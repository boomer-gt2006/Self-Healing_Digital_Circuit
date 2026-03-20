#!/usr/bin/env python3
"""
Approximate dynamic power from a VCD file by counting bit toggles.

Method:
- Parse VCD hierarchy and map each signal id-code to architecture buckets.
- Track `scenario_id` from tb_accuracy to bucket activity into S0..S12.
- Stream value changes and count known 0/1 bit transitions.
- Convert switching activity to estimated dynamic power using:

        P_dyn ~= alpha * C_eff * V^2 * f

Assumptions are user-configurable and defaults are provided.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple


ARCH_PREFIXES = {
    "baseline": ("tb_accuracy.u_baseline", "tb_accuracy.u_fi_base"),
    "dmr": ("tb_accuracy.u_dmr",),
    "tmr": ("tb_accuracy.u_tmr",),
    "adaptive": ("tb_accuracy.u_adaptive",),
}

SCENARIO_NAMES = {
    0: "S0_fault_free",
    1: "S1_flip_all_alu0",
    2: "S2_flip_all_alu1",
    3: "S3_flip_all_alu2",
    4: "S4_sa0_all_alu0",
    5: "S5_sa1_all_alu0",
    6: "S6_flip_lsb_alu0",
    7: "S7_flip_nibble_alu0",
    8: "S8_double_alu0_alu1",
    9: "S9_double_alu1_alu2",
    10: "S10_triple_fault",
    11: "S11_random_faults",
    12: "S12_burst_fault_recovery",
}


def build_default_schedule_ps() -> Dict[int, Tuple[int, int]]:
    """
    Fallback S0..S12 schedule derived from tb_accuracy timing.

    Assumptions from tb_accuracy.v:
    - CLK period = 10 ns
    - initial do_reset takes 5 cycles and completes at ~46 ns
    - S0 cycles: 10056
    - S1..S11 cycles each: do_reset(5) + warmup(512) + random(10000) = 10517
    - S12 cycles: do_reset(5) + random(10000) = 10005
    """
    start_ns = 46
    period_ns = 10

    s0_cycles = 10056
    s_std_cycles = 10517
    s12_cycles = 10005

    schedule_ps: Dict[int, Tuple[int, int]] = {}
    cur_ns = start_ns

    # S0
    end_ns = cur_ns + s0_cycles * period_ns
    schedule_ps[0] = (cur_ns * 1000, end_ns * 1000)
    cur_ns = end_ns

    # S1..S11
    for sid in range(1, 12):
        end_ns = cur_ns + s_std_cycles * period_ns
        schedule_ps[sid] = (cur_ns * 1000, end_ns * 1000)
        cur_ns = end_ns

    # S12
    end_ns = cur_ns + s12_cycles * period_ns
    schedule_ps[12] = (cur_ns * 1000, end_ns * 1000)

    return schedule_ps


def scenario_from_time_ps(time_ps: int, schedule_ps: Dict[int, Tuple[int, int]]) -> Optional[int]:
    for sid, (t0, t1) in schedule_ps.items():
        if t0 <= time_ps < t1:
            return sid
    return None


@dataclass
class SignalMeta:
    width: int
    groups: Set[str]


def classify_signal(full_name: str) -> Set[str]:
    groups: Set[str] = set()
    for grp, prefixes in ARCH_PREFIXES.items():
        if any(full_name.startswith(p) for p in prefixes):
            groups.add(grp)
    return groups


def parse_vcd_defs(vcd_path: Path) -> Tuple[Dict[str, SignalMeta], Optional[str], int]:
    id_meta: Dict[str, SignalMeta] = {}
    scope: List[str] = []
    scenario_id_code: Optional[str] = None
    enddef_line = 0

    with vcd_path.open("r", encoding="utf-8", errors="ignore") as f:
        for line_num, raw in enumerate(f, start=1):
            line = raw.strip()
            if not line:
                continue

            if line.startswith("$scope"):
                parts = line.split()
                if len(parts) >= 3:
                    scope.append(parts[2])
            elif line.startswith("$upscope"):
                if scope:
                    scope.pop()
            elif line.startswith("$var"):
                # $var <type> <size> <id_code> <ref> [range] $end
                parts = line.split()
                if len(parts) >= 5:
                    try:
                        width = int(parts[2])
                    except ValueError:
                        width = 1
                    id_code = parts[3]
                    ref = parts[4]
                    full_name = ".".join(scope + [ref])

                    if full_name in ("tb_accuracy.scenario_id", "tb_accuracy.scenario_dbg"):
                        scenario_id_code = id_code

                    groups = classify_signal(full_name)
                    if groups:
                        prev = id_meta.get(id_code)
                        if prev is None:
                            id_meta[id_code] = SignalMeta(width=width, groups=set(groups))
                        else:
                            prev.groups.update(groups)
                            if width > prev.width:
                                prev.width = width
            elif line.startswith("$enddefinitions"):
                enddef_line = line_num
                break

    if enddef_line == 0:
        raise RuntimeError("$enddefinitions not found in VCD")
    return id_meta, scenario_id_code, enddef_line


def scalar_flip(old: Optional[str], new: str) -> int:
    if old is None:
        return 0
    if old in ("0", "1") and new in ("0", "1") and old != new:
        return 1
    return 0


def vector_flips(old: Optional[str], new: str, width: int) -> int:
    if old is None:
        return 0

    old_bits = old.rjust(width, "0")[-width:]
    new_bits = new.rjust(width, "0")[-width:]

    flips = 0
    for ob, nb in zip(old_bits, new_bits):
        if ob in "01" and nb in "01" and ob != nb:
            flips += 1
    return flips


def parse_scalar_to_int(val: str) -> Optional[int]:
    if val in ("0", "1"):
        return int(val)
    return None


def parse_vector_to_int(bits: str) -> Optional[int]:
    if any(c not in "01" for c in bits):
        return None
    return int(bits, 2)


def process_changes(
    vcd_path: Path,
    id_meta: Dict[str, SignalMeta],
    scenario_id_code: Optional[str],
    start_line: int,
):
    group_toggles = {k: 0 for k in ARCH_PREFIXES}
    group_sig_bits = {k: 0 for k in ARCH_PREFIXES}
    scenario_group_toggles = {
        sid: {k: 0 for k in ARCH_PREFIXES}
        for sid in SCENARIO_NAMES
    }
    scenario_time_ps = {sid: 0 for sid in SCENARIO_NAMES}
    schedule_ps = build_default_schedule_ps()

    # Sum unique id_code widths into each group as a rough C_eff proxy.
    for id_code, meta in id_meta.items():
        for grp in meta.groups:
            group_sig_bits[grp] += meta.width

    values: Dict[str, str] = {}
    current_time = 0
    prev_time = 0
    end_time = 0
    current_scenario: Optional[int] = None

    with vcd_path.open("r", encoding="utf-8", errors="ignore") as f:
        for _ in range(start_line):
            next(f, None)

        for raw in f:
            line = raw.strip()
            if not line:
                continue

            if line.startswith("#"):
                try:
                    prev_time = current_time
                    current_time = int(line[1:])
                    active_sid = current_scenario
                    if active_sid is None:
                        active_sid = scenario_from_time_ps(prev_time, schedule_ps)
                    if active_sid in scenario_time_ps:
                        scenario_time_ps[active_sid] += max(current_time - prev_time, 0)
                    if current_time > end_time:
                        end_time = current_time
                except ValueError:
                    pass
                continue

            # Scalar: [01xXzZ]<id>
            c0 = line[0]
            if c0 in "01xXzZ":
                val = c0.lower()
                id_code = line[1:]

                if scenario_id_code is not None and id_code == scenario_id_code:
                    sid = parse_scalar_to_int(val)
                    current_scenario = sid if sid in SCENARIO_NAMES else None
                    values[id_code] = val
                    continue

                meta = id_meta.get(id_code)
                if meta is None:
                    continue
                old = values.get(id_code)
                flips = scalar_flip(old, val)
                if flips:
                    active_sid = current_scenario
                    if active_sid is None:
                        active_sid = scenario_from_time_ps(current_time, schedule_ps)
                    for grp in meta.groups:
                        group_toggles[grp] += flips
                        if active_sid in scenario_group_toggles:
                            scenario_group_toggles[active_sid][grp] += flips
                values[id_code] = val
                continue

            # Vector: b<binary> <id>
            if c0 in "bB":
                parts = line.split()
                if len(parts) != 2:
                    continue
                bits = parts[0][1:].lower()
                id_code = parts[1]

                if scenario_id_code is not None and id_code == scenario_id_code:
                    sid = parse_vector_to_int(bits)
                    current_scenario = sid if sid in SCENARIO_NAMES else None
                    values[id_code] = bits
                    continue

                meta = id_meta.get(id_code)
                if meta is None:
                    continue
                old = values.get(id_code)
                flips = vector_flips(old, bits, meta.width)
                if flips:
                    active_sid = current_scenario
                    if active_sid is None:
                        active_sid = scenario_from_time_ps(current_time, schedule_ps)
                    for grp in meta.groups:
                        group_toggles[grp] += flips
                        if active_sid in scenario_group_toggles:
                            scenario_group_toggles[active_sid][grp] += flips
                values[id_code] = bits
                continue

            # Real/value formats not used here; ignore.

    return group_toggles, group_sig_bits, scenario_group_toggles, scenario_time_ps, end_time


def calc_metrics(
    toggles: int,
    bits: int,
    sim_time_s: float,
    freq_hz: float,
    cap_ff: float,
    volt_v: float,
) -> Tuple[float, float, float, float]:
    bits_safe = max(bits, 1)
    cycles = max(sim_time_s * freq_hz, 1.0)
    alpha = toggles / (bits_safe * cycles)
    toggles_per_s = toggles / sim_time_s if sim_time_s > 0 else 0.0
    power_w = toggles_per_s * (cap_ff * 1e-15) * (volt_v ** 2)
    power_mw = power_w * 1e3
    return alpha, toggles_per_s, power_w, power_mw


def main() -> None:
    parser = argparse.ArgumentParser(description="Approximate dynamic power from VCD activity")
    parser.add_argument("--vcd", default="tb_accuracy.vcd", help="Path to VCD file")
    parser.add_argument("--csv", default="synth/reports/vcd_power_estimate.csv", help="Output CSV file")
    parser.add_argument(
        "--scenario-csv",
        default="synth/reports/vcd_power_estimate_by_scenario.csv",
        help="Per-scenario output CSV file",
    )
    parser.add_argument("--cap-ff", type=float, default=10.0, help="Assumed effective capacitance per tracked bit in fF")
    parser.add_argument("--voltage", type=float, default=1.0, help="Assumed supply voltage in V")
    parser.add_argument("--freq-hz", type=float, default=100e6, help="Assumed clock frequency in Hz")
    args = parser.parse_args()

    vcd_path = Path(args.vcd)
    if not vcd_path.exists():
        raise FileNotFoundError(f"VCD file not found: {vcd_path}")

    id_meta, scenario_id_code, enddef_line = parse_vcd_defs(vcd_path)
    group_toggles, group_sig_bits, scenario_group_toggles, scenario_time_ps, end_time_ps = process_changes(
        vcd_path, id_meta, scenario_id_code, enddef_line
    )

    if end_time_ps <= 0:
        raise RuntimeError("Invalid simulation end time in VCD")

    sim_time_ns = end_time_ps / 1000.0

    results = []
    for grp in ("baseline", "dmr", "tmr", "adaptive"):
        toggles = group_toggles.get(grp, 0)
        bits = max(group_sig_bits.get(grp, 0), 1)
        sim_time_s = sim_time_ns * 1e-9
        alpha, toggles_per_s, power_w, power_mw = calc_metrics(
            toggles,
            bits,
            sim_time_s,
            args.freq_hz,
            args.cap_ff,
            args.voltage,
        )
        toggles_per_ns = toggles_per_s * 1e-9
        norm_toggle_rate = toggles_per_ns / bits
        results.append((grp, toggles, bits, alpha, toggles_per_ns, norm_toggle_rate, power_w, power_mw))

    # Normalize to baseline for easier comparison.
    baseline_ref = results[0][7] if results and results[0][7] > 0 else 1.0
    rel = {r[0]: (r[7] / baseline_ref) for r in results}

    out_csv = Path(args.csv)
    out_csv.parent.mkdir(parents=True, exist_ok=True)
    with out_csv.open("w", encoding="utf-8") as f:
        f.write(
            "architecture,total_toggles,tracked_bits,sim_time_ns,alpha,toggles_per_ns,"
            "norm_toggles_per_ns_per_bit,est_power_w,est_power_mw,relative_to_baseline\n"
        )
        for grp, toggles, bits, alpha, toggles_per_ns, norm_toggle_rate, power_w, power_mw in results:
            f.write(
                f"{grp},{toggles},{bits},{sim_time_ns:.3f},{alpha:.9f},{toggles_per_ns:.6f},"
                f"{norm_toggle_rate:.9f},{power_w:.12e},{power_mw:.9f},{rel[grp]:.6f}\n"
            )

    # Per-scenario report
    scenario_csv = Path(args.scenario_csv)
    scenario_csv.parent.mkdir(parents=True, exist_ok=True)
    with scenario_csv.open("w", encoding="utf-8") as f:
        f.write(
            "scenario_id,scenario,architecture,scenario_time_ns,total_toggles,tracked_bits,alpha,"
            "toggles_per_ns,est_power_w,est_power_mw\n"
        )
        for sid in sorted(SCENARIO_NAMES):
            scen_time_ns = scenario_time_ps.get(sid, 0) / 1000.0
            scen_time_s = scen_time_ns * 1e-9
            for grp in ("baseline", "dmr", "tmr", "adaptive"):
                toggles = scenario_group_toggles[sid][grp]
                bits = max(group_sig_bits[grp], 1)
                if scen_time_s <= 0:
                    alpha = 0.0
                    toggles_per_s = 0.0
                    power_w = 0.0
                    power_mw = 0.0
                else:
                    alpha, toggles_per_s, power_w, power_mw = calc_metrics(
                        toggles,
                        bits,
                        scen_time_s,
                        args.freq_hz,
                        args.cap_ff,
                        args.voltage,
                    )
                toggles_per_ns = toggles_per_s * 1e-9
                f.write(
                    f"{sid},{SCENARIO_NAMES[sid]},{grp},{scen_time_ns:.3f},{toggles},{bits},{alpha:.9f},"
                    f"{toggles_per_ns:.6f},{power_w:.12e},{power_mw:.9f}\n"
                )

    print("VCD power-approximation complete")
    print(f"VCD: {vcd_path}")
    print(f"Sim time: {sim_time_ns:.3f} ns")
    print(f"Assumptions: C_bit={args.cap_ff:.3f} fF, V={args.voltage:.3f} V, f={args.freq_hz:.3f} Hz")
    print(f"Report: {out_csv}")
    print(f"Per-scenario report: {scenario_csv}")
    print("")
    print("Architecture summary (estimated dynamic power):")
    for grp, toggles, bits, alpha, toggles_per_ns, norm_toggle_rate, power_w, power_mw in results:
        print(
            f"  {grp:9s} toggles={toggles:12d}  bits={bits:6d}  "
            f"alpha={alpha:.6f}  P={power_mw:.6f} mW  rel={rel[grp]:.4f}x"
        )

    print("")
    print("Scenario power summary (mW):")
    for sid in sorted(SCENARIO_NAMES):
        scen_time_ns = scenario_time_ps.get(sid, 0) / 1000.0
        if scen_time_ns <= 0:
            continue
        row = []
        for grp in ("baseline", "dmr", "tmr", "adaptive"):
            toggles = scenario_group_toggles[sid][grp]
            bits = max(group_sig_bits[grp], 1)
            _, _, _, power_mw = calc_metrics(
                toggles,
                bits,
                scen_time_ns * 1e-9,
                args.freq_hz,
                args.cap_ff,
                args.voltage,
            )
            row.append(f"{grp}={power_mw:.6f}")
        print(f"  {SCENARIO_NAMES[sid]:24s} ({scen_time_ns:10.3f} ns): " + ", ".join(row))


if __name__ == "__main__":
    main()

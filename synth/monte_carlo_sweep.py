#!/usr/bin/env python3
"""Monte Carlo-style fault probability sweep for tb_accuracy.

Sweeps TB_FAULT_PROB_PCT used in scenario S11 and records:
- Grand-total accuracy per architecture
- S11 accuracy per architecture
- Adaptive estimated dynamic power from VCD

This script reuses the existing Vivado xsim flow and VCD power estimator.
"""

from __future__ import annotations

import argparse
import csv
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

ROOT = Path(__file__).resolve().parent.parent
REPORT_DIR = ROOT / "synth" / "reports"
TMP_DIR = REPORT_DIR / "mc_sweep_tmp"

VIVADO_BIN = Path(r"C:\Xilinx\2025.1\Vivado\bin")
XVLOG_EXE = str(VIVADO_BIN / "xvlog.bat")
XELAB_EXE = str(VIVADO_BIN / "xelab.bat")
XSIM_EXE = str(VIVADO_BIN / "xsim.bat")

TB_CFG = ROOT / "testbench" / "tb_accuracy_cfg.vh"

RTL_FILES = [
    "rtl/alu.v",
    "rtl/fault_injector.v",
    "rtl/majority_voter.v",
    "rtl/penta_voter.v",
    "rtl/residue_checker.v",
    "rtl/risk_estimator.v",
    "rtl/redundancy_controller.v",
    "rtl/top_dmr.v",
    "rtl/top_tmr.v",
    "rtl/top_adaptive.v",
    "testbench/tb_accuracy.v",
]


def run_cmd(cmd: List[str], cwd: Path, log_path: Path) -> int:
    with log_path.open("w", encoding="utf-8") as logf:
        proc = subprocess.run(
            ["cmd", "/c", *cmd],
            cwd=cwd,
            stdout=logf,
            stderr=subprocess.STDOUT,
            check=False,
        )
    return proc.returncode


def write_tb_cfg(n_random: int, n_corner: int, n_warmup: int, n_burst: int, fault_prob_pct: int) -> None:
    text = "\n".join(
        [
            "`define TB_CLK_HALF 5",
            f"`define TB_N_RANDOM {n_random}",
            f"`define TB_N_CORNER {n_corner}",
            f"`define TB_N_WARMUP {n_warmup}",
            f"`define TB_N_BURST {n_burst}",
            "`define TB_SEED 32'hDEAD_BEEF",
            f"`define TB_FAULT_PROB_PCT {fault_prob_pct}",
            "",
        ]
    )
    TB_CFG.write_text(text, encoding="utf-8")


def restore_tb_cfg_defaults() -> None:
    write_tb_cfg(
        n_random=10000,
        n_corner=500,
        n_warmup=512,
        n_burst=1000,
        fault_prob_pct=50,
    )


def parse_accuracy_line(line: str) -> Optional[Tuple[float, float, float, float]]:
    vals = re.findall(r"([0-9]+\.[0-9]+)%", line)
    if len(vals) < 4:
        return None
    return tuple(float(v) for v in vals[:4])


def _parse_s11_metrics_line(line: str) -> Optional[Dict[str, float]]:
    if not line.startswith("S11_METRICS|"):
        return None
    out: Dict[str, float] = {}
    parts = line.strip().split("|")[1:]
    for part in parts:
        if "=" not in part:
            continue
        k, v = part.split("=", 1)
        try:
            out[k.strip()] = float(v.strip())
        except ValueError:
            pass
    if not out:
        return None
    return out


def _safe_div(num: float, den: float) -> float:
    if den == 0:
        return 0.0
    return num / den


def parse_summary(log_path: Path) -> Dict[str, float]:
    text = log_path.read_text(encoding="utf-8", errors="ignore")
    grand = None
    s11 = None
    s11_metrics: Optional[Dict[str, float]] = None

    for line in text.splitlines():
        if "GRAND TOTAL (all scenarios combined)" in line:
            grand = parse_accuracy_line(line)
        elif "S11 Random fault injection" in line:
            s11 = parse_accuracy_line(line)
        else:
            parsed = _parse_s11_metrics_line(line)
            if parsed is not None:
                s11_metrics = parsed

    if grand is None or s11 is None:
        raise RuntimeError("Could not parse GRAND TOTAL or S11 accuracy from simulation log")

    data: Dict[str, float] = {
        "grand_base_pct": grand[0],
        "grand_dmr_pct": grand[1],
        "grand_tmr_pct": grand[2],
        "grand_adaptive_pct": grand[3],
        "s11_base_pct": s11[0],
        "s11_dmr_pct": s11[1],
        "s11_tmr_pct": s11[2],
        "s11_adaptive_pct": s11[3],
    }

    # If S11 machine metrics are present, derive reliability metrics.
    if s11_metrics is not None:
        inj_base = s11_metrics.get("inj_base", 0.0)
        inj_dmr = s11_metrics.get("inj_dmr", 0.0)
        inj_tmr = s11_metrics.get("inj_tmr", 0.0)
        inj_adp = s11_metrics.get("inj_adp", 0.0)
        det_dmr = s11_metrics.get("det_dmr", 0.0)
        det_tmr = s11_metrics.get("det_tmr", 0.0)
        det_adp = s11_metrics.get("det_adp", 0.0)
        ok_base = s11_metrics.get("ok_base", 0.0)
        ok_dmr = s11_metrics.get("ok_dmr", 0.0)
        ok_tmr = s11_metrics.get("ok_tmr", 0.0)
        ok_adp = s11_metrics.get("ok_adp", 0.0)
        tot = s11_metrics.get("tot", 0.0)

        # Detection / masking / SDC for S11
        data["s11_detection_base"] = 0.0
        data["s11_detection_dmr"] = _safe_div(det_dmr, inj_dmr)
        data["s11_detection_tmr"] = _safe_div(det_tmr, inj_tmr)
        data["s11_detection_adaptive"] = _safe_div(det_adp, inj_adp)

        data["s11_masking_base"] = _safe_div(ok_base, inj_base)
        data["s11_masking_dmr"] = _safe_div(ok_dmr, inj_dmr)
        data["s11_masking_tmr"] = _safe_div(ok_tmr, inj_tmr)
        data["s11_masking_adaptive"] = _safe_div(ok_adp, inj_adp)

        data["s11_sdc_base"] = max(0.0, 1.0 - data["s11_detection_base"])
        data["s11_sdc_dmr"] = max(0.0, 1.0 - data["s11_detection_dmr"])
        data["s11_sdc_tmr"] = max(0.0, 1.0 - data["s11_detection_tmr"])
        data["s11_sdc_adaptive"] = max(0.0, 1.0 - data["s11_detection_adaptive"])

        # Reliability over S11 operations using undetected faults
        undet_base = inj_base
        undet_dmr = max(0.0, inj_dmr - det_dmr)
        undet_tmr = max(0.0, inj_tmr - det_tmr)
        undet_adp = max(0.0, inj_adp - det_adp)

        data["s11_reliability_base"] = max(0.0, 1.0 - _safe_div(undet_base, tot))
        data["s11_reliability_dmr"] = max(0.0, 1.0 - _safe_div(undet_dmr, tot))
        data["s11_reliability_tmr"] = max(0.0, 1.0 - _safe_div(undet_tmr, tot))
        data["s11_reliability_adaptive"] = max(0.0, 1.0 - _safe_div(undet_adp, tot))

    return data


def parse_adaptive_power(power_csv: Path) -> float:
    with power_csv.open("r", encoding="utf-8", newline="") as f:
        rdr = csv.DictReader(f)
        for row in rdr:
            if row.get("architecture", "").strip().lower() == "adaptive":
                return float(row["est_power_mw"])
    raise RuntimeError("Adaptive row not found in power CSV")


def main() -> None:
    parser = argparse.ArgumentParser(description="Sweep fault probability for tb_accuracy")
    parser.add_argument("--probs", default="1,2,5,10,20,30,50", help="Comma-separated fault probability percentages")
    parser.add_argument("--n-random", type=int, default=2000)
    parser.add_argument("--n-corner", type=int, default=200)
    parser.add_argument("--n-warmup", type=int, default=256)
    parser.add_argument("--n-burst", type=int, default=500)
    parser.add_argument("--cap-ff", type=float, default=10.0)
    parser.add_argument("--out", default="synth/reports/monte_carlo_sweep.csv")
    args = parser.parse_args()

    probs = [int(p.strip()) for p in args.probs.split(",") if p.strip()]
    for p in probs:
        if p < 0 or p > 100:
            raise ValueError(f"Invalid probability {p}; must be 0..100")

    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    TMP_DIR.mkdir(parents=True, exist_ok=True)

    rows: List[Dict[str, float]] = []

    try:
        for p in probs:
            print(f"[Sweep] fault_prob_pct={p}")

            write_tb_cfg(args.n_random, args.n_corner, args.n_warmup, args.n_burst, p)

            tag = f"p{p:03d}"
            xvlog_log = TMP_DIR / f"{tag}_xvlog.log"
            xelab_log = TMP_DIR / f"{tag}_xelab.log"
            xsim_log = TMP_DIR / f"{tag}_xsim.log"

            snap = f"tb_accuracy_mc_{tag}"

            rc = run_cmd([XVLOG_EXE, "--sv", *RTL_FILES], ROOT, xvlog_log)
            if rc != 0:
                raise RuntimeError(f"xvlog failed at p={p}; see {xvlog_log}")

            rc = run_cmd([XELAB_EXE, "tb_accuracy", "-s", snap], ROOT, xelab_log)
            if rc != 0:
                raise RuntimeError(f"xelab failed at p={p}; see {xelab_log}")

            rc = run_cmd([XSIM_EXE, snap, "-R"], ROOT, xsim_log)
            if rc != 0:
                raise RuntimeError(f"xsim failed at p={p}; see {xsim_log}")

            summary = parse_summary(xsim_log)

            power_csv = TMP_DIR / f"{tag}_power.csv"
            scen_csv = TMP_DIR / f"{tag}_power_by_scenario.csv"
            pwr_log = TMP_DIR / f"{tag}_power.log"
            rc = run_cmd(
                [
                    sys.executable,
                    "synth/approx_power_from_vcd.py",
                    "--vcd",
                    "tb_accuracy.vcd",
                    "--cap-ff",
                    str(args.cap_ff),
                    "--voltage",
                    "1.0",
                    "--freq-hz",
                    "100e6",
                    "--csv",
                    str(power_csv),
                    "--scenario-csv",
                    str(scen_csv),
                ],
                ROOT,
                pwr_log,
            )
            if rc != 0:
                raise RuntimeError(f"Power estimation failed at p={p}; see {pwr_log}")

            adaptive_power_mw = parse_adaptive_power(power_csv)

            row: Dict[str, float] = {
                "fault_prob_pct": float(p),
                **summary,
                "adaptive_power_mw": adaptive_power_mw,
                "cap_ff": args.cap_ff,
                "n_random": float(args.n_random),
                "n_corner": float(args.n_corner),
                "n_warmup": float(args.n_warmup),
                "n_burst": float(args.n_burst),
            }
            rows.append(row)

        out_path = (ROOT / args.out).resolve()
        out_path.parent.mkdir(parents=True, exist_ok=True)
        with out_path.open("w", encoding="utf-8", newline="") as f:
            fieldnames = [
                "fault_prob_pct",
                "grand_base_pct",
                "grand_dmr_pct",
                "grand_tmr_pct",
                "grand_adaptive_pct",
                "s11_base_pct",
                "s11_dmr_pct",
                "s11_tmr_pct",
                "s11_adaptive_pct",
                "s11_detection_base",
                "s11_detection_dmr",
                "s11_detection_tmr",
                "s11_detection_adaptive",
                "s11_masking_base",
                "s11_masking_dmr",
                "s11_masking_tmr",
                "s11_masking_adaptive",
                "s11_sdc_base",
                "s11_sdc_dmr",
                "s11_sdc_tmr",
                "s11_sdc_adaptive",
                "s11_reliability_base",
                "s11_reliability_dmr",
                "s11_reliability_tmr",
                "s11_reliability_adaptive",
                "adaptive_power_mw",
                "cap_ff",
                "n_random",
                "n_corner",
                "n_warmup",
                "n_burst",
            ]
            w = csv.DictWriter(f, fieldnames=fieldnames)
            w.writeheader()
            w.writerows(rows)

        print(f"Wrote: {out_path}")

    finally:
        restore_tb_cfg_defaults()


if __name__ == "__main__":
    main()

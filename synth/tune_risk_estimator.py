#!/usr/bin/env python3
"""Hyperparameter sweep for risk_estimator thresholds.

For each threshold set this script:
1. Compiles and runs tb_accuracy with compile-time defines.
2. Extracts Adaptive GRAND TOTAL accuracy from simulator output.
3. Runs VCD-based power approximation and extracts Adaptive power.
4. Produces ranking and Pareto-front tradeoff reports.
"""

from __future__ import annotations

import csv
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional


ROOT = Path(__file__).resolve().parent.parent
REPORT_DIR = ROOT / "synth" / "reports"
TMP_DIR = REPORT_DIR / "tuning_tmp"
VIVADO_BIN = Path(r"C:\Xilinx\2025.1\Vivado\bin")
XVLOG_EXE = str(VIVADO_BIN / "xvlog.bat")
XELAB_EXE = str(VIVADO_BIN / "xelab.bat")
XSIM_EXE = str(VIVADO_BIN / "xsim.bat")
ADP_CFG = ROOT / "rtl" / "adaptive_risk_cfg.vh"
TB_CFG = ROOT / "testbench" / "tb_accuracy_cfg.vh"


@dataclass
class SweepConfig:
    name: str
    window: int
    toggle_med: int
    toggle_high: int
    error_med: int
    error_high: int


@dataclass
class SweepResult:
    config: SweepConfig
    adaptive_accuracy_pct: float
    adaptive_power_mw: float
    sim_ok: bool
    notes: str = ""


CONFIGS: List[SweepConfig] = [
    SweepConfig("default", 64, 10, 30, 2, 4),
    SweepConfig("aggressive_a", 64, 6, 18, 1, 2),
    SweepConfig("aggressive_b", 64, 8, 24, 1, 3),
    SweepConfig("balanced_a", 64, 8, 28, 2, 4),
    SweepConfig("balanced_b", 64, 10, 26, 2, 3),
    SweepConfig("error_sensitive", 64, 12, 36, 1, 2),
    SweepConfig("toggle_sensitive", 64, 6, 22, 3, 5),
    SweepConfig("conservative_a", 64, 12, 36, 3, 5),
    SweepConfig("conservative_b", 64, 14, 42, 4, 6),
    SweepConfig("very_conservative", 64, 16, 48, 4, 8),
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


def parse_adaptive_accuracy(sim_log_path: Path) -> Optional[float]:
    text = sim_log_path.read_text(encoding="utf-8", errors="ignore")
    for line in text.splitlines():
        if "GRAND TOTAL (all scenarios combined)" not in line:
            continue
        cols = [c.strip() for c in line.split("|") if c.strip()]
        if len(cols) < 5:
            continue
        # Expected cols: scenario, baseline, dmr, tmr, adaptive
        adaptive = cols[-1].replace("%", "").strip()
        try:
            return float(adaptive)
        except ValueError:
            continue
    return None


def parse_adaptive_power(csv_path: Path) -> Optional[float]:
    with csv_path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row.get("architecture", "").strip().lower() == "adaptive":
                try:
                    return float(row["est_power_mw"])
                except (KeyError, ValueError):
                    return None
    return None


def pareto_front(results: List[SweepResult]) -> List[SweepResult]:
    good = [r for r in results if r.sim_ok]
    front: List[SweepResult] = []
    for r in good:
        dominated = False
        for o in good:
            if o is r:
                continue
            better_or_equal_acc = o.adaptive_accuracy_pct >= r.adaptive_accuracy_pct
            better_or_equal_pow = o.adaptive_power_mw <= r.adaptive_power_mw
            strictly_better = (
                o.adaptive_accuracy_pct > r.adaptive_accuracy_pct
                or o.adaptive_power_mw < r.adaptive_power_mw
            )
            if better_or_equal_acc and better_or_equal_pow and strictly_better:
                dominated = True
                break
        if not dominated:
            front.append(r)
    front.sort(key=lambda x: (-x.adaptive_accuracy_pct, x.adaptive_power_mw))
    return front


def main() -> None:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    TMP_DIR.mkdir(parents=True, exist_ok=True)

    results: List[SweepResult] = []

    rtl_files = [
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

    default_adp_cfg = """`define ADP_WINDOW_CYCLES 64
`define ADP_TOGGLE_MED 10
`define ADP_TOGGLE_HIGH 30
`define ADP_ERROR_MED 2
`define ADP_ERROR_HIGH 4
"""
    default_tb_cfg = """`define TB_CLK_HALF 5
`define TB_N_RANDOM 10000
`define TB_N_CORNER 500
`define TB_N_WARMUP 512
`define TB_N_BURST 1000
`define TB_SEED 32'hDEAD_BEEF
"""

    ADP_CFG.write_text(default_adp_cfg, encoding="utf-8")
    TB_CFG.write_text(default_tb_cfg, encoding="utf-8")

    for idx, cfg in enumerate(CONFIGS, start=1):
        snap = f"tb_accuracy_tune_{idx}_{cfg.name}"
        print(f"[{idx}/{len(CONFIGS)}] Running {cfg.name} ...")

        xvlog_cmd = [XVLOG_EXE, "--sv"]
        xvlog_cmd.extend(rtl_files)

        xelab_cmd = [XELAB_EXE, "tb_accuracy", "-s", snap]
        xsim_cmd = [XSIM_EXE, snap, "-R"]

        log_xvlog = TMP_DIR / f"{cfg.name}_xvlog.log"
        log_xelab = TMP_DIR / f"{cfg.name}_xelab.log"
        log_xsim = TMP_DIR / f"{cfg.name}_xsim.log"

        ADP_CFG.write_text(
            "\n".join(
                [
                    f"`define ADP_WINDOW_CYCLES {cfg.window}",
                    f"`define ADP_TOGGLE_MED {cfg.toggle_med}",
                    f"`define ADP_TOGGLE_HIGH {cfg.toggle_high}",
                    f"`define ADP_ERROR_MED {cfg.error_med}",
                    f"`define ADP_ERROR_HIGH {cfg.error_high}",
                    "",
                ]
            ),
            encoding="utf-8",
        )
        TB_CFG.write_text(
            "\n".join(
                [
                    "`define TB_CLK_HALF 5",
                    "`define TB_N_RANDOM 2000",
                    "`define TB_N_CORNER 200",
                    "`define TB_N_WARMUP 256",
                    "`define TB_N_BURST 500",
                    "`define TB_SEED 32'hDEAD_BEEF",
                    "",
                ]
            ),
            encoding="utf-8",
        )

        rc = run_cmd(xvlog_cmd, ROOT, log_xvlog)
        if rc != 0:
            results.append(SweepResult(cfg, 0.0, 0.0, False, "xvlog failed"))
            continue

        rc = run_cmd(xelab_cmd, ROOT, log_xelab)
        if rc != 0:
            results.append(SweepResult(cfg, 0.0, 0.0, False, "xelab failed"))
            continue

        rc = run_cmd(xsim_cmd, ROOT, log_xsim)
        if rc != 0:
            results.append(SweepResult(cfg, 0.0, 0.0, False, "xsim failed"))
            continue

        acc = parse_adaptive_accuracy(log_xsim)
        if acc is None:
            results.append(SweepResult(cfg, 0.0, 0.0, False, "could not parse adaptive accuracy"))
            continue

        power_csv = TMP_DIR / f"{cfg.name}_power.csv"
        scen_csv = TMP_DIR / f"{cfg.name}_power_by_scenario.csv"
        power_cmd = [
            sys.executable,
            "synth/approx_power_from_vcd.py",
            "--vcd",
            "tb_accuracy.vcd",
            "--cap-ff",
            "12.0",
            "--voltage",
            "1.0",
            "--freq-hz",
            "100e6",
            "--csv",
            str(power_csv),
            "--scenario-csv",
            str(scen_csv),
        ]
        log_power = TMP_DIR / f"{cfg.name}_power_tool.log"
        rc = run_cmd(power_cmd, ROOT, log_power)
        if rc != 0:
            results.append(SweepResult(cfg, acc, 0.0, False, "power tool failed"))
            continue

        pwr = parse_adaptive_power(power_csv)
        if pwr is None:
            results.append(SweepResult(cfg, acc, 0.0, False, "could not parse adaptive power"))
            continue

        results.append(SweepResult(cfg, acc, pwr, True))

    valid = [r for r in results if r.sim_ok]
    if not valid:
        raise RuntimeError("No successful sweep points.")

    # Normalize and compute scalar score: maximize accuracy, minimize power.
    min_p = min(r.adaptive_power_mw for r in valid)
    max_p = max(r.adaptive_power_mw for r in valid)
    min_a = min(r.adaptive_accuracy_pct for r in valid)
    max_a = max(r.adaptive_accuracy_pct for r in valid)

    def norm(v: float, lo: float, hi: float) -> float:
        if hi <= lo:
            return 0.0
        return (v - lo) / (hi - lo)

    rows = []
    for r in valid:
        acc_n = norm(r.adaptive_accuracy_pct, min_a, max_a)
        pwr_n = norm(r.adaptive_power_mw, min_p, max_p)
        score = 0.7 * acc_n + 0.3 * (1.0 - pwr_n)
        rows.append((r, score))

    rows.sort(key=lambda t: t[1], reverse=True)
    pfront = pareto_front(valid)

    out_csv = REPORT_DIR / "risk_tuning_results.csv"
    with out_csv.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow([
            "config",
            "window",
            "toggle_med",
            "toggle_high",
            "error_med",
            "error_high",
            "adaptive_accuracy_pct",
            "adaptive_power_mw",
            "status",
            "notes",
        ])
        for r in results:
            w.writerow([
                r.config.name,
                r.config.window,
                r.config.toggle_med,
                r.config.toggle_high,
                r.config.error_med,
                r.config.error_high,
                f"{r.adaptive_accuracy_pct:.4f}",
                f"{r.adaptive_power_mw:.9f}",
                "ok" if r.sim_ok else "failed",
                r.notes,
            ])

    out_md = REPORT_DIR / "risk_tuning_report.md"
    with out_md.open("w", encoding="utf-8") as f:
        f.write("# Risk Estimator Hyperparameter Tuning\n\n")
        f.write("Sweep objective: maximize Adaptive GRAND TOTAL accuracy while minimizing Adaptive estimated dynamic power (from VCD).\n\n")
        f.write("Tuning run settings: `TB_N_RANDOM=2000`, `TB_N_CORNER=200`, `TB_N_WARMUP=256`, `TB_N_BURST=500`.\n\n")
        f.write("## Ranked Results (score = 0.7*acc + 0.3*(1-power))\n\n")
        f.write("| Rank | Config | Window | Tmed | Thigh | Emed | Ehigh | Accuracy (%) | Power (mW) | Score |\n")
        f.write("|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|\n")
        for i, (r, score) in enumerate(rows, start=1):
            f.write(
                f"| {i} | {r.config.name} | {r.config.window} | {r.config.toggle_med} | {r.config.toggle_high} | "
                f"{r.config.error_med} | {r.config.error_high} | {r.adaptive_accuracy_pct:.2f} | {r.adaptive_power_mw:.6f} | {score:.4f} |\n"
            )

        f.write("\n## Pareto Front (non-dominated)\n\n")
        f.write("| Config | Accuracy (%) | Power (mW) | Thresholds (Tmed/Thigh, Emed/Ehigh) |\n")
        f.write("|---|---:|---:|---|\n")
        for r in pfront:
            f.write(
                f"| {r.config.name} | {r.adaptive_accuracy_pct:.2f} | {r.adaptive_power_mw:.6f} | "
                f"{r.config.toggle_med}/{r.config.toggle_high}, {r.config.error_med}/{r.config.error_high} |\n"
            )

        best = rows[0][0]
        f.write("\n## Recommendation\n\n")
        f.write(
            f"Recommended config: **{best.config.name}** with "
            f"`TOGGLE_MED={best.config.toggle_med}`, `TOGGLE_HIGH={best.config.toggle_high}`, "
            f"`ERROR_MED={best.config.error_med}`, `ERROR_HIGH={best.config.error_high}`.\n\n"
        )
        f.write(
            f"Observed Adaptive metrics at this setting: **accuracy {best.adaptive_accuracy_pct:.2f}%**, "
            f"**power {best.adaptive_power_mw:.6f} mW**.\n"
        )

    print(f"Wrote: {out_csv}")
    print(f"Wrote: {out_md}")

    # Restore default config headers for regular runs.
    ADP_CFG.write_text(default_adp_cfg, encoding="utf-8")
    TB_CFG.write_text(default_tb_cfg, encoding="utf-8")


if __name__ == "__main__":
    main()

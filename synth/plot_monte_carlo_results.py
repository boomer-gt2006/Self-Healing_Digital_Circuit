#!/usr/bin/env python3
"""Generate evaluation graphs from monte_carlo_sweep.csv.

Produces:
1) detection_vs_fault_probability.png
2) reliability_comparison.png
3) masking_vs_fault_probability.png
4) overhead_vs_reliability_improvement.png
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent


def read_rows(csv_path: Path) -> List[Dict[str, float]]:
    rows: List[Dict[str, float]] = []
    with csv_path.open("r", encoding="utf-8", newline="") as f:
        rdr = csv.DictReader(f)
        for row in rdr:
            parsed: Dict[str, float] = {}
            for k, v in row.items():
                if v is None or v == "":
                    continue
                try:
                    parsed[k] = float(v)
                except ValueError:
                    pass
            rows.append(parsed)
    rows.sort(key=lambda r: r.get("fault_prob_pct", 0.0))
    return rows


def read_lut_overheads(module_csv: Path) -> Dict[str, float]:
    lut_map: Dict[str, float] = {}
    with module_csv.open("r", encoding="utf-8", newline="") as f:
        rdr = csv.DictReader(f)
        for row in rdr:
            name = row.get("Module", "").strip().lower()
            luts = row.get("LUTs", "").strip()
            if not luts.isdigit():
                continue
            lut_map[name] = float(luts)

    base = lut_map.get("alu", 1.0)
    overhead = {
        "single": 1.0,
        "dmr": lut_map.get("top_dmr", base) / base,
        "tmr": lut_map.get("top_tmr", base) / base,
        "adaptive": lut_map.get("top_adaptive", base) / base,
    }
    return overhead


def get_series(rows: List[Dict[str, float]], key: str) -> List[float]:
    return [r.get(key, 0.0) for r in rows]


def main() -> None:
    ap = argparse.ArgumentParser(description="Plot Monte Carlo sweep results")
    ap.add_argument("--in", dest="in_csv", default="synth/reports/monte_carlo_sweep.csv")
    ap.add_argument("--module-util", default="synth/reports/module_utilization.csv")
    ap.add_argument("--out-dir", default="synth/reports/figures")
    args = ap.parse_args()

    in_csv = (ROOT / args.in_csv).resolve()
    out_dir = (ROOT / args.out_dir).resolve()
    module_csv = (ROOT / args.module_util).resolve()

    out_dir.mkdir(parents=True, exist_ok=True)

    rows = read_rows(in_csv)
    if not rows:
        raise RuntimeError(f"No data rows found in {in_csv}")

    p = get_series(rows, "fault_prob_pct")

    # 1) Detection vs fault probability
    plt.figure(figsize=(8, 5))
    plt.plot(p, get_series(rows, "s11_detection_dmr"), marker="o", label="DMR")
    plt.plot(p, get_series(rows, "s11_detection_tmr"), marker="o", label="Adaptive TMR")
    plt.plot(p, get_series(rows, "s11_detection_adaptive"), marker="o", label="Adaptive PMR")
    plt.xlabel("Fault probability (%)")
    plt.ylabel("Detection rate (S11)")
    plt.title("Fault Detection Rate vs Fault Probability")
    plt.grid(True, alpha=0.3)
    plt.ylim(0, 1.05)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_dir / "detection_vs_fault_probability.png", dpi=180)
    plt.close()

    # 2) Reliability comparison across architectures
    plt.figure(figsize=(8, 5))
    plt.plot(p, get_series(rows, "s11_reliability_base"), marker="o", label="Single")
    plt.plot(p, get_series(rows, "s11_reliability_dmr"), marker="o", label="DMR")
    plt.plot(p, get_series(rows, "s11_reliability_tmr"), marker="o", label="Adaptive TMR")
    plt.plot(p, get_series(rows, "s11_reliability_adaptive"), marker="o", label="Adaptive PMR")
    plt.xlabel("Fault probability (%)")
    plt.ylabel("Reliability (S11)")
    plt.title("Reliability Comparison Across Architectures")
    plt.grid(True, alpha=0.3)
    plt.ylim(0, 1.05)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_dir / "reliability_comparison.png", dpi=180)
    plt.close()

    # 3) Fault masking vs fault probability
    plt.figure(figsize=(8, 5))
    plt.plot(p, get_series(rows, "s11_masking_base"), marker="o", label="Single")
    plt.plot(p, get_series(rows, "s11_masking_dmr"), marker="o", label="DMR")
    plt.plot(p, get_series(rows, "s11_masking_tmr"), marker="o", label="Adaptive TMR")
    plt.plot(p, get_series(rows, "s11_masking_adaptive"), marker="o", label="Adaptive PMR")
    plt.xlabel("Fault probability (%)")
    plt.ylabel("Masking rate (S11)")
    plt.title("Fault Masking Rate vs Fault Probability")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_dir / "masking_vs_fault_probability.png", dpi=180)
    plt.close()

    # 4) Hardware overhead vs reliability improvement
    overhead = read_lut_overheads(module_csv)
    p_ref = 50.0
    ref_row = min(rows, key=lambda r: abs(r.get("fault_prob_pct", 0.0) - p_ref))
    rel_single = ref_row.get("s11_reliability_base", 0.0)

    arch = ["Single", "DMR", "Adaptive TMR", "Adaptive PMR"]
    rel = [
        ref_row.get("s11_reliability_base", 0.0),
        ref_row.get("s11_reliability_dmr", 0.0),
        ref_row.get("s11_reliability_tmr", 0.0),
        ref_row.get("s11_reliability_adaptive", 0.0),
    ]
    rel_impr = [x - rel_single for x in rel]
    ovh = [
        overhead.get("single", 1.0),
        overhead.get("dmr", 1.0),
        overhead.get("tmr", 1.0),
        overhead.get("adaptive", 1.0),
    ]

    plt.figure(figsize=(8, 5))
    for i in range(len(arch)):
        plt.scatter(ovh[i], rel_impr[i], s=90)
        plt.text(ovh[i] + 0.02, rel_impr[i], arch[i], fontsize=9)
    plt.xlabel("LUT Overhead (x vs Single)")
    plt.ylabel(f"Reliability Improvement at p≈{ref_row.get('fault_prob_pct', p_ref):.0f} (%)")
    plt.title("Hardware Overhead vs Reliability Improvement")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(out_dir / "overhead_vs_reliability_improvement.png", dpi=180)
    plt.close()

    print(f"Wrote figures to: {out_dir}")


if __name__ == "__main__":
    main()

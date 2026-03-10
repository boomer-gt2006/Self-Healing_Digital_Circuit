#!/usr/bin/env python3
"""
compare_results.py
===================
Parses Vivado synthesis reports for the three designs:
  - Base ALU           (reports/alu/)
  - Traditional TMR    (reports/tmr/)
  - Adaptive           (reports/adaptive/)

Extracts:
  - LUT as Logic  (utilization report)
  - Total On-Chip Power (W)  (power report)
  - Worst Negative Slack / Minimum Period  (timing report)

Prints a formatted comparison table and saves comparison.csv.
"""

import os
import re
import csv

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

DESIGNS = {
    "Base ALU"           : os.path.join(SCRIPT_DIR, "reports", "alu"),
    "Traditional TMR"    : os.path.join(SCRIPT_DIR, "reports", "tmr"),
    "Adaptive Redundancy": os.path.join(SCRIPT_DIR, "reports", "adaptive"),
}

# ─────────────────────────────────────────────────────────────
# Parsing helpers
# ─────────────────────────────────────────────────────────────

def parse_utilization(rpt_path: str) -> dict:
    """Extract LUT, FF, DSP, BRAM counts from utilization report."""
    result = {"LUTs": "N/A", "FFs": "N/A", "DSPs": "N/A", "BRAMs": "N/A"}
    if not os.path.exists(rpt_path):
        return result

    with open(rpt_path, encoding="utf-8", errors="ignore") as f:
        text = f.read()

    # Pattern: | LUT as Logic        |   <num> |
    patterns = {
        "LUTs" : r"\|\s*LUT as Logic\s*\|\s*(\d+)\s*\|",
        "FFs"  : r"\|\s*(?:Slice\s+)?Registers?\s*\|\s*(\d+)\s*\|",
        "DSPs" : r"\|\s*DSPs\s*\|\s*(\d+)\s*\|",
        "BRAMs": r"\|\s*Block RAM Tile\s*\|\s*(\d+)\s*\|",
    }
    for key, pat in patterns.items():
        m = re.search(pat, text, re.IGNORECASE)
        if m:
            result[key] = int(m.group(1))
    return result


def parse_power(rpt_path: str) -> dict:
    """Extract total on-chip power from power report."""
    result = {"Total Power (W)": "N/A", "Dynamic (W)": "N/A", "Static (W)": "N/A"}
    if not os.path.exists(rpt_path):
        return result

    with open(rpt_path, encoding="utf-8", errors="ignore") as f:
        text = f.read()

    # Pattern: | Total On-Chip Power (W) |  0.123  |
    m = re.search(r"\|\s*Total On-Chip Power\s*\(W\)\s*\|\s*([\d.]+)\s*\|", text, re.IGNORECASE)
    if m:
        result["Total Power (W)"] = float(m.group(1))

    m = re.search(r"\|\s*Dynamic\s*\(W\)\s*\|\s*([\d.]+)\s*\|", text, re.IGNORECASE)
    if m:
        result["Dynamic (W)"] = float(m.group(1))

    m = re.search(r"\|\s*(?:Device\s+)?Static\s*\(W\)\s*\|\s*([\d.]+)\s*\|", text, re.IGNORECASE)
    if m:
        result["Static (W)"] = float(m.group(1))

    return result


def parse_timing(rpt_path: str) -> dict:
    """Extract WNS and minimum achievable clock period from timing summary."""
    result = {"WNS (ns)": "N/A", "Min Period (ns)": "N/A", "Max Freq (MHz)": "N/A"}
    if not os.path.exists(rpt_path):
        return result

    with open(rpt_path, encoding="utf-8", errors="ignore") as f:
        text = f.read()

    # WNS line:  WNS(ns)  TNS(ns)  ...
    #              -0.123   ...   (or "NA" / "-------" when no clocks are defined)
    m = re.search(r"WNS\(ns\).*?\n\s*[-]+.*?\n\s*([-\d.NA]+)", text, re.IGNORECASE | re.DOTALL)
    if m:
        val = m.group(1).strip()
        try:
            result["WNS (ns)"] = float(val)
        except ValueError:
            result["WNS (ns)"] = "N/A (no clocks)"

    # Data path delay — primary metric when no constraints are used;
    # take the largest (worst-case / longest path) value found
    delays = [float(x) for x in re.findall(r"Data Path Delay:\s*([\d.]+)\s*ns", text, re.IGNORECASE)]
    if delays:
        dp_delay = max(delays)
        result["Min Period (ns)"] = round(dp_delay, 3)
        result["Max Freq (MHz)"]  = round(1000.0 / dp_delay, 2) if dp_delay > 0 else "N/A"

    return result


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

def _print_table(title: str, rows: list, cols: list) -> None:
    """Print a pretty-formatted ASCII table."""
    col_widths = {c: max(len(c), max(len(str(r[c])) for r in rows)) for c in cols}
    sep = "+-" + "-+-".join("-" * col_widths[c] for c in cols) + "-+"
    hdr = "| " + " | ".join(c.ljust(col_widths[c]) for c in cols) + " |"
    print("\n" + "=" * len(sep))
    print(f"  {title}")
    print("=" * len(sep))
    print(sep)
    print(hdr)
    print(sep)
    for r in rows:
        print("| " + " | ".join(str(r[c]).ljust(col_widths[c]) for c in cols) + " |")
    print(sep)


def main():
    rows       = []   # synthesis (vectorless) results
    saif_rows  = []   # SAIF-annotated power results

    for design, rpt_dir in DESIGNS.items():
        util  = parse_utilization(os.path.join(rpt_dir, "utilization.rpt"))
        power = parse_power(os.path.join(rpt_dir, "power.rpt"))
        tim   = parse_timing(os.path.join(rpt_dir, "timing.rpt"))

        rows.append({
            "Design"           : design,
            "LUTs"             : util["LUTs"],
            "FFs"              : util["FFs"],
            "DSPs"             : util["DSPs"],
            "Total Power (W)"  : power["Total Power (W)"],
            "Dynamic (W)"      : power["Dynamic (W)"],
            "Static (W)"       : power["Static (W)"],
            "WNS (ns)"         : tim["WNS (ns)"],
            "Min Period (ns)"  : tim["Min Period (ns)"],
            "Max Freq (MHz)"   : tim["Max Freq (MHz)"],
        })

        # ── SAIF power (optional — only present after sim run) ─
        saif_rpt = os.path.join(rpt_dir, "power_saif.rpt")
        saif_pwr = parse_power(saif_rpt)
        saif_rows.append({
            "Design"                : design,
            "SAIF Total Power (W)"  : saif_pwr["Total Power (W)"],
            "SAIF Dynamic (W)"      : saif_pwr["Dynamic (W)"],
            "SAIF Static (W)"       : saif_pwr["Static (W)"],
            "Vectorless Total (W)"  : power["Total Power (W)"],
            "Vectorless Dynamic (W)": power["Dynamic (W)"],
        })

    # ── Table 1: full synthesis comparison ────────────────────
    synth_cols = list(rows[0].keys())
    _print_table("SYNTHESIS COMPARISON   (Zynq xc7z020clg400-1)", rows, synth_cols)

    # ── Table 2: SAIF vs vectorless power ─────────────────────
    saif_cols = list(saif_rows[0].keys())
    _print_table("SAIF vs VECTORLESS POWER COMPARISON", saif_rows, saif_cols)

    # Compute overhead/savings annotation
    print("\n  Power overhead (SAIF vs vectorless):")
    for r in saif_rows:
        vl = r["Vectorless Total (W)"]
        sa = r["SAIF Total Power (W)"]
        if isinstance(vl, (int, float)) and isinstance(sa, (int, float)):
            delta  = sa - vl
            pct    = (delta / vl * 100) if vl != 0 else 0.0
            sign   = "+" if delta >= 0 else ""
            print(f"    {r['Design']:<24}: {sign}{delta:.3f} W  ({sign}{pct:.1f}%)")
        else:
            print(f"    {r['Design']:<24}: SAIF report not yet available")

    # ── Save CSV ──────────────────────────────────────────────
    csv_path = os.path.join(SCRIPT_DIR, "reports", "comparison.csv")
    os.makedirs(os.path.dirname(csv_path), exist_ok=True)
    all_cols = list({k: None for r in rows for k in r} |
                    {k: None for r in saif_rows for k in r})
    merged = []
    for r, s in zip(rows, saif_rows):
        merged.append({**r, **{k: v for k, v in s.items() if k != "Design"}})
    with open(csv_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(merged[0].keys()))
        writer.writeheader()
        writer.writerows(merged)

    print(f"\n[INFO] Comparison table saved to: {csv_path}\n")


if __name__ == "__main__":
    main()

# VCD Power Rerun Summary (2026-03-14)

## Run Setup

- Simulation: fresh rerun of tb_accuracy
- Log: synth/reports/rerun_xsim.log
- VCD source: tb_accuracy.vcd
- Power estimator: synth/approx_power_from_vcd.py
- Estimator assumptions used for this rerun:
  - C_eff = 12.0 fF per tracked bit
  - V = 1.0 V
  - f = 100 MHz

## Architecture Power (Fresh Rerun)

Source CSV: synth/reports/vcd_power_estimate_rerun.csv

| Architecture | Power (mW) | Power (uW) | Relative to Single |
|---|---:|---:|---:|
| Single (baseline) | 0.039118492 | 39.118 | 1.000x |
| DMR | 0.080117153 | 80.117 | 2.048x |
| TMR | 0.115893144 | 115.893 | 2.963x |
| Adaptive | 0.202169330 | 202.169 | 5.168x |

## Accuracy Context (Same Rerun)

From synth/reports/rerun_xsim.log:

- S0 fault-free: Single 100.00%, DMR 100.00%, TMR 100.00%, Adaptive 100.00%
- GRAND TOTAL: Single 33.91%, DMR 33.91%, TMR 63.88%, Adaptive 84.22%

## Why This Differs From The Earlier ~106 uW Adaptive Number

- Earlier conversations used a different workload state and assumptions.
- The power estimator defaults to C_eff = 10 fF unless overridden; this rerun used 12 fF.
- Current testbench/scenario behavior in this workspace produces higher adaptive toggles than the older run basis.

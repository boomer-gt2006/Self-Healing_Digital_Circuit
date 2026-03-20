# Power Comparison Using Both Assumptions (2026-03-14)

VCD source: tb_accuracy.vcd (fresh rerun)

Common assumptions:
- V = 1.0 V
- f = 100 MHz

Compared capacitance assumptions:
- Assumption A: C_eff = 10.0 fF per tracked bit
- Assumption B: C_eff = 12.0 fF per tracked bit

Source files:
- synth/reports/vcd_power_estimate_rerun_cap10.csv
- synth/reports/vcd_power_estimate_rerun_cap12.csv

## Side-by-side Architecture Power

| Architecture | A (10 fF) mW | A (10 fF) uW | B (12 fF) mW | B (12 fF) uW |
|---|---:|---:|---:|---:|
| Single (baseline) | 0.032598743 | 32.599 | 0.039118492 | 39.118 |
| DMR | 0.066764294 | 66.764 | 0.080117153 | 80.117 |
| TMR | 0.096577620 | 96.578 | 0.115893144 | 115.893 |
| Adaptive | 0.168474442 | 168.474 | 0.202169330 | 202.169 |

## Notes

- Power scales linearly with C_eff in this model.
- Therefore B is exactly 1.2x A for all architectures.

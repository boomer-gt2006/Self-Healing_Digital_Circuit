# Risk Estimator Hyperparameter Tuning

Sweep objective: maximize Adaptive GRAND TOTAL accuracy while minimizing Adaptive estimated dynamic power (from VCD).

Tuning run settings: `TB_N_RANDOM=2000`, `TB_N_CORNER=200`, `TB_N_WARMUP=256`, `TB_N_BURST=500`.

## Ranked Results (score = 0.7*acc + 0.3*(1-power))

| Rank | Config | Window | Tmed | Thigh | Emed | Ehigh | Accuracy (%) | Power (mW) | Score |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | default | 64 | 10 | 30 | 2 | 4 | 84.24 | 0.201365 | 1.0000 |
| 2 | aggressive_a | 64 | 6 | 18 | 1 | 2 | 84.24 | 0.201365 | 1.0000 |
| 3 | balanced_a | 64 | 8 | 28 | 2 | 4 | 84.24 | 0.201365 | 1.0000 |
| 4 | balanced_b | 64 | 10 | 26 | 2 | 3 | 84.24 | 0.201365 | 1.0000 |
| 5 | error_sensitive | 64 | 12 | 36 | 1 | 2 | 84.24 | 0.201365 | 1.0000 |
| 6 | toggle_sensitive | 64 | 6 | 22 | 3 | 5 | 84.24 | 0.201365 | 1.0000 |
| 7 | conservative_a | 64 | 12 | 36 | 3 | 5 | 84.24 | 0.201365 | 1.0000 |
| 8 | conservative_b | 64 | 14 | 42 | 4 | 6 | 84.24 | 0.201365 | 1.0000 |
| 9 | very_conservative | 64 | 16 | 48 | 4 | 8 | 84.24 | 0.201366 | 0.9996 |
| 10 | aggressive_b | 64 | 8 | 24 | 1 | 3 | 84.22 | 0.202169 | 0.0000 |

## Pareto Front (non-dominated)

| Config | Accuracy (%) | Power (mW) | Thresholds (Tmed/Thigh, Emed/Ehigh) |
|---|---:|---:|---|
| default | 84.24 | 0.201365 | 10/30, 2/4 |
| aggressive_a | 84.24 | 0.201365 | 6/18, 1/2 |
| balanced_a | 84.24 | 0.201365 | 8/28, 2/4 |
| balanced_b | 84.24 | 0.201365 | 10/26, 2/3 |
| error_sensitive | 84.24 | 0.201365 | 12/36, 1/2 |
| toggle_sensitive | 84.24 | 0.201365 | 6/22, 3/5 |
| conservative_a | 84.24 | 0.201365 | 12/36, 3/5 |
| conservative_b | 84.24 | 0.201365 | 14/42, 4/6 |

## Recommendation

Recommended config: **default** with `TOGGLE_MED=10`, `TOGGLE_HIGH=30`, `ERROR_MED=2`, `ERROR_HIGH=4`.

Observed Adaptive metrics at this setting: **accuracy 84.24%**, **power 0.201365 mW**.

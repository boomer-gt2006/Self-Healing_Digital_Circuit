# Self-Healing Digital Circuit

Hybrid adaptive redundancy architecture for fault-tolerant digital computation using runtime risk estimation, modulo-3 residue checking, and configurable quarantine policy control.

## Overview

This project implements and evaluates three architecture classes:

- Static TMR baseline (fixed 3-way redundancy)
- Adaptive (no residue, no quarantine)
- Adaptive (+residue +quarantine), with runtime switching between:
  - Adaptive TMR mode
  - Adaptive PMR mode (5-module voting)

The adaptive flow increases fault coverage while reducing unnecessary redundancy in low-risk windows.

## Key Features

- Runtime risk estimator driven by switching activity and mismatch/error events
- Dynamic mode selection: Single / Adaptive TMR / Adaptive PMR
- Per-module modulo-3 residue checker for arithmetic fault localization
- Per-module quarantine FSM with configurable event fusion policies:
  - Policy 0: Residue-only
  - Policy 1: Voter-only
  - Policy 2: Fused-AND
  - Policy 3: Fused-OR
- Fault injection framework and multi-scenario accuracy sweeps (S0-S14)
- Monte Carlo sweep scripts and report-generation flow

## Repository Structure

```text
Self-Healing_Digital_Circuit/
  rtl/
    alu.v
    residue_checker.v
    risk_estimator.v
    redundancy_controller.v
    majority_voter.v
    penta_voter.v
    top_adaptive.v
    top_adaptive_no_residue.v
    top_tmr.v
    top_dmr.v
    ...
  testbench/
    tb_accuracy.v
    tb_accuracy_cfg.vh
    tb_accuracy_policy_0.v
    tb_accuracy_policy_1.v
    tb_accuracy_policy_2.v
    tb_accuracy_policy_3.v
    tb_accuracy_no_residue.v
    tb_accuracy_fused_or.v
    tb_residue_comparison.v
    ...
  sim/
    xsim_run_accuracy.tcl
    xsim_run_adaptive.tcl
    xsim_run_alu.tcl
    xsim_run_tmr.tcl
  synth/
    run_synthesis.bat
    synth_alu.tcl
    synth_tmr.tcl
    synth_adaptive.tcl
    synth_alu_array.tcl
    synth_alu_array_tmr.tcl
    monte_carlo_sweep.py
    power_estimation.py
    reports/
  docs/
    report.tex
    report.pdf
    run_accuracy_sim.bat
    run_residue_comparison.bat
```

## Quick Start (Windows + Vivado)

1. Ensure Vivado tools (`xvlog`, `xelab`, `xsim`) are in `PATH`.
2. Run scenario accuracy simulation:

```bat
cd docs
run_accuracy_sim.bat
```

3. Build synthesis reports:

```bat
cd synth
run_synthesis.bat
```

4. Compile the paper/report:

```bat
cd docs
pdflatex -interaction=nonstopmode report.tex
pdflatex -interaction=nonstopmode report.tex
```

## Policy Evaluation

Use policy-specific testbenches in `testbench/` to compare quarantine strategies:

- `tb_accuracy_policy_0.v` (Residue-only)
- `tb_accuracy_policy_1.v` (Voter-only)
- `tb_accuracy_policy_2.v` (Fused-AND)
- `tb_accuracy_policy_3.v` (Fused-OR)

Current sweeps indicate policy 1/2/3 tie for best grand-total accuracy in S0-S14 evaluation, while residue-only is lower in mixed-operation scenarios.

## Selected Results (from current report)

- Static TMR grand-total accuracy: 65.34%
- Adaptive (+residue +quarantine) grand-total accuracy (best policy): 85.83%
- Scenario S11 accuracy for adaptive (+R+Q, best policy): 87.40%

See `docs/report.pdf` and `synth/reports/` for detailed tables, Monte Carlo outputs, and power summaries.

## Notes

- Generated simulator artifacts (`*.wdb`, `*.vcd`, `xsim.dir/`, logs) are git-ignored.
- If a simulator file is locked (for example, `xsim.jou`), close Vivado/XSim processes before cleanup.

## License

This repository currently has no explicit license file. Add a `LICENSE` file if redistribution terms are required.

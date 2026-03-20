@echo off
:: ============================================================
:: run_accuracy_sim.bat
:: Compiles and simulates tb_accuracy using Vivado xvlog/xelab/xsim.
::
:: Usage:
::   Run from the project root directory:
::     docs\run_accuracy_sim.bat
::   Or double-click from Windows Explorer.
::
:: Output:
::   Accuracy results printed to the console.
::   accuracy_sim.log  — full simulator log saved in project root.
:: ============================================================

:: --- Change to project root (one level up from this script) ---
cd /d "%~dp0.."

echo ==============================================================
echo  Self-Healing Digital Circuit -- Accuracy Simulation
echo ==============================================================
echo.

:: ---- Step 1: Compile all RTL sources ----
echo [1/3] Compiling RTL sources...
xvlog ^
  rtl/alu.v ^
  rtl/fault_injector.v ^
  rtl/majority_voter.v ^
  rtl/penta_voter.v ^
  rtl/residue_checker.v ^
  rtl/risk_estimator.v ^
  rtl/redundancy_controller.v ^
  rtl/top_dmr.v ^
  rtl/top_tmr.v ^
  rtl/top_adaptive.v ^
  > accuracy_compile.log 2>&1

if %ERRORLEVEL% neq 0 (
    echo [ERROR] RTL compilation failed. See accuracy_compile.log.
    pause
    exit /b 1
)
echo        RTL compilation OK.

:: ---- Step 2: Compile testbench ----
echo [2/3] Compiling testbench...
xvlog ^
  testbench/tb_accuracy.v ^
  >> accuracy_compile.log 2>&1

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Testbench compilation failed. See accuracy_compile.log.
    pause
    exit /b 1
)
echo        Testbench compilation OK.

:: ---- Step 3: Elaborate ----
echo [3/3] Elaborating...
xelab tb_accuracy ^
  --timescale 1ns/1ps ^
  --snapshot tb_accuracy_snap ^
  >> accuracy_compile.log 2>&1

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Elaboration failed. See accuracy_compile.log.
    pause
    exit /b 1
)
echo        Elaboration OK.

:: ---- Step 4: Simulate ----
echo.
echo Running simulation (this may take a minute)...
echo.
xsim tb_accuracy_snap ^
  --nolog ^
  --tclbatch sim/xsim_run_accuracy.tcl ^
  2>&1 | tee accuracy_sim.log

echo.
echo ==============================================================
echo  Simulation complete. Full log saved to accuracy_sim.log
echo ==============================================================
pause

@echo off
:: ============================================================
:: run_residue_comparison.bat
:: Compiles and simulates tb_residue_comparison to compare
:: adaptive architectures with and without residue-based 
:: fault localization.
::
:: Usage:
::   Run from the project root directory:
::     docs\run_residue_comparison.bat
::   Or double-click from Windows Explorer.
::
:: Output:
::   Residue impact analysis printed to the console.
::   residue_comparison.log  — full simulator log saved in project root.
:: ============================================================

:: --- Change to project root (one level up from this script) ---
cd /d "%~dp0.."

:: ---- Setup Vivado environment ----
call "C:\Xilinx\2025.1\settings64.bat" 2>nul
if %ERRORLEVEL% neq 0 (
    echo [INFO] Running without explicit Vivado settings. Attempting with PATH...
)

echo ==============================================================
echo  Residue-Based Fault Localization Impact Analysis
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
  rtl/top_adaptive_no_residue.v ^
  > residue_compile.log 2>&1

if %ERRORLEVEL% neq 0 (
    echo [ERROR] RTL compilation failed. See residue_compile.log.
    pause
    exit /b 1
)
echo        RTL compilation OK.

:: ---- Step 2: Compile testbench ----
echo [2/3] Compiling testbench...
xvlog ^
  testbench/tb_residue_comparison.v ^
  >> residue_compile.log 2>&1

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Testbench compilation failed. See residue_compile.log.
    pause
    exit /b 1
)
echo        Testbench compilation OK.

:: ---- Step 3: Elaborate and simulate ----
echo [3/3] Running simulation...
xelab -debug all tb_residue_comparison >> residue_compile.log 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Elaboration failed. See residue_compile.log.
    pause
    exit /b 1
)

xsim tb_residue_comparison -runall >> residue_sim.log 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Simulation may have finished with non-zero exit code (OK if no errors logged).
)

echo        Simulation complete.
echo.

:: ---- Step 4: Display results ----
echo [RESULTS] Printing simulation output...
echo.
more residue_sim.log

echo ==============================================================
echo  Simulation log saved to: residue_sim.log
echo ==============================================================
pause

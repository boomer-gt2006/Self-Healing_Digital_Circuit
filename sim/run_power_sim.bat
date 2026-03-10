@echo off
:: ============================================================
:: run_power_sim.bat
:: Master pipeline: Synthesis -> XSim SAIF simulation -> Power analysis
::
:: Prerequisites:
::   * Vivado (including xvlog/xelab/xsim) on PATH  -OR-  
::     set XILINX_VIVADO to your Vivado install root
::   * Python 3 on PATH
::
:: Run from the project root:
::   cd C:\Users\gt111\Desktop\Self-Healing_Digital_Circuit
::   sim\run_power_sim.bat
:: ============================================================

setlocal EnableDelayedExpansion

:: ── Resolve project root (parent of this script's directory) ─
set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%.."
set "ROOT_DIR=%CD%"
popd

echo.
echo ============================================================
echo  Self-Healing Digital Circuit  --  SAIF Power Pipeline
echo  Root : %ROOT_DIR%
echo ============================================================
echo.

:: ── Optional: add Vivado to PATH if XILINX_VIVADO is set ─────
if defined XILINX_VIVADO (
    set "PATH=%XILINX_VIVADO%\bin;%PATH%"
    echo [INFO] Using Vivado at: %XILINX_VIVADO%\bin
)

:: ── Verify vivado is reachable ────────────────────────────────
where vivado >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 'vivado' not found on PATH.
    echo         Set XILINX_VIVADO or add Vivado\bin to PATH.
    exit /b 1
)

:: ── Create report output directories (SAIF needs them upfront) ─
mkdir "%ROOT_DIR%\synth\reports\alu"      2>nul
mkdir "%ROOT_DIR%\synth\reports\tmr"      2>nul
mkdir "%ROOT_DIR%\synth\reports\adaptive" 2>nul

:: ── Temporary XSim work directory (inside project root) ───────
set "XSIM_DIR=%ROOT_DIR%\xsim_work"
mkdir "%XSIM_DIR%" 2>nul

:: ============================================================
:: STEP 1 — Synthesis (generates synth.dcp checkpoints)
:: ============================================================
echo.
echo [STEP 1/4] Running Vivado synthesis ...
echo.

echo   --- ALU synthesis ---
vivado -mode batch -source "%ROOT_DIR%\synth\synth_alu.tcl" ^
       -log "%ROOT_DIR%\synth\reports\alu\vivado_synth.log" ^
       -nojournal
if errorlevel 1 ( echo [ERROR] ALU synthesis failed. & exit /b 1 )

echo   --- TMR synthesis ---
vivado -mode batch -source "%ROOT_DIR%\synth\synth_tmr.tcl" ^
       -log "%ROOT_DIR%\synth\reports\tmr\vivado_synth.log" ^
       -nojournal
if errorlevel 1 ( echo [ERROR] TMR synthesis failed. & exit /b 1 )

echo   --- Adaptive synthesis ---
vivado -mode batch -source "%ROOT_DIR%\synth\synth_adaptive.tcl" ^
       -log "%ROOT_DIR%\synth\reports\adaptive\vivado_synth.log" ^
       -nojournal
if errorlevel 1 ( echo [ERROR] Adaptive synthesis failed. & exit /b 1 )

echo.
echo [STEP 1/4] Synthesis COMPLETE.

:: ============================================================
:: STEP 2 — XSim Simulation (generates .saif files)
:: All XSim commands run from project root so relative SAIF
:: paths in xsim_run_*.tcl resolve correctly.
:: ============================================================
echo.
echo [STEP 2/4] Running XSim simulations to generate SAIF files ...
echo.

cd /D "%ROOT_DIR%"

:: ──────────────────────────────────────────────────────────
:: 2a) Base ALU
:: ──────────────────────────────────────────────────────────
echo   --- Simulating ALU (tb_power_alu) ---

xvlog -v 0 --work work_alu ^
    rtl\alu.v ^
    testbench\tb_power_alu.v
if errorlevel 1 ( echo [ERROR] xvlog failed for ALU. & exit /b 1 )

xelab -v 0 --debug all ^
    --work work_alu ^
    --snapshot tb_power_alu_snap ^
    tb_power_alu
if errorlevel 1 ( echo [ERROR] xelab failed for ALU. & exit /b 1 )

xsim tb_power_alu_snap -tclbatch sim\xsim_run_alu.tcl
if errorlevel 1 ( echo [ERROR] xsim failed for ALU. & exit /b 1 )

:: ──────────────────────────────────────────────────────────
:: 2b) Traditional TMR
:: ──────────────────────────────────────────────────────────
echo.
echo   --- Simulating TMR (tb_power_tmr) ---

xvlog -v 0 --work work_tmr ^
    rtl\alu.v ^
    rtl\fault_injector.v ^
    rtl\majority_voter.v ^
    rtl\top_tmr.v ^
    testbench\tb_power_tmr.v
if errorlevel 1 ( echo [ERROR] xvlog failed for TMR. & exit /b 1 )

xelab -v 0 --debug all ^
    --work work_tmr ^
    --snapshot tb_power_tmr_snap ^
    tb_power_tmr
if errorlevel 1 ( echo [ERROR] xelab failed for TMR. & exit /b 1 )

xsim tb_power_tmr_snap -tclbatch sim\xsim_run_tmr.tcl
if errorlevel 1 ( echo [ERROR] xsim failed for TMR. & exit /b 1 )

:: ──────────────────────────────────────────────────────────
:: 2c) Adaptive Redundancy
:: ──────────────────────────────────────────────────────────
echo.
echo   --- Simulating Adaptive (tb_power_adaptive) ---

xvlog -v 0 --work work_adaptive ^
    rtl\alu.v ^
    rtl\fault_injector.v ^
    rtl\majority_voter.v ^
    rtl\risk_estimator.v ^
    rtl\redundancy_controller.v ^
    rtl\top_adaptive.v ^
    testbench\tb_power_adaptive.v
if errorlevel 1 ( echo [ERROR] xvlog failed for Adaptive. & exit /b 1 )

xelab -v 0 --debug all ^
    --work work_adaptive ^
    --snapshot tb_power_adaptive_snap ^
    tb_power_adaptive
if errorlevel 1 ( echo [ERROR] xelab failed for Adaptive. & exit /b 1 )

xsim tb_power_adaptive_snap -tclbatch sim\xsim_run_adaptive.tcl
if errorlevel 1 ( echo [ERROR] xsim failed for Adaptive. & exit /b 1 )

echo.
echo [STEP 2/4] XSim simulations COMPLETE.

:: ============================================================
:: STEP 3 — Vivado Power Analysis with SAIF annotation
:: ============================================================
echo.
echo [STEP 3/4] Running SAIF-annotated Vivado power analysis ...
echo.

echo   --- ALU power analysis ---
vivado -mode batch -source "%ROOT_DIR%\sim\power_alu.tcl" ^
       -log "%ROOT_DIR%\synth\reports\alu\vivado_power.log" ^
       -nojournal
if errorlevel 1 ( echo [ERROR] ALU power analysis failed. & exit /b 1 )

echo   --- TMR power analysis ---
vivado -mode batch -source "%ROOT_DIR%\sim\power_tmr.tcl" ^
       -log "%ROOT_DIR%\synth\reports\tmr\vivado_power.log" ^
       -nojournal
if errorlevel 1 ( echo [ERROR] TMR power analysis failed. & exit /b 1 )

echo   --- Adaptive power analysis ---
vivado -mode batch -source "%ROOT_DIR%\sim\power_adaptive.tcl" ^
       -log "%ROOT_DIR%\synth\reports\adaptive\vivado_power.log" ^
       -nojournal
if errorlevel 1 ( echo [ERROR] Adaptive power analysis failed. & exit /b 1 )

echo.
echo [STEP 3/4] Vivado power analysis COMPLETE.

:: ============================================================
:: STEP 4 — Generate comparison table
:: ============================================================
echo.
echo [STEP 4/4] Generating comparison tables ...
echo.

python "%ROOT_DIR%\synth\compare_results.py"
if errorlevel 1 ( echo [WARN] compare_results.py exited with errors. )

:: ── Clean up XSim intermediate files (optional) ─────────────
echo.
echo [INFO] Cleaning up XSim work libraries ...
if exist "%ROOT_DIR%\work_alu"      rmdir /s /q "%ROOT_DIR%\work_alu"
if exist "%ROOT_DIR%\work_tmr"      rmdir /s /q "%ROOT_DIR%\work_tmr"
if exist "%ROOT_DIR%\work_adaptive" rmdir /s /q "%ROOT_DIR%\work_adaptive"
if exist "%ROOT_DIR%\xsim.dir"      rmdir /s /q "%ROOT_DIR%\xsim.dir"

echo.
echo ============================================================
echo  SAIF Power Pipeline COMPLETE
echo  Reports in: synth\reports\{alu,tmr,adaptive}\power_saif.rpt
echo  Summary  : synth\reports\comparison.csv
echo ============================================================
echo.

endlocal

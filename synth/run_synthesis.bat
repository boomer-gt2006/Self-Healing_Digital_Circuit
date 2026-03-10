@echo off
:: ============================================================
:: run_synthesis.bat
:: Runs Vivado synthesis for all three designs in batch mode.
::
:: Prerequisites:
::   Vivado must be on your PATH, or set VIVADO_BIN below.
::
::   To add Vivado to PATH temporarily, run before this script:
::     set PATH=C:\Xilinx\Vivado\2023.2\bin;%PATH%
::
:: Usage:
::   cd synth
::   run_synthesis.bat
:: ============================================================

:: ---- Vivado installation path --------------------------------
set VIVADO_BIN=C:\Xilinx\2025.1\Vivado\bin
set PATH=%VIVADO_BIN%;%PATH%

:: ---- Script directory ---------------------------------------
set SCRIPT_DIR=%~dp0

echo ============================================================
echo  Self-Healing Digital Circuit  ^|  Vivado Batch Synthesis
echo  Target FPGA : xc7z020clg400-1 (Zynq)
echo ============================================================
echo.

:: ---- Pre-create report directories so Vivado can write logs -
mkdir "%SCRIPT_DIR%reports\alu"      2>nul
mkdir "%SCRIPT_DIR%reports\tmr"      2>nul
mkdir "%SCRIPT_DIR%reports\adaptive" 2>nul
:: ---- 1) Base ALU --------------------------------------------
echo [1/3] Synthesizing Base ALU ...
vivado -mode batch -source "%SCRIPT_DIR%synth_alu.tcl" -log "%SCRIPT_DIR%reports\alu\vivado.log" -journal "%SCRIPT_DIR%reports\alu\vivado.jou"
if errorlevel 1 (
    echo [ERROR] ALU synthesis failed. Check reports\alu\vivado.log
    exit /b 1
)
echo [1/3] ALU synthesis DONE.
echo.

:: ---- 2) Traditional TMR -------------------------------------
echo [2/3] Synthesizing Traditional TMR ...
vivado -mode batch -source "%SCRIPT_DIR%synth_tmr.tcl" -log "%SCRIPT_DIR%reports\tmr\vivado.log" -journal "%SCRIPT_DIR%reports\tmr\vivado.jou"
if errorlevel 1 (
    echo [ERROR] TMR synthesis failed. Check reports\tmr\vivado.log
    exit /b 1
)
echo [2/3] TMR synthesis DONE.
echo.

:: ---- 3) Adaptive Redundancy ---------------------------------
echo [3/3] Synthesizing Adaptive Redundancy ...
vivado -mode batch -source "%SCRIPT_DIR%synth_adaptive.tcl" -log "%SCRIPT_DIR%reports\adaptive\vivado.log" -journal "%SCRIPT_DIR%reports\adaptive\vivado.jou"
if errorlevel 1 (
    echo [ERROR] Adaptive synthesis failed. Check reports\adaptive\vivado.log
    exit /b 1
)
echo [3/3] Adaptive synthesis DONE.
echo.

:: ---- Compare results ----------------------------------------
echo ============================================================
echo  Running results comparison...
echo ============================================================
python "%SCRIPT_DIR%compare_results.py"

echo.
echo All done! Reports are in:
echo   %SCRIPT_DIR%reports\alu\
echo   %SCRIPT_DIR%reports\tmr\
echo   %SCRIPT_DIR%reports\adaptive\
pause

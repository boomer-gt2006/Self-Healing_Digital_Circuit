@echo off
setlocal enabledelayedexpansion
:: ============================================================
:: compile.bat — LaTeX build script for report.tex
:: Run this from the docs\ folder or double-click it.
:: ============================================================

cd /d "%~dp0"

echo [1/2] First pdflatex pass...
pdflatex -interaction=nonstopmode report.tex >nul 2>&1

echo [2/2] Second pass (resolves cross-references and citations)...
pdflatex -interaction=nonstopmode report.tex >nul 2>&1

:: Clean up auxiliary files
del /q report.aux report.log report.out report.toc report.lof report.lot 2>nul

echo.
if exist report.pdf (
  echo SUCCESS: report.pdf generated
  echo.
  dir /b report.pdf
) else (
  echo ERROR: report.pdf not found
  exit /b 1
)
echo.
pause
echo.

:: Open the PDF automatically
start "" report.pdf

pause

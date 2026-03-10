@echo off
:: ============================================================
:: compile.bat — LaTeX build script for report.tex
:: Run this from the docs\ folder or double-click it.
:: ============================================================

cd /d "%~dp0"

echo [1/2] First pdflatex pass...
pdflatex -interaction=nonstopmode report.tex > compile.log 2>&1

echo [2/2] Second pass (resolves cross-references and citations)...
pdflatex -interaction=nonstopmode report.tex >> compile.log 2>&1

:: Clean up auxiliary files
del /q report.aux report.log report.out report.toc report.lof report.lot 2>nul

echo.
echo Done! Output: report.pdf
echo Full log saved to: compile.log
echo.

:: Open the PDF automatically
start "" report.pdf

pause

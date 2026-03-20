$ErrorActionPreference = "Stop"

$root = "C:/Users/gt111/Desktop/Self-Healing_Digital_Circuit"
Set-Location $root

$vivadoBin = "C:/Xilinx/2025.1/Vivado/bin"
$xvlog = Join-Path $vivadoBin "xvlog.bat"
$xelab = Join-Path $vivadoBin "xelab.bat"
$xsim = Join-Path $vivadoBin "xsim.bat"
$python = "c:/Users/gt111/Desktop/Self-Healing_Digital_Circuit/.venv/Scripts/python.exe"

$adpCfgPath = "rtl/adaptive_risk_cfg.vh"
$tbCfgPath = "testbench/tb_accuracy_cfg.vh"
$outDir = "synth/reports/tuning_manual"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$configs = @(
    @{ name = "default";          window = 64; tmed = 10; thigh = 30; emed = 2; ehigh = 4 },
    @{ name = "aggressive";       window = 64; tmed = 6;  thigh = 18; emed = 1; ehigh = 2 },
    @{ name = "semi_aggressive";  window = 64; tmed = 8;  thigh = 24; emed = 1; ehigh = 3 },
    @{ name = "balanced";         window = 64; tmed = 10; thigh = 26; emed = 2; ehigh = 3 },
    @{ name = "semi_conservative";window = 64; tmed = 12; thigh = 36; emed = 3; ehigh = 5 },
    @{ name = "conservative";     window = 64; tmed = 14; thigh = 42; emed = 4; ehigh = 6 }
)

$results = @()

foreach ($cfg in $configs) {
    Write-Host "Running config: $($cfg.name)"

    @(
        '`define ADP_WINDOW_CYCLES ' + $cfg.window,
        '`define ADP_TOGGLE_MED ' + $cfg.tmed,
        '`define ADP_TOGGLE_HIGH ' + $cfg.thigh,
        '`define ADP_ERROR_MED ' + $cfg.emed,
        '`define ADP_ERROR_HIGH ' + $cfg.ehigh
    ) | Set-Content -Path $adpCfgPath -Encoding ascii

    @(
        '`define TB_CLK_HALF 5',
        '`define TB_N_RANDOM 2000',
        '`define TB_N_CORNER 200',
        '`define TB_N_WARMUP 256',
        '`define TB_N_BURST 500',
        '`define TB_SEED 32''hDEAD_BEEF'
    ) | Set-Content -Path $tbCfgPath -Encoding ascii

    $snap = "tb_accuracy_tune_$($cfg.name)"
    $xvlogLog = Join-Path $outDir "$($cfg.name)_xvlog.log"
    $xelabLog = Join-Path $outDir "$($cfg.name)_xelab.log"
    $xsimLog = Join-Path $outDir "$($cfg.name)_xsim.log"

    & $xvlog --sv rtl/alu.v rtl/fault_injector.v rtl/majority_voter.v rtl/penta_voter.v rtl/residue_checker.v rtl/risk_estimator.v rtl/redundancy_controller.v rtl/top_dmr.v rtl/top_tmr.v rtl/top_adaptive.v testbench/tb_accuracy.v *> $xvlogLog
    if ($LASTEXITCODE -ne 0) {
        $results += [PSCustomObject]@{ config = $cfg.name; window = $cfg.window; toggle_med = $cfg.tmed; toggle_high = $cfg.thigh; error_med = $cfg.emed; error_high = $cfg.ehigh; adaptive_accuracy_pct = ""; adaptive_power_mw = ""; status = "xvlog_failed" }
        continue
    }

    & $xelab tb_accuracy -s $snap *> $xelabLog
    if ($LASTEXITCODE -ne 0) {
        $results += [PSCustomObject]@{ config = $cfg.name; window = $cfg.window; toggle_med = $cfg.tmed; toggle_high = $cfg.thigh; error_med = $cfg.emed; error_high = $cfg.ehigh; adaptive_accuracy_pct = ""; adaptive_power_mw = ""; status = "xelab_failed" }
        continue
    }

    & $xsim $snap -R *> $xsimLog
    if ($LASTEXITCODE -ne 0) {
        $results += [PSCustomObject]@{ config = $cfg.name; window = $cfg.window; toggle_med = $cfg.tmed; toggle_high = $cfg.thigh; error_med = $cfg.emed; error_high = $cfg.ehigh; adaptive_accuracy_pct = ""; adaptive_power_mw = ""; status = "xsim_failed" }
        continue
    }

    $grandLine = Select-String -Path $xsimLog -Pattern "GRAND TOTAL \(all scenarios combined\)" | Select-Object -Last 1
    if (-not $grandLine) {
        $results += [PSCustomObject]@{ config = $cfg.name; window = $cfg.window; toggle_med = $cfg.tmed; toggle_high = $cfg.thigh; error_med = $cfg.emed; error_high = $cfg.ehigh; adaptive_accuracy_pct = ""; adaptive_power_mw = ""; status = "parse_accuracy_failed" }
        continue
    }

    $pctMatches = [regex]::Matches($grandLine.Line, "([0-9]+\.[0-9]+)%")
    if ($pctMatches.Count -lt 4) {
        $results += [PSCustomObject]@{ config = $cfg.name; window = $cfg.window; toggle_med = $cfg.tmed; toggle_high = $cfg.thigh; error_med = $cfg.emed; error_high = $cfg.ehigh; adaptive_accuracy_pct = ""; adaptive_power_mw = ""; status = "parse_accuracy_failed" }
        continue
    }
    $adaptiveAcc = [double]$pctMatches[3].Groups[1].Value

    $powerCsv = Join-Path $outDir "$($cfg.name)_power.csv"
    $powerScenCsv = Join-Path $outDir "$($cfg.name)_power_by_scenario.csv"
    $powerLog = Join-Path $outDir "$($cfg.name)_power_tool.log"

    & $python synth/approx_power_from_vcd.py --vcd tb_accuracy.vcd --cap-ff 12.0 --voltage 1.0 --freq-hz 100e6 --csv $powerCsv --scenario-csv $powerScenCsv *> $powerLog
    if ($LASTEXITCODE -ne 0) {
        $results += [PSCustomObject]@{ config = $cfg.name; window = $cfg.window; toggle_med = $cfg.tmed; toggle_high = $cfg.thigh; error_med = $cfg.emed; error_high = $cfg.ehigh; adaptive_accuracy_pct = $adaptiveAcc; adaptive_power_mw = ""; status = "power_failed" }
        continue
    }

    $adaptiveRow = Import-Csv -Path $powerCsv | Where-Object { $_.architecture -eq "adaptive" }
    if (-not $adaptiveRow) {
        $results += [PSCustomObject]@{ config = $cfg.name; window = $cfg.window; toggle_med = $cfg.tmed; toggle_high = $cfg.thigh; error_med = $cfg.emed; error_high = $cfg.ehigh; adaptive_accuracy_pct = $adaptiveAcc; adaptive_power_mw = ""; status = "parse_power_failed" }
        continue
    }

    $adaptivePower = [double]$adaptiveRow.est_power_mw

    $results += [PSCustomObject]@{
        config = $cfg.name
        window = $cfg.window
        toggle_med = $cfg.tmed
        toggle_high = $cfg.thigh
        error_med = $cfg.emed
        error_high = $cfg.ehigh
        adaptive_accuracy_pct = [math]::Round($adaptiveAcc, 3)
        adaptive_power_mw = [math]::Round($adaptivePower, 9)
        status = "ok"
    }
}

# Restore defaults
@(
    '`define ADP_WINDOW_CYCLES 64',
    '`define ADP_TOGGLE_MED 10',
    '`define ADP_TOGGLE_HIGH 30',
    '`define ADP_ERROR_MED 2',
    '`define ADP_ERROR_HIGH 4'
) | Set-Content -Path $adpCfgPath -Encoding ascii

@(
    '`define TB_CLK_HALF 5',
    '`define TB_N_RANDOM 10000',
    '`define TB_N_CORNER 500',
    '`define TB_N_WARMUP 512',
    '`define TB_N_BURST 1000',
    '`define TB_SEED 32''hDEAD_BEEF'
) | Set-Content -Path $tbCfgPath -Encoding ascii

$outCsv = Join-Path $outDir "risk_tuning_results.csv"
$results | Export-Csv -Path $outCsv -NoTypeInformation

$ok = $results | Where-Object { $_.status -eq "ok" }
if ($ok.Count -gt 0) {
    $bestAcc = $ok | Sort-Object -Property @(
        @{ Expression = "adaptive_accuracy_pct"; Descending = $true },
        @{ Expression = "adaptive_power_mw"; Descending = $false }
    ) | Select-Object -First 1
    $bestPow = $ok | Sort-Object -Property @(
        @{ Expression = "adaptive_power_mw"; Descending = $false },
        @{ Expression = "adaptive_accuracy_pct"; Descending = $true }
    ) | Select-Object -First 1

    Write-Host "\nCompleted sweep."
    Write-Host "Best accuracy config: $($bestAcc.config) => acc=$($bestAcc.adaptive_accuracy_pct)% power=$($bestAcc.adaptive_power_mw) mW"
    Write-Host "Best power config:    $($bestPow.config) => acc=$($bestPow.adaptive_accuracy_pct)% power=$($bestPow.adaptive_power_mw) mW"
    Write-Host "Results CSV: $outCsv"
} else {
    Write-Host "No successful points. See logs in $outDir"
}

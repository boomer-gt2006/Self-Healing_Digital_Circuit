# ============================================================
# power_adaptive.tcl
# Vivado power analysis with SAIF annotation — Adaptive Design
#
# Prerequisites:
#   1. synth_adaptive.tcl must have run and written synth.dcp
#   2. tb_power_adaptive XSim simulation must have completed
#      and written reports/adaptive/sim.saif
#
# Usage (from project root, Vivado on PATH):
#   vivado -mode batch -source sim/power_adaptive.tcl
# ============================================================

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set ROOT_DIR   [file normalize [file join $SCRIPT_DIR ..]]
set DCP        [file join $ROOT_DIR synth reports adaptive synth.dcp]
set SAIF       [file join $ROOT_DIR synth reports adaptive sim_impl.saif]
set OUT_DIR    [file join $ROOT_DIR synth reports adaptive]

puts "\n\[INFO\] === Adaptive SAIF-Annotated Power Analysis ==="
puts "\[INFO\] Loading checkpoint : $DCP"

open_checkpoint $DCP

# 100 MHz clock constraint
create_clock -period 10.000 -name clk [get_ports clk]

puts "\[INFO\] Reading SAIF file : $SAIF"
if {[file exists $SAIF]} {
    read_saif $SAIF -strip_path tb_power_adaptive/uut
    puts "\[INFO\] SAIF loaded successfully"
} else {
    puts "\[WARN\] SAIF file not found — falling back to vectorless estimation"
}

report_power \
    -file [file join $OUT_DIR power_saif.rpt] \
    -name adaptive_saif_power

puts "\[INFO\] Adaptive SAIF power report written to: [file join $OUT_DIR power_saif.rpt]"
puts "\[INFO\] === Adaptive Power Analysis COMPLETE ===\n"

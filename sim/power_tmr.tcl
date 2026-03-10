# ============================================================
# power_tmr.tcl
# Vivado power analysis with SAIF annotation — Traditional TMR
#
# Prerequisites:
#   1. synth_tmr.tcl must have run and written synth.dcp
#   2. tb_power_tmr XSim simulation must have completed
#      and written reports/tmr/sim.saif
#
# Usage (from project root, Vivado on PATH):
#   vivado -mode batch -source sim/power_tmr.tcl
# ============================================================

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set ROOT_DIR   [file normalize [file join $SCRIPT_DIR ..]]
set DCP        [file join $ROOT_DIR synth reports tmr impl.dcp]
set SAIF       [file join $ROOT_DIR synth reports tmr sim_impl.saif]
set OUT_DIR    [file join $ROOT_DIR synth reports tmr]

puts "\n\[INFO\] === TMR SAIF-Annotated Power Analysis ==="
puts "\[INFO\] Loading checkpoint : $DCP"

open_checkpoint $DCP

# 100 MHz clock constraint
create_clock -period 10.000 -name clk [get_ports clk]

puts "\[INFO\] Reading SAIF file : $SAIF"
if {[file exists $SAIF]} {
    read_saif $SAIF -strip_path tb_power_tmr/uut
    puts "\[INFO\] SAIF loaded successfully"
} else {
    puts "\[WARN\] SAIF file not found — falling back to vectorless estimation"
}

report_power \
    -file [file join $OUT_DIR power_saif.rpt] \
    -name tmr_saif_power

puts "\[INFO\] TMR SAIF power report written to: [file join $OUT_DIR power_saif.rpt]"
puts "\[INFO\] === TMR Power Analysis COMPLETE ===\n"

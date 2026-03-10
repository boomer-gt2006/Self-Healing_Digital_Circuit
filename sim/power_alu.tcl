# ============================================================
# power_alu.tcl
# Vivado power analysis with SAIF annotation — Base ALU
#
# Prerequisites:
#   1. synth_alu.tcl must have run and written synth.dcp
#   2. tb_power_alu XSim simulation must have completed
#      and written reports/alu/sim.saif
#
# Usage (from project root, Vivado on PATH):
#   vivado -mode batch -source sim/power_alu.tcl
# ============================================================

set PART       "xc7z020clg400-1"
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set ROOT_DIR   [file normalize [file join $SCRIPT_DIR ..]]
set DCP        [file join $ROOT_DIR synth reports alu impl.dcp]
set SAIF       [file join $ROOT_DIR synth reports alu sim_impl.saif]
set OUT_DIR    [file join $ROOT_DIR synth reports alu]

puts "\n\[INFO\] === ALU SAIF-Annotated Power Analysis ==="
puts "\[INFO\] Loading checkpoint : $DCP"

# ---- Load synthesised netlist --------------------------------
open_checkpoint $DCP

# ---- Define clock constraint --------------------------------
# 100 MHz = 10 ns period on the clk port
create_clock -period 10.000 -name clk [get_ports clk]

# ---- Read SAIF activity data --------------------------------
# instance_name maps the SAIF hierarchy root to the design top.
# The SAIF was recorded from /tb_power_alu/uut/* so the
# prefix to strip is "tb_power_alu/uut".
puts "\[INFO\] Reading SAIF file : $SAIF"
if {[file exists $SAIF]} {
    read_saif $SAIF -strip_path tb_power_alu/uut -verbose
    puts "\[INFO\] SAIF loaded successfully"
} else {
    puts "\[WARN\] SAIF file not found — falling back to vectorless estimation"
}

# ---- Report power with SAIF annotation ----------------------
puts "\[INFO\] Running report_power..."
report_power \
    -file [file join $OUT_DIR power_saif.rpt] \
    -name alu_saif_power

puts "\[INFO\] ALU SAIF power report written to: [file join $OUT_DIR power_saif.rpt]"
puts "\[INFO\] === ALU Power Analysis COMPLETE ===\n"

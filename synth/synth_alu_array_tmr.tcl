# ============================================================
# synth_alu_array_tmr.tcl
# Vivado Non-Project Synthesis — 3 × 32-ALU TMR Array
# Target : xc7a35tcpg236-1  (Artix-7 35T)
# Usage  : vivado -mode batch -source synth/synth_alu_array_tmr.tcl
#
# Architecture: alu_array_tmr
#   3 × alu_array (32 ALUs each) + 32 majority_voter per slot
#   Total: 96 ALU instances, 32 voters
#
# -flatten_hierarchy full: ensures all 96 ALU internal nets
#   become direct children of alu_array_tmr in the DCP, so
#   XSim's flat SAIF output matches at ~90%+ confidence (High).
# ============================================================

set DESIGN     "alu_array_tmr"
set PART       "xc7a35tcpg236-1"
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set RTL_DIR    [file normalize [file join $SCRIPT_DIR .. rtl]]
set OUT_DIR    [file normalize [file join $SCRIPT_DIR reports alu_array_tmr]]

file mkdir $OUT_DIR

# ── Read RTL ─────────────────────────────────────────────────
read_verilog [file join $RTL_DIR alu.v]
read_verilog [file join $RTL_DIR majority_voter.v]
read_verilog [file join $RTL_DIR alu_array.v]
read_verilog [file join $RTL_DIR alu_array_tmr.v]

# ── Synthesis ─────────────────────────────────────────────────
# -flatten_hierarchy full: collapses all 3 arrays × 32 sub-ALU
# instances into one flat alu_array_tmr module so all ~9000 nets
# are direct children — matching XSim SAIF flat output.
synth_design \
    -top  $DESIGN \
    -part $PART \
    -no_iobuf \
    -flatten_hierarchy full

opt_design

write_checkpoint -force [file join $OUT_DIR synth.dcp]

# ── Implement ─────────────────────────────────────────────────
create_clock -period 10.000 -name clk [get_ports clk]
place_design
route_design

write_checkpoint -force [file join $OUT_DIR impl.dcp]
write_verilog -mode funcsim -force [file join $OUT_DIR post_impl_netlist.v]

# ── Reports ───────────────────────────────────────────────────
report_utilization   -file [file join $OUT_DIR utilization.rpt]
report_power         -file [file join $OUT_DIR power.rpt]
report_timing_summary \
    -delay_type max \
    -check_timing_verbose \
    -file [file join $OUT_DIR timing.rpt]

puts "\n\[INFO\] ALU-array-TMR synthesis+implementation complete. Reports in: $OUT_DIR\n"

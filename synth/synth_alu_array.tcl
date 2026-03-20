# ============================================================
# synth_alu_array.tcl
# Vivado Non-Project Synthesis — 32 × ALU Array
# Target : xc7a35tcpg236-1  (Artix-7 35T)
# Usage  : vivado -mode batch -source synth/synth_alu_array.tcl
# ============================================================

set DESIGN     "alu_array"
set PART       "xc7a35tcpg236-1"
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set RTL_DIR    [file normalize [file join $SCRIPT_DIR .. rtl]]
set OUT_DIR    [file normalize [file join $SCRIPT_DIR reports alu_array]]

file mkdir $OUT_DIR

# ── Read RTL ─────────────────────────────────────────────────
read_verilog [file join $RTL_DIR alu.v]
read_verilog [file join $RTL_DIR alu_array.v]

# ── Synthesis ─────────────────────────────────────────────────
# -flatten_hierarchy full: fully flattens the 32 sub-ALU instances into
# alu_array so that the post-impl netlist has ONE level of hierarchy.
# XSim cannot write INSTANCE sub-blocks for generate-loop instances in SAIF,
# so without flattening only ~31% of nets match.  With full flattening,
# get_objects /tb/uut/* sees all internal signals at the same level and
# net matching rises to ~95%+.
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

puts "\n\[INFO\] ALU-array synthesis+implementation complete. Reports in: $OUT_DIR\n"

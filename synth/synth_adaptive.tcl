# ============================================================
# synth_adaptive.tcl
# Vivado Non-Project Synthesis — Adaptive Redundancy
# Target : xc7z020clg400-1  (Zynq, e.g. Zybo / Pynq-Z2)
# Usage  : vivado -mode batch -source synth_adaptive.tcl
# ============================================================

set DESIGN     "top_adaptive"
set PART       "xc7z020clg400-1"
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set RTL_DIR    [file normalize [file join $SCRIPT_DIR .. rtl]]
set OUT_DIR    [file normalize [file join $SCRIPT_DIR reports adaptive]]

# ── Create output directory ──────────────────────────────────
file mkdir $OUT_DIR

# ── Read RTL (all dependencies first, then top) ───────────────
read_verilog [file join $RTL_DIR alu.v]
read_verilog [file join $RTL_DIR fault_injector.v]
read_verilog [file join $RTL_DIR majority_voter.v]
read_verilog [file join $RTL_DIR risk_estimator.v]
read_verilog [file join $RTL_DIR redundancy_controller.v]
read_verilog [file join $RTL_DIR top_adaptive.v]

# ── Synthesis ─────────────────────────────────────────────────
synth_design \
    -top  $DESIGN \
    -part $PART \
    -no_iobuf

# ── Optimise ─────────────────────────────────────────────────
opt_design

# ── Save synthesis checkpoint ──────────────────────────────────
write_checkpoint -force [file join $OUT_DIR synth.dcp]

# ── Apply clock constraint then implement ───────────────────
create_clock -period 10.000 -name clk [get_ports clk]
place_design
route_design

write_checkpoint -force [file join $OUT_DIR impl.dcp]
write_verilog -mode funcsim -force [file join $OUT_DIR post_impl_netlist.v]

# ── Reports ──────────────────────────────────────────────────
report_utilization   -file [file join $OUT_DIR utilization.rpt]
report_power         -file [file join $OUT_DIR power.rpt]
report_timing_summary \
    -delay_type max \
    -check_timing_verbose \
    -file [file join $OUT_DIR timing.rpt]

puts "\n\[INFO\] Adaptive synthesis+implementation complete. Reports in: $OUT_DIR\n"

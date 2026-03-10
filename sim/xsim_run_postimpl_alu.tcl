# xsim_run_postimpl_alu.tcl
# XSim runtime — records SAIF from post-implementation netlist simulation.
# Single restart initialises the design, then scope-based log_saif -r
# recursively registers all signals under uut without calling get_objects
# (avoids XSim-internal model signals that pollute the SAIF hierarchy).

set SAIF_FILE {synth/reports/alu/sim_impl.saif}

restart
open_saif $SAIF_FILE
log_saif [get_objects /tb_power_alu/uut/*]
run -all
close_saif

puts "\[XSIM\] ALU post-impl SAIF written to: $SAIF_FILE"
quit

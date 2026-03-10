# ============================================================
# xsim_run_adaptive.tcl
# XSim runtime script — records SAIF for the Adaptive design.
#
# Invoked by:
#   xsim tb_power_adaptive_snap -nolog -tclbatch sim/xsim_run_adaptive.tcl
# ============================================================

set SAIF_FILE {synth/reports/adaptive/sim.saif}

restart
open_saif $SAIF_FILE
log_saif [get_objects /tb_power_adaptive/*]
restart
run -all
close_saif

puts "\[XSIM\] Adaptive SAIF written to: $SAIF_FILE"
quit

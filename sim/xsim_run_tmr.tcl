# ============================================================
# xsim_run_tmr.tcl
# XSim runtime script — records SAIF for the TMR design.
#
# Invoked by:
#   xsim tb_power_tmr_snap -nolog -tclbatch sim/xsim_run_tmr.tcl
# ============================================================

set SAIF_FILE {synth/reports/tmr/sim.saif}

restart
open_saif $SAIF_FILE
log_saif [get_objects /tb_power_tmr/*]
restart
run -all
close_saif

puts "\[XSIM\] TMR SAIF written to: $SAIF_FILE"
quit

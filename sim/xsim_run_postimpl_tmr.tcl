# xsim_run_postimpl_tmr.tcl
set SAIF_FILE {synth/reports/tmr/sim_impl.saif}

restart
open_saif $SAIF_FILE
log_saif [get_objects /tb_power_tmr/uut/*]
run -all
close_saif

puts "\[XSIM\] TMR post-impl SAIF written to: $SAIF_FILE"
quit

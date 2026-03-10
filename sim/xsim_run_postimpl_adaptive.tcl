# xsim_run_postimpl_adaptive.tcl
set SAIF_FILE {synth/reports/adaptive/sim_impl.saif}

restart
open_saif $SAIF_FILE
log_saif [get_objects /tb_power_adaptive/uut/*]
run -all
close_saif

puts "\[XSIM\] Adaptive post-impl SAIF written to: $SAIF_FILE"
quit

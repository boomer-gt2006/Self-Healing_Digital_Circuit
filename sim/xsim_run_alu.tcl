# ============================================================
# xsim_run_alu.tcl
# XSim runtime script — records SAIF for the ALU design.
#
# Invoked by:
#   xsim tb_power_alu_snap -nolog -tclbatch sim/xsim_run_alu.tcl
#
# The script:
#   1. Opens a SAIF file for writing.
#   2. Registers all objects under the DUT instance for logging.
#   3. Runs the simulation to completion ($finish in testbench).
#   4. Closes the SAIF and exits XSim.
# ============================================================

# Output SAIF path — relative to xsim working directory which
# is set by the batch script to the project root.
set SAIF_FILE {synth/reports/alu/sim.saif}

# Restart to initialise the simulation (makes objects accessible)
restart

# Open SAIF for recording
open_saif $SAIF_FILE

# Log all signals in the testbench scope.
# The uut (alu) ports are connected to same-named wires, so
# /tb_power_alu/* captures full port-level switching activity.
log_saif [get_objects /tb_power_alu/*]

# Restart to time 0 so the full simulation is captured in the SAIF
restart

# Run until $finish is called by the testbench
run -all

# Close the SAIF file (flushes and writes final statistics)
close_saif

puts "\[XSIM\] ALU SAIF written to: $SAIF_FILE"

quit

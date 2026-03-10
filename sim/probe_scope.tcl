restart
puts "=== Testing log_saif -r on uut scope ==="
current_scope /tb_power_alu/uut
puts "current_scope: [current_scope]"
puts "Objects in uut:"
foreach o [get_objects] { puts "  $o" }
quit

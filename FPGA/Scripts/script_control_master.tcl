.main clear
vlog control.v
vlog control_master_tb.v
project compileall
vsim -gui work.control_tb
add wave -position insertpoint sim:/control_tb/*
add wave -position insertpoint sim:/control_tb/uut/edge_detector_reg
add wave -position insertpoint sim:/control_tb/uut/state
add wave -position insertpoint sim:/control_tb/uut/next_state
config wave -signalnamewidth 1
run -all
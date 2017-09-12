.main clear
vlog controlmicro_sd.v
vlog control_microsd_tb.v
project compileall
vsim -gui work.control_microsd_tb
add wave -position insertpoint sim:/control_microsd_tb/*
add wave -position insertpoint sim:/control_microsd_tb/uut/edge_detector_reg
config wave -signalnamewidth 1
run -all
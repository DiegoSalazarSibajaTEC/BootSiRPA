.main clear
vlog controlsd.v
vlog controlsd_tb.v
project compileall
vsim -gui work.controlsd_tb
add wave -position insertpoint sim:/controlsd_tb/*
add wave -position insertpoint sim:/controlsd_tb/uut/instruction_sd
add wave -position insertpoint sim:/controlsd_tb/uut/word_counter
add wave -position insertpoint sim:/controlsd_tb/uut/flag_edge_detector
add wave -position insertpoint sim:/controlsd_tb/uut/transmission
add wave -position insertpoint sim:/controlsd_tb/uut/flag
add wave -position insertpoint sim:/controlsd_tb/uut/state
add wave -position insertpoint sim:/controlsd_tb/uut/next_state
config wave -signalnamewidth 1
run -all
.main clear
vlog CRC_7.v
vlog CRC_tb2.v
project compileall
vsim -gui work.CRC_tb2
add wave -position insertpoint sim:/CRC_tb2/*
add wave -position insertpoint sim:/CRC_tb2/uut/counter
add wave -position insertpoint sim:/CRC_tb2/uut/BITVAL
add wave -position insertpoint sim:/CRC_tb2/uut/data_int
add wave -position insertpoint sim:/CRC_tb2/uut/inv
config wave -signalnamewidth 1
run -all
.main clear
vlog ram_dual.v
vlog fifo.v
vlog control_mem.v
vlog sram.v
vlog test1.v
vlog test1_tb.v
project compileall
vsim -gui work.test1_tb
add wave -position insertpoint sim:/test1_tb/*
add wave -position insertpoint sim:/test1_tb/uut/fifo_data
add wave -position insertpoint sim:/test1_tb/uut/read_fifo_flag
add wave -position insertpoint sim:/test1_tb/uut/sram_address
add wave -position insertpoint sim:/test1_tb/uut/sram_datain
add wave -position insertpoint sim:/test1_tb/uut/sram_cs
add wave -position insertpoint sim:/test1_tb/uut/sram_we
config wave -signalnamewidth 1
run -all
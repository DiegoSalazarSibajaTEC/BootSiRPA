.main clear
vlog ram_dual.v
vlog fifo.v
vlog fifo_tb.v
project compileall
vsim -gui work.fifo_tb
add wave -position insertpoint sim:/fifo_tb/*
#add wave -position insertpoint sim:/fifo_tb/uut/*
config wave -signalnamewidth 1
run -all
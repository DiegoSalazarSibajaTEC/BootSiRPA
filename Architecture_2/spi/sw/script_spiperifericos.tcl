.main clear
vlog spi_perifericos.v
vlog spiperifericos_tb.v
project compileall
vsim -gui work.spiperifericos_tb
add wave -position insertpoint sim:/spiperifericos_tb/*
config wave -signalnamewidth 1
run -all
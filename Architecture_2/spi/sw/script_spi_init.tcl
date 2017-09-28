.main clear
vlog spi_init.v
vlog spi_init_tb.v
project compileall
vsim -gui work.spi_init_tb
add wave -position insertpoint sim:/spi_init_tb/*
add wave -position insertpoint sim:/spi_init_tb/uut/counter_operation
config wave -signalnamewidth 1
run -all
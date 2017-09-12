.main clear
vlog spi.v
vlog spi_tb.v
project compileall
vsim -gui work.spi_tb
add wave -position insertpoint sim:/spi_tb/*
config wave -signalnamewidth 1
run -all
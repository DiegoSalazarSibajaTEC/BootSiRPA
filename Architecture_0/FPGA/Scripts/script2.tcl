.main clear
vlog spi_std.v
vlog spi_std_tb.v
project compileall
vsim -gui work.spi_std_tb
add wave -position insertpoint sim:/spi_std_tb/*
add wave -position insertpoint sim:/spi_std_tb/uut/state
add wave -position insertpoint sim:/spi_std_tb/uut/word_counter
add wave -position insertpoint sim:/spi_std_tb/uut/shift
config wave -signalnamewidth 1
run -all
.main clear
vlog bootstrap.v
vlog bootstrap_tb.v
vlog spi_perifericos.v
vlog control_mem.v
vlog spi_init.v
vlog spi_microSDHC.v
vlog fifo.v
vlog spi.v
vlog spi_microSD.v
vlog ram_dual.v
vlog test.v
vlog test_tb.v
project compileall
vsim -gui work.test_tb
add wave -position insertpoint sim:/test_tb/*
add wave -position insertpoint sim:/test_tb/uut/spi_flagreg_o
add wave -position insertpoint sim:/test_tb/uut/spi_data_i
config wave -signalnamewidth 1
run -all
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
project compileall
vsim -gui work.bootstrap_tb
add wave -position insertpoint sim:/bootstrap_tb/*
config wave -signalnamewidth 1
run -all
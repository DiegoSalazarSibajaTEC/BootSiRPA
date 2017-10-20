.main clear
vlog spi_microSDHC.v
vlog spi_microSD.v
vlog spi_init.v
vlog spi_microSDHC_tb.v
project compileall
vsim -gui work.spi_microSDHC_tb
add wave -position insertpoint sim:/spi_microSDHC_tb/*
add wave -position insertpoint sim:/spi_microSDHC_tb/uut/spi_statusreg
add wave -position insertpoint sim:/spi_microSDHC_tb/uut/spi_data
add wave -position insertpoint sim:/spi_microSDHC_tb/uut/R1
config wave -signalnamewidth 1
run -all
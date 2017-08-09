.main clear
vlog spi_control.v
vlog spi_testbench.v
project compileall
vsim -gui work.spi_testbench
add wave -position insertpoint sim:/spi_testbench/spi_rst_i
add wave -position insertpoint sim:/spi_testbench/spi_clk_i
add wave -position insertpoint sim:/spi_testbench/spi_fbo_i
add wave -position insertpoint sim:/spi_testbench/spi_start_i
add wave -position insertpoint sim:/spi_testbench/transmission_data_i
add wave -position insertpoint sim:/spi_testbench/clock_divider_i
add wave -position insertpoint sim:/spi_testbench/MISO
add wave -position insertpoint sim:/spi_testbench/SS
add wave -position insertpoint sim:/spi_testbench/SCK
add wave -position insertpoint sim:/spi_testbench/MOSI
add wave -position insertpoint sim:/spi_testbench/done
add wave -position insertpoint sim:/spi_testbench/received_data_o
add wave -position insertpoint sim:/spi_testbench/uut/word_counter
config wave -signalnamewidth 1
run -all
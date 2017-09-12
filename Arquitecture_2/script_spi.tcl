.main clear
vlog spi.v
vlog spi_tb.v
project compileall
vsim -gui work.spi_tb
add wave -position insertpoint sim:/spi_tb/*
add wave -position insertpoint sim:/spi_tb/uut/clear_reg_word
add wave -position insertpoint sim:/spi_tb/uut/word_counter
add wave -position insertpoint sim:/spi_tb/uut/data_out_MOSI
add wave -position insertpoint sim:/spi_tb/uut/word_counter_send
add wave -position insertpoint sim:/spi_tb/uut/state
add wave -position insertpoint sim:/spi_tb/uut/word_counter_wroper 
config wave -signalnamewidth 1
run -all
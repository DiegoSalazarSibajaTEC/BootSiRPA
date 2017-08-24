`timescale 1ns / 1ps

module spi_microsd(sd_address_i, control_rst_i, control_clk_i, SCK, mem_data_o, control_we_i, control_re_i, control_dataw_i, SS, MISO, MOSI);


input [31:0] sd_address_i;
input control_rst_i;
input control_clk_i;
input control_we_i;
input control_re_i;
input [31:0] control_dataw_i;
input MISO;
output SCK;
output [31:0] mem_data_o;
output SS;
output MOSI;

wire spi_rst;
wire spi_fbo;
wire spi_start;
wire [47:0] instruction_sd;
wire clock_divider;
wire [79:0] spi_data;
wire spi_done;
wire spi_datawe;
wire spi_sendenb;


controlmicro_sd microSD (
    .spi_rst_o(spi_rst), 
    .sd_address_i(sd_address_i), 
    .spi_fbo_o(spi_fbo), //
    .spi_start_o(spi_start), //
    .instruction_sd_o(instruction_sd),// 
    .clock_divider_o(clock_divider),// 
    .spi_data_i(spi_data), //
    .control_rst_i(control_rst_i), //
    .control_clk_i(control_clk_i), //
    .spi_SCK_i(SCK), //
    .spi_done_i(spi_done), //
    .mem_data_o(mem_data_o), 
    .control_we_i(control_we_i), 
    .control_re_i(control_re_i),// 
    .spi_datawe_i(spi_datawe), //
    .spi_sendenb_o(spi_sendenb), //
    .control_dataw_i(control_dataw_i)
    );

spi_std spi_microsd (
    .spi_rst_i(spi_rst), //
    .spi_clk_i(spi_clk_i), //
    .spi_fbo_i(spi_fbo), //
    .spi_start_i(spi_start),// 
    .transmission_data_i(instruction_sd), //
    .clock_divider_i(clock_divider), //
    .MISO(MISO), 
    .SS(SS), 
    .SCK(SCK), 
    .MOSI(MOSI), 
    .done(spi_done), //
    .received_data_o(spi_data), //
    .spi_datawe_o(spi_datawe), //
    .spi_sendenb_i(spi_sendenb)//
    );




endmodule

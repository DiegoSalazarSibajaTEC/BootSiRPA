`timescale 1ns / 1ps

module spi #(parameter DATA_WIDTH = 8)(spi_clk_i, spi_rst_i, spi_statusreg_i, spi_data_i, spi_init_i, MISO, MOSI, SCK_SPI, SS, spi_initdone_o, spi_flagreg_o, spi_data_o);

input 				spi_clk_i;
input 				spi_rst_i;
input 				MISO;
input 		[8:0] 	spi_statusreg_i;
input 		[47:0] 	spi_data_i;
input 				spi_init_i;
output wire 		spi_initdone_o;
output wire 		MOSI;
output wire 		SS;
output wire 		SCK_SPI;
output wire [2:0]	spi_flagreg_o;
output wire [31:0] 	spi_data_o;

//MUX SIGNALS
wire 		MOSI_spi_1;
wire 		MOSI_spi_2;
wire 		SCK_SPI_spi_1;
wire 		SCK_SPI_spi_2;
wire 		SS_spi_1;
wire 		SS_spi_2;
wire [7:0] 	statusreg_spi_1;
wire [5:0] 	statusreg_spi_2;
wire [2:0] 	flagreg_spi_1;
wire 		flagreg_spi_2;
wire [2*DATA_WIDTH-1:0] dataout_spi_2;
wire [31:0] dataout_spi_1;

assign MOSI = 			(spi_statusreg_i[8:7]== 2'b11) ? MOSI_spi_1 : (spi_statusreg_i[8:7]== 2'b10) ? MOSI_spi_2 : 1'b0;
assign SCK_SPI = 		(spi_statusreg_i[8:7]== 2'b11) ? SCK_SPI_spi_1 : (spi_statusreg_i[8:7]== 2'b10) ? SCK_SPI_spi_2 : 1'b0;
assign SS = 			(spi_statusreg_i[8:7]== 2'b11) ? SS_spi_1 :(spi_statusreg_i[8:7]== 2'b10) ? SS_spi_2 : 1'b1;
assign statusreg_spi_1 = (spi_statusreg_i[8:7]== 2'b11) ? spi_statusreg_i[7:0] : 8'h00 ;
assign statusreg_spi_2 = (spi_statusreg_i[8:7]== 2'b10) ? {spi_statusreg_i[7:4], spi_statusreg_i[1:0]} : 6'h00 ;
assign spi_flagreg_o = 	(spi_statusreg_i[8:7]== 2'b11) ? flagreg_spi_1 : (spi_statusreg_i[8:7]== 2'b10) ? {flagreg_spi_2,2'b00} : 3'b000;
assign spi_data_o = 	(spi_statusreg_i[8:7]== 2'b11) ? dataout_spi_1 : (spi_statusreg_i[8:7]== 2'b10) ? {dataout_spi_2, {32-2*DATA_WIDTH{1'b0}}} : 32'd0;

spi_microSDHC spi_1 (
    .spi_clk_i(spi_clk_i), //
    .spi_rst_i(spi_rst_i), //
    .spi_statusreg_i(statusreg_spi_1), //
    .spi_data_i(spi_data_i), //
    .MISO(MISO), //
    .spi_init_i(spi_init_i), //
    .spi_data_o(dataout_spi_1), //
    .spi_flagreg_o(flagreg_spi_1), //
    .MOSI(MOSI_spi_1), //
    .SS(SS_spi_1), //
    .SCK_SPI(SCK_SPI_spi_1), //
    .spi_initdone_o(spi_initdone_o)//
    );


spi_perifericos #(.DATA_WIDTH(DATA_WIDTH)) spi_2 (
    .spi_clk_i(spi_clk_i), //
    .spi_rst_i(spi_rst_i), //
    .spi_data_i(spi_data_i[47:40]), //
    .spi_data_o(dataout_spi_2), //
    .MOSI(MOSI_spi_2), //
    .MISO(MISO), //
    .SCK_SPI(SCK_SPI_spi_2), //
    .SS(SS_spi_2), //
    .spi_doneflag_o(flagreg_spi_2), //
    .spi_statusreg_i(statusreg_spi_2)//
    );



endmodule
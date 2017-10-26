`timescale 1ns / 1ps
/**************************************************************************************
Bootstrap DCILAB 2017
Instituto Tecnológico de Costa Rica

Diego Salazar Sibaja

Modulo: SPI init

Descripción general: Este módulo es una memoria en la cual se encuentran los comandos 
de inicializacion para la tarjeta SD.

****************************************************************************************/
module spi_microSDHC( spi_clk_i, spi_rst_i, spi_statusreg_i, spi_data_i, MISO, spi_init_i, spi_data_o, spi_flagreg_o, MOSI, SS, SCK_SPI, spi_initdone_o);

//************************OUTPUTS and INPUTS********************************************
input 				spi_clk_i;
input 				spi_rst_i;
input 		[7:0] 	spi_statusreg_i;
input 		[47:0]	spi_data_i;
input 				MISO;
input 				spi_init_i;
output wire [31:0] 	spi_data_o;
output wire [2:0] 	spi_flagreg_o;
output wire			MOSI;
output wire			SS;
output wire			SCK_SPI;
output wire			spi_initdone_o;

//*************************Señales internas********************************************
wire [47:0] spi_data;
wire [7:0] 	R1;
wire [8:0] 	spi_statusreg;


//*****************************Instaciación********************************************
spi_microSD A1 (
    .spi_clk_i(spi_clk_i), //
    .spi_rst_i(spi_rst_i), //
    .spi_data_i(spi_data), //
    .spi_data_o(spi_data_o), //
    .MOSI(MOSI), //
    .MISO(MISO), //
    .SCK_SPI(SCK_SPI), //
    .SS(SS), //
    .R1(R1), //
    .spi_flagreg_o(spi_flagreg_o), //
    .spi_statusreg_i(spi_statusreg)//
    );
	 
spi_init A2 (
    .spi_clk_i(spi_clk_i), //
    .spi_rst_i(spi_rst_i), //
    .spi_init_i(spi_init_i), //
    .spi_datamicro_i(spi_data_i),// 
    .spi_statusregmicro_i(spi_statusreg_i), //
    .R1(R1), //
    .spi_flagreg_i(spi_flagreg_o), //
    .spi_datainit_o(spi_data), //
    .spi_statusreginit_o(spi_statusreg), //
    .spi_initdone_o(spi_initdone_o)
    );

endmodule
`timescale 1ns / 1ps
/**************************************************************************************
Bootstrap DCILAB 2017
Instituto Tecnológico de Costa Rica

Diego Salazar Sibaja

Modulo: SPI init

Descripción general: En este módulo se hace la multiplexación de señales, dependiendo
del protocolo SPI a activar por el microprocesador o el controlador del bootstrap.
Se encuentran instanciados los modulos spi_microSDHC.v y spi_perifericos.v

****************************************************************************************/
module spi #(parameter DATA_WIDTH = 8)(spi_clk_i, spi_rst_i, spi_statusreg_i, spi_data_i, spi_init_i, MISO, MOSI, SCK_SPI, SS, spi_initdone_o,
										spi_flagreg_o, spi_data_o,spi_initwritemem_o, R1);

//************************OUTPUTS and INPUTS********************************************
input 				spi_clk_i;//************Reloj master
input 				spi_rst_i;//************Reset master 1:Reset/0:No reset
input 				MISO;//*****************MISO del SPI
/***************************************************************************************
		La señal spi_statusreg_i es una serie de banderas que indican ciertas caracteristicas
		para el protocolo SPI. Se describe como:
			[0] Operacion --> Indica cuando se habilita una operacion de transmision 1:Habilitado/0:desabilitado
			[1] FBO --> Indica si el primer bit de salida es MSB o LSB 1:MSB/0LSB
			[2] WR_EN --> Indica si se va a enviar un comando de escritura 1:Habilitado/0:desabilitado
			[3] RD_EN --> Indica si se va a enviar un comando de lectura 1:Habilitado/0:desabilitado
			[4:6] Divisor --> Indica en que escala se divide el SCK SPI con respector al reloj 
					  master. 000= 1:1, 001= 1:2, 010= 1:4, 011= 1:8, 1xx=1:16
			[7] Enable 1/2--> Habilita el SPI a operar 1:SPI microSD/0:SPI perifericos
			[8] Enable--> Habilita operacion de los SPI 1:Habilitado/0:desabilitado
**************************************************************************************/
input 		[8:0] 	spi_statusreg_i;
/***************************************************************************************
		La señal spi_data_i es la señal con los datos de entrada para ambos módulos SPI. En el
		caso del SPI microSD, la palabra se utiliza completa. En el SPI perifericos, solo se utiliza
		los bits más significativos de palabra como la palabra de uso para el módulo.
**************************************************************************************/
input 		[47:0] 	spi_data_i; 
/***************************************************************************************
		La señal spi_init_i señala se si esta inicializando la tarjeta SD
		1: Inicializando / 0: Sin inicializar o ya inicializada
**************************************************************************************/
input 				spi_init_i;
output wire 		spi_initdone_o;//*******Indica finalización de la inicializacion 1: Finalizado/0:No finalizado
output wire 		MOSI;//*****************MOSI del SPI
output wire 		SS;//*******************SS del SPI
output wire 		SCK_SPI;//**************SCK del SPI
/***************************************************************************************
		La señal spi_flagreg_i es una serie de banderas que finalización de eventos. Se describe como:
			[0] WORD_COM --> Indica cuando se completo el envio o recepción de una
				palabra 1:Completado/0:No Completo
			[1] OPERT_DONE --> Indica cuando se completo el envio de un comando  1:Completado/0:No Completo
			[2] DATA_WR --> Indica cuando se debe enviar los datos a enviar 1:Habilitado/0:desabilitado
**************************************************************************************/
output wire [2:0]	spi_flagreg_o;
output wire [31:0] 	spi_data_o;//Datos de salida del SPI
output wire			spi_initwritemem_o;
output wire [7:0]   R1;

//***************************Señales y mulplexación de señales************************
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


//*****************************Instaciación********************************************
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
    .spi_initdone_o(spi_initdone_o),//
	.spi_initwritemem_o(spi_initwritemem_o),
	.R1(R1)
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
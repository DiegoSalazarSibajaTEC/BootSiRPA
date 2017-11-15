`timescale 1ns / 1ps
/**************************************************************************************
Bootstrap DCILAB 2017
Instituto Tecnológico de Costa Rica

Diego Salazar Sibaja

Modulo: SPI init

Descripción general: Este módulo es una memoria en la cual se encuentran los comandos 
de inicializacion para la tarjeta SD.

****************************************************************************************/
module spi_init(spi_clk_i, spi_rst_i, spi_init_i, spi_datamicro_i, spi_statusregmicro_i, R1, spi_flagreg_i, spi_datainit_o, spi_statusreginit_o,
				spi_initdone_o, spi_initwritemem_o);

/***************************************************************************************
Parametros con los valores de los comandos  y respuestas R1 de inicializacion de la 
tarjeta SD.
**************************************************************************************/
parameter IWAIT  = 48'hFFFFFFFFFFFF;
parameter ICMD0  = 48'h400000000095; //r1
parameter ICMD8  = 48'h48000001AA87; //r7 87 o 0F
parameter ICMD55 = 48'h770000000001;
parameter IACMD41= 48'h694000000077;
parameter ICMD58 = 48'h7A0000000001;
parameter ICMD59 = 48'h7B00000000FF;//x01
parameter RCMDX	 = 8'h01;
parameter RCMDY	 = 8'h00;

//************************OUTPUTS and INPUTS********************************************
input 				spi_clk_i;//***************Reloj master
input 				spi_rst_i;//***************Reset master 1:Reset/0:No reset
/***************************************************************************************
		La señal spi_init_i señala se si esta inicializando la tarjeta SD
		1: Inicializando / 0: Sin inicializar o ya inicializada
**************************************************************************************/
input 				spi_init_i;
/***************************************************************************************
		La señal spi_datamicro_i y spi_statusregmicro_i son los datos que van a la 
		tarjeta SD cuando spi_init_i=0
**************************************************************************************/
input [47:0] 		spi_datamicro_i;//
input [7:0] 		spi_statusregmicro_i;
input [7:0] 		R1;//*********************Valor de respuesta R1
/***************************************************************************************
		La señal spi_flagreg_i es una serie de banderas que finalización de eventos. Se describe como:
			[0] WORD_COM --> Indica cuando se completo el envio o recepción de una
				palabra 1:Completado/0:No Completo
			[1] OPERT_DONE --> Indica cuando se completo el envio de un comando  1:Completado/0:No Completo
			[2] DATA_WR --> Indica cuando se debe enviar los datos a enviar 1:Habilitado/0:desabilitado
**************************************************************************************/
input [2:0] 		spi_flagreg_i;
output wire [47:0] 	spi_datainit_o;//*********Comando para spi_microSD.v(spi_data_i)
output wire [8:0]  	spi_statusreginit_o;//****Señal para spi_microSD.v(spi_statusreg_i)
output reg 			spi_initdone_o;//*********Indica finalización de la inicializacion 1: Finalizado/0:No finalizado
output reg			spi_initwritemem_o;
//**************************************************************************************

//*************************Señales internas********************************************
reg [47:0]	datainit;//***********Comando a enviar
reg [8:0] 	statusreg;//**********StatusReg a enviar
reg [4:0] 	counter_operation;//**Contador de estado inicializacion
reg 		enable_count;//*******Bandera habilitador de cuenta
reg 		r_acmd47;//***********Bandera de R1 correcto

//********ASIGNACIÓN DE SEÑALES DE SALIDA********************************************
assign spi_datainit_o =(spi_init_i) ? datainit : spi_datamicro_i;
assign spi_statusreginit_o = (spi_init_i) ? statusreg : {spi_statusregmicro_i[7:1],1'b0,spi_statusregmicro_i[0]};


/****************************M�?QUINA DE ESTADO***************************************
En esta máquina de estados se registra en cada valor el comando y el valor de StatusReg
a enviar cuando el valor de spi_init_i es 1. Una vez finalizado, el valor de 
spi_initdone_o cambia a 1, con el fin de finalizar le inicializacion. Dejar spi_init_i
no provoca ningun cambio, al menos de que se resetee la unidad. En el caso de statusreg
se comenta el valor de cada variable
***********************************************************************************/
always @(posedge spi_clk_i or posedge spi_rst_i)begin
	if(spi_rst_i)begin
		counter_operation <= 5'h00;
	end
	else if (enable_count && spi_init_i && spi_statusregmicro_i[7] && spi_flagreg_i[1] == 1'b1) begin
		if(r_acmd47) begin
			counter_operation <= 5'h03;
		end
		else begin
		 counter_operation <= counter_operation +5'h01;
		end
	end
end
always @* begin
	enable_count = 1'b0;
	r_acmd47 = 1'b0;
	spi_initdone_o = 1'b0;
	datainit = IWAIT;
	statusreg = 8'h00;
	spi_initwritemem_o = 1'b0;
	case(counter_operation)
		5'h00: begin 
			datainit = IWAIT;
			statusreg = 9'b101000111; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 1 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end
		5'h01: begin 
			datainit = ICMD0;
			statusreg = 9'b101000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end		
		5'h02: begin 
			datainit = ICMD8;
			statusreg = 9'b101000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end	
		5'h03: begin 
			datainit = ICMD55;
			statusreg = 9'b101000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end

		5'h04: begin 
			datainit = IACMD41;
			statusreg = 9'b101000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
			if(R1== RCMDY)begin
				r_acmd47 = 1'b0;
			end
			else begin
				r_acmd47 = 1'b1;
			end
		end
		5'h05: begin 
			datainit = ICMD58;
			statusreg = 9'b101000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end
		5'h06: begin 
			datainit = ICMD59;
			statusreg = 9'b101000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end
		5'h07: begin 
			datainit = {8'h51, 32'h00006020, 8'hFF};
			spi_initwritemem_o = 1'b1;
			statusreg = 9'b101010101; //010 1:4 clock divider -- 1 microSDrd 0 microSDwr -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			if(R1 == RCMDY )begin//|| R1== RCMDY)begin
				enable_count = 1'b1; 
			end
			else begin
				enable_count = 1'b0;
			end
		end
		5'h08: begin
			spi_initdone_o = 1'b1;
			spi_initwritemem_o = 1'b1;
			enable_count = 1'b0;
			r_acmd47 = 1'b0;
		end

	endcase
end

endmodule
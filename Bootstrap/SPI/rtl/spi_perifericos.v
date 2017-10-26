`timescale 1ns / 1ps
/***************************************************************
Bootstrap DCILAB 2017
Instituto Tecnológico de Costa Rica

Diego Salazar Sibaja

Modulo: SPI perifericos

Descripción general: Este módulo se encarga de realizar una comunicación SPI con perifericos.
El mismo es un código de un SPI master, el cual envía un byte y es capaz de recibir 2 bytes.
El tamaño de la palabra es ajustable con el parameter DATA_WIDTH. Se detalla su funcionamiento 
a traves del código.

****************************************************************/

module spi_perifericos#(parameter DATA_WIDTH=8)(spi_clk_i, spi_rst_i, spi_data_i, spi_data_o, MOSI, MISO, SCK_SPI, SS, spi_doneflag_o, spi_statusreg_i);



/***************************************************************************************
Parametros para la máquina de estados para envío y recepción de datos SPI.
**************************************************************************************/
parameter 	idle=2'b00;		
parameter 	send=2'b10; 
parameter 	finish=2'b11; 


//************************OUTPUTS and INPUTS********************************************
/***************************************************************************************
La señal spi_statusreg_i es una serie de banderas que indican ciertas caracteristicas
para el protocolo SPI. Se describe como:
	[0] Operacion --> Indica cuando se habilita una operacion de transmision 1:Habilitado/0:desabilitado
	[1] FBO --> Indica si el primer bit de salida es MSB o LSB 1:MSB/0LSB
	[2:4] Divisor --> Indica en que escala se divide el SCK SPI con respector al reloj 
					  master. 000= 1:1, 001= 1:2, 010= 1:4, 011= 1:8, 1xx=1:16
	[5] Enable--> Habilita operacion de SPI perifericos 1:Habilitado/0:desabilitado
**************************************************************************************/
input		[5:0]				spi_statusreg_i;
input 							spi_clk_i; //****Reloj master
input 							spi_rst_i; //****Reset master 1:Reset/0:No reset
input 	   	[DATA_WIDTH-1:0]	spi_data_i;//****Datos de entrada para envío
input 							MISO;//**********Salida MISO del SPI
/***************************************************************************************
La señal spi_doneflag_o indica  cuando la operacion de envio y recepción de datos ha terminado.
Cuando esta señal se habilita el bit [0] de spi_statusreg_i debe deshabilitarse, sino la operacion
volvera a repetirse de nuevo.
1:Habilitado/0:desabilitado
**************************************************************************************/
output reg						spi_doneflag_o;
/***************************************************************************************
spi_data_o son los datos de salida, se compone de dos palabras. En los MSB se encuentra la 
primera palabra recibida por el periferico. En los LSB se encuentra la segunda palabra recibida
por el periferico.
**************************************************************************************/
output reg	[DATA_WIDTH-1:0]  spi_data_o;
output reg						MOSI;//*********Salida MOSI del SPI
output wire						SS;//***********Salida SS del SPI
output wire						SCK_SPI;//******Salida de reloj del SPI
//**************************************************************************************

//*************************Señales internas********************************************
reg	[4:0]				counter_divider;//******CONTADOR PARA DIVISOR DE FRECUENCIA
reg [7:0]				word_counter;//*********CUENTA LOS BITS DE ENTRADA
reg [7:0]				received_reg;//*********REGISTRO DE DATO RECIBIDO
reg [DATA_WIDTH-1:0]	transmission_reg;//*****REGISTRO DE DATO A ENVIAR
reg [DATA_WIDTH-1:0]	data_out_MOSI;//********DIVIDE LAS PALABRAS EN BYTES
reg						clear_reg; //***********LIMPIA REGISTROS DE CUENTAS
reg [1:0]				state, next_state; //***MAQUINA DE ESTADOS
reg [DATA_WIDTH-1:0]	reg_data_MISO; //*******REGISTRO DE DATOS FINAL
reg						SCK;//******************RELOJ INTERNO DEL SPI
reg 					complete_word; //*******Se completo envio de una palabra	

//***********************Division de la señal spi_statusreg_i*************************
wire						spi_fbo_i;
wire 						spi_operation_i;
wire						enable_operation;
wire [4:0]					clock_divider;
assign spi_operation_i	=	spi_statusreg_i[0];
assign spi_fbo_i		=	spi_statusreg_i[1];
assign enable_operation	=	spi_statusreg_i[5];
assign clock_divider	=	(spi_statusreg_i[4:2]==3'b000) ? 5'h00: (spi_statusreg_i[4:2]==3'b001) ? 5'h01 : (spi_statusreg_i[4:2]==3'b010) ? 5'h03 :
							(spi_statusreg_i[4:2]==3'b011) ? 5'h07 : 5'h0F;
				

//********ASIGNACIÓN DE SEÑALES DE SALIDA********************************************
assign SCK_SPI=(complete_word)? 1'b0:SCK;
assign SS=(complete_word )? 1'b1:1'b0;
always @(posedge spi_clk_i) begin
	if(spi_doneflag_o) begin
		spi_data_o <= reg_data_MISO;
	end
	else begin
		spi_data_o <= spi_data_o;
	end
end	

/****************************MÁQUINA DE ESTADO***************************************
En esta máquina de estados se tiene tres estados.
	idle: Cuando el módulo esta habilitado([5] de spi_statusreg_i), espera a que se 
	habilite el envio de un dato con [0] de spi_statusreg_i.
	send: Se realiza el envio de datos. Cuando se envie las dos palabra se habilita el
	siguiente estado.
	finish: En este estado se limpia registros de cuentas de bits y palabras, además
	de que se levanta la bandera de spi_doneflag_o.
***********************************************************************************/
always @* begin
	 next_state = state;
	 clear_reg	=	1'b0;
	 complete_word = 1'b0;
	 spi_doneflag_o	=	1'b0;
	 case(state)
		idle:begin
			clear_reg	=	1'b1;
			complete_word = 1'b1;
			if(spi_operation_i && enable_operation)begin
					next_state	=	send;
					spi_doneflag_o	=	1'b0;
			end
		end 
		send:begin
			clear_reg	=	1'b0;
			complete_word = 1'b0;
			spi_doneflag_o	=	1'b0;
			if (word_counter == 5'h08)begin //corroborar
				next_state	=	finish;
			end
			data_out_MOSI = spi_data_i; 
			reg_data_MISO= received_reg; 	
		end//send
			
		finish:begin
			clear_reg	=	1'b1;
			next_state	=	idle;
			spi_doneflag_o	=	1'b1;
			complete_word = 1'b1;
		end
		
		default: next_state	=	finish;
	endcase
end
//*************************Transición de estados*********************************
always@(posedge spi_clk_i  or posedge spi_rst_i) begin
	if(spi_rst_i) 
		state <= idle;
	else 
		state <= next_state;
 end

//*************************Generador de reloj SPI*********************************
always @(negedge spi_clk_i or posedge spi_rst_i or posedge clear_reg) begin
  if(spi_rst_i || clear_reg ) begin
		counter_divider	=	5'h0; 
		SCK	= 1'b0; 
	end
  else begin
		if(counter_divider == clock_divider) begin
			SCK	=~ SCK;
			counter_divider = 5'h00;
		end 
		else if(counter_divider != clock_divider)begin
			counter_divider = counter_divider + 5'h01;
		end
	end 
	
 end

//**************Cuenta bits enviados***********************************************
 always@(posedge SCK or posedge spi_rst_i or posedge clear_reg) begin
	if(spi_rst_i || clear_reg)  begin
		word_counter <= 8'd0;  
	end
    else begin 
		word_counter <= word_counter + 8'd1;
	end 
end 

 //****************Registros y procesos de salida e ingreso de datos***************
 //*********MISO INPUT DATA PROCESS************************************************
 always@(posedge SCK or posedge spi_rst_i or posedge clear_reg) begin
	if(spi_rst_i || clear_reg)  begin
			received_reg = 8'hFF;  
	end
    else begin 
		  if(spi_fbo_i== 1'b0) 
			begin  received_reg = {MISO,received_reg[DATA_WIDTH-1:1]};  end 
		  else  
			begin  received_reg = {received_reg[DATA_WIDTH-2:0],MISO};  end
	end 
end 
//**********MOSI OUTPUT DATA*******************************************************
always@(negedge SCK or posedge spi_rst_i  or posedge clear_reg) begin
	if(spi_rst_i || clear_reg) begin
	  transmission_reg = 8'hFF;  
	  MOSI = 1'b1;  
	end  
	else begin
		if(word_counter == 8'h00) begin //load data into transmission_reg
			transmission_reg = data_out_MOSI; 
			MOSI= spi_fbo_i ? transmission_reg[DATA_WIDTH-1]:transmission_reg[0];
		end 
		else begin
			if(spi_fbo_i == 1'b0) begin //LSB first, shift right
				transmission_reg = {1'b1,transmission_reg[DATA_WIDTH-1:1]}; 
				MOSI = transmission_reg[0]; 
			end
			else begin//MSB first shift LEFT
				transmission_reg = {transmission_reg[DATA_WIDTH-2:0],1'b1}; 
				MOSI = transmission_reg[DATA_WIDTH-1]; 
			end
		end
	end 
end 

endmodule
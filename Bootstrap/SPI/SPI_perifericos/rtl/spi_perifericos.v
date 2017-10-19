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
El parametro down_clocl determina el tiempo que se quedará en bajo la señal de reloj, 
despues de haber enviado un dato. Es ajustable por la necesidad del periferico. Si se 
escribe el valor de 1 se agregará de tiempo el inverso de la frecuencia de la señal 
de reloj del SPI.
**************************************************************************************/
parameter down_clock 		= 9;

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
output wire	[2*DATA_WIDTH-1:0]  spi_data_o;
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
reg [1:0]				flag_edge_detector;//***DETECTOR DE RELOJ MASTER
reg [11:0]				word_counter_send;//****CONTADOR DE BYTES ENVIADOS
reg [1:0]				state, next_state; //***MAQUINA DE ESTADOS
reg						clear_reg_word; //******LIMPIA REGISTROS DE CUENTA DE BYTES
reg [2*DATA_WIDTH-1:0]	reg_data_MISO; //*******REGISTRO DE DATOS FINAL
reg						SCK;//******************RELOJ INTERNO DEL SPI
reg 					complete_word; //*******Se completo envio de una palabra	

//***********************Division de la señal spi_statusreg_i*************************
wire						spi_fbo_i;
wire						spi_microSDwr_i;
wire						spi_microSDrd_i;
wire 						spi_operation_i;
wire						enable_operation;
wire [4:0]				clock_divider;
assign spi_operation_i	=	spi_statusreg_i[0];
assign spi_fbo_i		=	spi_statusreg_i[1];
assign enable_operation	=	spi_statusreg_i[5];
assign clock_divider	=	(spi_statusreg_i[4:2]==3'b000) ? 5'h00: (spi_statusreg_i[4:2]==3'b001) ? 5'h01 : (spi_statusreg_i[4:2]==3'b010) ? 5'h03 :
							(spi_statusreg_i[4:2]==3'b011) ? 5'h07 : 5'h0F;
				

//********ASIGNACIÓN DE SEÑALES DE SALIDA********************************************
assign SCK_SPI=(complete_word || word_counter == 8'h00 || word_counter == 8'h01)? 1'b0:SCK;
assign SS=(complete_word || word_counter == 8'h00)? 1'b1:1'b0;
assign spi_data_o = (complete_word || spi_doneflag_o) ? reg_data_MISO : spi_data_o;

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
	 case(state)
		idle:begin
			clear_reg	=	1'b1;
			complete_word = 1'b0;
			if(spi_operation_i && flag_edge_detector == 8'b10 && enable_operation)begin
					next_state	=	send;
					spi_doneflag_o	=	1'b0;
			end
		end 
		send:begin
			clear_reg	=	1'b0;
			if (word_counter_send == 12'h002)begin //corroborar
				next_state	=	finish;
			end
			case(word_counter_send) //modificar tamano de palabra es modificar esta seccion
				8'h00: begin data_out_MOSI = spi_data_i; reg_data_MISO[2*DATA_WIDTH-1:DATA_WIDTH] = received_reg; end
				8'h01: begin data_out_MOSI = 0; reg_data_MISO[DATA_WIDTH-1:0] = received_reg; end
				8'h02: begin complete_word = 1'b1; end
			endcase
		
		end//send
			
		finish:begin
			clear_reg	=	1'b1;
			next_state	=	idle;
			spi_doneflag_o	=	1'b1;
			complete_word = 1'b0;
		end
		
		default: next_state	=	finish;
	endcase
end
//*************************Transición de estados*********************************
always@(posedge spi_clk_i  or posedge spi_rst_i) begin
	if(spi_rst_i) 
		state <= finish;
	else 
		state <= next_state;
 end

//*************************Generador de reloj SPI*********************************

always @(negedge spi_clk_i or posedge spi_rst_i or posedge clear_reg_word) begin
  if(spi_rst_i || clear_reg_word ) begin
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
 //***********************Detector de flancos*************************************
always@(negedge spi_clk_i or posedge spi_rst_i)begin
	if(spi_rst_i)begin
		flag_edge_detector = 2'b00;
	end
	else begin
		flag_edge_detector = {SCK,flag_edge_detector[1]};
	end
end	
//***********************Cuenta de bits y palabras********************************
//**************REINICIA CONTADOR DE BITS*****************************************
always @(posedge spi_clk_i)begin
	if(word_counter == 8'h09 && flag_edge_detector == 2'b01)begin
		clear_reg_word <= 1'b1;
	end
	else begin
		clear_reg_word <= 1'b0;
	end
end
//*************Cuenta palabras enviadas*******************************************
always @(posedge spi_clk_i or posedge spi_rst_i or posedge clear_reg)begin
	if(spi_rst_i || clear_reg) begin
		word_counter_send <= 12'h00;
	end
	else if(word_counter == 8'h09 && flag_edge_detector == 2'b01)begin
		word_counter_send <= word_counter_send + 12'h001;
	end
end
//**************Cuenta bits enviados***********************************************
 always@(posedge SCK or posedge spi_rst_i or posedge clear_reg_word or posedge clear_reg) begin
	if(clear_reg_word || spi_rst_i || clear_reg)  begin
		word_counter <= 8'd0;  
	end
    else begin 
		word_counter <= word_counter + 8'd1;
	end 
end
 //****************Registros y procesos de salida e ingreso de datos***************
 //*********MISO INPUT DATA PROCESS************************************************
 always@(posedge SCK or posedge spi_rst_i or posedge clear_reg_word or posedge clear_reg) begin
	if(clear_reg_word || spi_rst_i || clear_reg)  begin
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
always@(negedge SCK or posedge spi_rst_i or posedge clear_reg_word or posedge clear_reg) begin
	if(clear_reg_word || spi_rst_i || clear_reg) begin
	  transmission_reg = 8'hFF;  
	  MOSI = 1'b1;  
	end  
	else begin
		if(word_counter == 8'h01  ) begin //load data into transmission_reg
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
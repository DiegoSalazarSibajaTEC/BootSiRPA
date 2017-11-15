`timescale 1ns / 1ps
//http://bikealive.nl/sd-v2-initialization.html
/***************************************************************
Bootstrap DCILAB 2017
Instituto Tecnológico de Costa Rica

Diego Salazar Sibaja

Modulo: SPI perifericos

Descripción general: Este módulo se encarga de realizar una comunicación SPI con una microSD.
El mismo es un código de un SPI master o host. Es capaz de enviar comandos con distintos 
tamaños de recepción de respuesta.

****************************************************************/
module spi_microSD(spi_clk_i, spi_rst_i, spi_data_i, spi_data_o, MOSI, MISO, SCK_SPI, SS, R1, spi_flagreg_o, spi_statusreg_i);

/***************************************************************************************
Parametros de tamaño de palabra de entrada y palabras de salida.
**************************************************************************************/
parameter word_in_width   	= 48;
parameter word_out_width 	= 32;	
/***************************************************************************************
El parametro down_clocl determina el tiempo que se quedará en bajo la señal de reloj, 
despues de haber enviado un dato. Es ajustable por la necesidad del periferico. Si se 
escribe el valor de 1 se agregará de tiempo el inverso de la frecuencia de la señal 
de reloj del SPI.
**************************************************************************************/
parameter down_clock 		= 9;//tiempo que al terminar una palabra se queda en bajo el clock

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
	[1] SS --> Indica cuando SS estara en alto o bajo 1:HIGH/0:LOW
	[2] FBO --> Indica si el primer bit de salida es MSB o LSB 1:MSB/0LSB
	[3] WR_EN --> Indica si se va a enviar un comando de escritura 1:Habilitado/0:desabilitado
	[4] RD_EN --> Indica si se va a enviar un comando de lectura 1:Habilitado/0:desabilitado
	[5:7] Divisor --> Indica en que escala se divide el SCK SPI con respector al reloj 
					  master. 000= 1:1, 001= 1:2, 010= 1:4, 011= 1:8, 1xx=1:16
	[8] Enable--> Habilita operacion de SPI microSD 1:Habilitado/0:desabilitado
**************************************************************************************/
input		[8:0]					spi_statusreg_i;
input 								spi_clk_i;//****Reloj master
input 								spi_rst_i;//****Reset master 1:Reset/0:No reset
input 	   	[word_in_width-1:0]		spi_data_i;//****Datos de entrada para envío
input 								MISO;//**********Salida MISO del SPI
/***************************************************************************************
La señal spi_flagreg_i es una serie de banderas que finalización de eventos. Se describe como:
	[0] WORD_COM --> Indica cuando se completo el envio o recepción de una
		palabra 1:Completado/0:No Completo
	[1] OPERT_DONE --> Indica cuando se completo el envio de un comando  1:Completado/0:No Completo
	[2] DATA_WR --> Indica cuando se debe enviar los datos a enviar 1:Habilitado/0:desabilitado
**************************************************************************************/
output wire	[2:0]					spi_flagreg_o;
output reg	[word_out_width-1:0]  	spi_data_o;
output reg							MOSI;
output reg							SS;
output reg 	[7:0]					R1;
output wire							SCK_SPI;
//**************************************************************************************

//*************************Señales internas********************************************
reg	[4:0]				counter_divider;//********CONTADOR PARA DIVISOR DE FRECUENCIA
reg [7:0]				word_counter;//***********CUENTA LOS BITS DE ENTRADA
reg [7:0]				received_reg;//***********REGISTRO DE DATO RECIBIDO
reg [7:0]				transmission_reg;//*******REGISTRO DE DATO A ENVIAR
reg [7:0]				data_out_MOSI;//**********DIVIDE LAS PALABRAS EN BYTES
reg						clear_reg; //*************LIMPIA REGISTROS DE CUENTAS
reg [1:0]				flag_edge_detector;//*****DETECTOR DE RELOJ MASTER
reg [11:0]				word_counter_send;//******CONTADOR DE BYTES ENVIADOS
reg [7:0]				word_counter_wroper;//****CONTADOR PALABRAS DE 32 BITS ENVIADAS
reg [1:0]				state, next_state; //*****MAQUINA DE ESTADOS
reg						clear_reg_word; //********LIMPIA REGISTROS DE CUENTA DE BYTES
reg [word_out_width-1:0]reg_data_MISO; //*********REGISTRO DE DATOS FINAL
reg						SCK;//********************RELOJ INTERNO DEL SPI

//***********************Division de la señal spi_statusreg_i*************************
wire						spi_fbo_i;
wire						spi_microSDwr_i;
wire						spi_microSDrd_i;
wire 						spi_operation_i;
wire 						spi_initSS_i;//init control
wire 						spi_enableoper;
wire [4:0]					clock_divider;
assign spi_operation_i	=	spi_statusreg_i[0];
assign spi_initSS_i		=	spi_statusreg_i[1];
assign spi_fbo_i		=	spi_statusreg_i[2];
assign spi_microSDwr_i	=	spi_statusreg_i[3];
assign spi_microSDrd_i	=	spi_statusreg_i[4];
assign clock_divider	=	(spi_statusreg_i[7:5]==3'b000) ? 5'h00: (spi_statusreg_i[7:5]==3'b001) ? 5'h01 : (spi_statusreg_i[7:5]==3'b010) ? 5'h03 :
							(spi_statusreg_i[7:5]==3'b011) ? 5'h07 : 5'h0F;
assign spi_enableoper   =   spi_statusreg_i[8];
							
//***********************Composición de la señal spi_flagreg_i*************************
reg							spi_doneflag_o;
reg							spi_flagdatawr_o;
reg 						complete_word;					
assign spi_flagreg_o[0]= (word_counter == 8'h08 && flag_edge_detector == 2'b01) ? complete_word : 1'b0;							
assign spi_flagreg_o[1]= spi_doneflag_o;	
assign spi_flagreg_o[2]= spi_flagdatawr_o;	

//********ASIGNACIÓN DE SEÑALES DE SALIDA********************************************
assign SCK_SPI=(complete_word || word_counter == 8'h00 || word_counter == 8'h01)? 1'b0:SCK;
always @(posedge spi_clk_i) begin
	if(complete_word || spi_doneflag_o) begin
		spi_data_o <= reg_data_MISO;
	end
	else begin
		spi_data_o <= spi_data_o;
	end
end		
				
/****************************M�?QUINA DE ESTADO***************************************
En esta máquina de estados se tiene tres estados.
	idle: Cuando el módulo esta habilitado([5] de spi_statusreg_i), espera a que se 
	habilite el envio de un dato con [0] de spi_statusreg_i.
	send: Se realiza el envio de datos. Cuando se envie las dos palabra se habilita el
	siguiente estado. Depende el comando puede variari el tamaño de palabras.
	finish: En este estado se limpia registros de cuentas de bits y palabras, además
	de que se levanta banderas del spi_flagreg_i.
***********************************************************************************/
always @* begin
	 next_state = state;
	 clear_reg	=	1'b0;
	 spi_doneflag_o	=	1'b0;
	 SS = 1'b1;
	 case(state)
		idle:begin
			clear_reg	=	1'b1;
			SS = 1'b0;
			if(spi_operation_i && flag_edge_detector == 8'b10 && spi_enableoper)begin
					next_state	=	send;
					spi_doneflag_o	=	1'b0;
			end
		end 
		send:begin
			clear_reg	=	1'b0;
			spi_doneflag_o	=	1'b0;
			if(spi_initSS_i)begin
				SS = 1'b1;
			end
			else begin
				SS = 1'b0;
			end
			clear_reg	=	1'b0;
			if (word_counter_send == 12'h00F && !spi_microSDwr_i && !spi_microSDrd_i)begin //corroborar
				next_state	=	finish;
			end
			else if (word_counter_send == 12'h600 && !spi_microSDwr_i && spi_microSDrd_i)begin //revisar
					next_state	=	finish;
			    end
				else if (word_counter_send == 12'h600 && spi_microSDwr_i && !spi_microSDrd_i)begin
					next_state	=	finish;
				end
		end
		finish:begin
			if(spi_initSS_i)begin
				SS = 1'b1;
			end
			else begin
				SS = 1'b0;
			end
			clear_reg	=	1'b1;
			next_state	=	idle;
			spi_doneflag_o	=	1'b1;
		end
		
		default: next_state	=	finish;
	endcase
end
/****************************Asignacion de valores***************************************
En las siguientes instancias se definiran los valores para las señales R1, reg_data_MISO,
data_out_MOSI, complete_word y spi_flagdatawr_o
***********************************************************************************/
always@(posedge spi_clk_i) begin
	if(spi_rst_i)begin
		R1 <= 8'hzz;
	end
	else begin
		if(word_counter == 8'h09 && flag_edge_detector == 2'b11 && word_counter_send==12'h007)begin
			R1 <= received_reg;
		end
		else begin
			R1 <= R1;
		end
	end
end

always@(posedge spi_clk_i) begin
	if(spi_rst_i)begin
		reg_data_MISO <= 32'h00000000;
	end
	else begin
		if(word_counter_send == (12'h00A+(12'h005*word_counter_wroper)))begin
			reg_data_MISO[31:24] <= received_reg; 
		end
		else begin
			if(word_counter_send == (12'h00B+(12'h005*word_counter_wroper)))begin
				reg_data_MISO[23:16] <= received_reg; 
			end
			else begin
				if(word_counter_send == (12'h00C+(12'h005*word_counter_wroper)))begin
					reg_data_MISO[15:8] <= received_reg; 
				end
				else begin
					if(word_counter_send == (12'h00D+(12'h005*word_counter_wroper)))begin
						reg_data_MISO[7:0] <= received_reg; 
					end
					else begin
						reg_data_MISO <= reg_data_MISO;
					end
				end
			end
		end
	end
end

always@* begin
	data_out_MOSI = 8'hFF;
	complete_word = 1'b0;
	spi_flagdatawr_o = 1'b0; 
	//reg_data_MISO = 32'h
	case(word_counter_send) //modificar tamano de palabra es modificar esta seccion
		12'h000: begin 	data_out_MOSI = spi_data_i[47:40]; 
						complete_word =1'b0; 
						spi_flagdatawr_o = 1'b0; 
				end
		12'h001: begin 	data_out_MOSI = spi_data_i[39:32]; 
						complete_word =1'b0; 
						spi_flagdatawr_o = 1'b0; 
				end
		12'h002: begin 	data_out_MOSI = spi_data_i[31:24]; 
						complete_word =1'b0; 
						spi_flagdatawr_o = 1'b0; 
				end
		12'h003: begin 	data_out_MOSI = spi_data_i[23:16];
						complete_word =1'b0; 
						spi_flagdatawr_o = 1'b0; 
				end
		12'h004: begin 	data_out_MOSI = spi_data_i[15:8];
						complete_word =1'b0; 
						spi_flagdatawr_o = 1'b0; 
				end
		12'h005: begin 	data_out_MOSI = spi_data_i[7:0]; 
						complete_word =1'b0; 
						spi_flagdatawr_o = 1'b0; 
				end
		12'h006: begin 	data_out_MOSI = 8'hFF;
						complete_word =1'b0; 
						spi_flagdatawr_o = 1'b0; 
				end
		12'h007: begin 	data_out_MOSI = 8'hFF;
						complete_word =1'b0; 
						spi_flagdatawr_o = 1'b0; 
				end
		12'h008: begin 	
						data_out_MOSI = 8'hFF;
						complete_word =1'b0;
						if(spi_microSDwr_i)begin 
								spi_flagdatawr_o = 1'b1; 
						end 
						else begin 
								spi_flagdatawr_o = 1'b0; 
						end 
				end  //BITS EN ALTO
						
		12'h009: begin 
						complete_word =1'b0;
						if(spi_microSDwr_i)begin 
							data_out_MOSI = 8'hFE;
						end 
						if(spi_microSDwr_i)begin 
								spi_flagdatawr_o = 1'b1; 
						end 
						else begin 
								spi_flagdatawr_o = 1'b0; 
						end 
				end //START BLOCK TOKENS
		
		12'h00A+(12'h005*word_counter_wroper): begin //FIRST BYTE
						complete_word =1'b0;
						if(spi_microSDwr_i)begin 
							data_out_MOSI = spi_data_i[47:40];
							spi_flagdatawr_o = 1'b1;							
						end 
						else begin 
							spi_flagdatawr_o = 1'b0; 
							if(spi_microSDrd_i) begin 
								data_out_MOSI = 8'hFF;
							end
						end
				end
						
		12'h00B+(12'h005*word_counter_wroper): begin //SECOND BYTE
						complete_word =1'b0;
						if(spi_microSDwr_i)begin 
							data_out_MOSI = spi_data_i[39:32];
							spi_flagdatawr_o = 1'b1;							
						end 
						else begin 
							spi_flagdatawr_o = 1'b0; 
							if(spi_microSDrd_i) begin 
								data_out_MOSI = 8'hFF;
							end
						end
				end
				
		12'h00C+(12'h005*word_counter_wroper): begin //THIRD BYTE
						complete_word =1'b0;
						if(spi_microSDwr_i)begin 
							data_out_MOSI = spi_data_i[31:24];
							spi_flagdatawr_o = 1'b1;							
						end 
						else begin 
							spi_flagdatawr_o = 1'b0; 
							if(spi_microSDrd_i) begin 
								data_out_MOSI = 8'hFF;
							end
						end
				end
		12'h00D+(12'h005*word_counter_wroper): begin //FOURTH BYTE
						complete_word =1'b0;
						if(spi_microSDwr_i)begin 
							data_out_MOSI = spi_data_i[23:16];
							spi_flagdatawr_o = 1'b1;							
						end 
						else begin 
							spi_flagdatawr_o = 1'b0; 
							if(spi_microSDrd_i) begin 
								data_out_MOSI = 8'hFF;
							end
						end
				end

		12'h00E+(12'h005*word_counter_wroper): begin //END WORD
					data_out_MOSI = 8'hFF;
					if(spi_microSDwr_i)begin
						complete_word = 1'b1;
						spi_flagdatawr_o = 1'b1;
					end
					else begin
						if(spi_microSDrd_i)begin
							complete_word = 1'b1;
							spi_flagdatawr_o = 1'b0;
						end
						else begin
							complete_word = 1'b0;
							spi_flagdatawr_o = 1'b0;
						end
					end
				end
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
//*************Cuenta palabras enviadas*******************************************
always @(posedge spi_clk_i or posedge spi_rst_i or posedge clear_reg)begin
	if(spi_rst_i || clear_reg) begin
		word_counter_send <= 12'h00;
	end
	else if((word_counter == 8'h09 && flag_edge_detector == 2'b01)||(word_counter_send > 12'h009 && word_counter == down_clock && complete_word && flag_edge_detector == 2'b01))begin//!spi_protocole_i && word_counter == 8'h09 && flag_edge_detector == 2'b01
		word_counter_send <= word_counter_send + 12'h001;
	end
end
//**************REINICIA CONTADOR DE BITS*****************************************
always @(posedge spi_clk_i)begin
	if((word_counter == 8'h09 && flag_edge_detector == 2'b01) || (word_counter_send > 12'h009 && word_counter == down_clock && complete_word && flag_edge_detector == 2'b01))begin
		clear_reg_word <= 1'b1;
	end
	else begin
		clear_reg_word <= 1'b0;
	end
end
//***************OPERACION DE CONTADOR DE PALABRAS*********************************
always @(posedge spi_clk_i or posedge spi_rst_i)begin
	if(spi_rst_i || clear_reg) begin
		word_counter_wroper <= 8'h00;
	end
	else if(word_counter_send > 12'h009 && word_counter == down_clock && complete_word && flag_edge_detector == 2'b01) begin
			word_counter_wroper <= word_counter_wroper + 8'h01;
		end
		else begin
			word_counter_wroper <= word_counter_wroper;
		end
end
//**************Cuenta bits enviados***********************************************
 always@(posedge SCK or posedge spi_rst_i or posedge clear_reg_word or posedge clear_reg) begin
	if(clear_reg_word || spi_rst_i || clear_reg)  begin
		word_counter <= 8'd0;  
	end
    else begin 
		word_counter <= word_counter + 8'h01;
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
			begin  received_reg = {MISO,received_reg[7:1]};  end 
		  else  
			begin  received_reg = {received_reg[6:0],MISO};  end
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
			MOSI= spi_fbo_i ? transmission_reg[7]:transmission_reg[0];
		end 
		else begin
			if(spi_fbo_i == 1'b0) begin //LSB first, shift right
				transmission_reg = {1'b1,transmission_reg[7:1]}; 
				MOSI = transmission_reg[0]; 
			end
			else begin//MSB first shift LEFT
				transmission_reg = {transmission_reg[6:0],1'b1}; 
				MOSI = transmission_reg[7]; 
			end
		end
	end 
end 

endmodule

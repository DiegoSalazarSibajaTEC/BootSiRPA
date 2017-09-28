`timescale 1ns / 1ps
//http://bikealive.nl/sd-v2-initialization.html
module spi_microSD(spi_clk_i, spi_rst_i, spi_data_i, spi_data_o, MOSI, MISO, SCK_SPI, SS, R1, spi_flagreg_o, spi_statusreg_i, spi_enableoper_i);

parameter word_in_width   	= 48;
parameter word_out_width 	= 32;	
parameter down_clock 		= 9;//tiempo que al terminar una palabra se queda en bajo el clock

parameter 	idle=2'b00;		
parameter 	send=2'b10; 
parameter 	finish=2'b11; 

input		[7:0]				spi_statusreg_i;
input 							spi_clk_i;
input 							spi_rst_i;
input 	   [word_in_width-1:0]	spi_data_i;
input 							MISO;
input 							spi_enableoper_i;
output wire[2:0]				spi_flagreg_o;
output reg[word_out_width-1:0]  spi_data_o;
output reg						MOSI;
output reg						SS;
output reg [7:0]				R1;
output wire						SCK_SPI;

//INTERNAL SIGNALS
reg	[4:0]				counter_divider;//CONTADOR PARA DIVISOR DE FRECUENCIA
reg [7:0]				word_counter;//CUENTA LOS BITS DE ENTRADA
reg [7:0]				received_reg;//REGISTRO DE DATO RECIBIDO
reg [7:0]				transmission_reg;//REGISTRO DE DATO A ENVIAR
reg [7:0]				data_out_MOSI;//DIVIDE LAS PALABRAS EN BYTES
reg						clear_reg; //LIMPIA REGISTROS DE CUENTAS
reg [1:0]				flag_edge_detector;//DETECTOR DE RELOJ MASTER
reg [11:0]				word_counter_send;//CONTADOR DE BYTES ENVIADOS
reg [7:0]				word_counter_wroper;//CONTADOR PALABRAS DE 32 BITS ENVIADAS
reg [1:0]				state, next_state; //MAQUINA DE ESTADOS
reg						clear_reg_word; //LIMPIA REGISTROS DE CUENTA DE BYTES
reg [word_out_width-1:0]reg_data_MISO; //REGISTRO DE DATOS FINAL
reg						SCK;//RELOJ INTERNO DEL SPI

//STATUS REG
wire						spi_fbo_i;
wire						spi_microSDwr_i;
wire						spi_microSDrd_i;
wire 						spi_operation_i;
wire 						spi_initSS_i;//0 is  microSD  1 is arduino
assign spi_operation_i	=	spi_statusreg_i[0];
assign spi_initSS_i		=	spi_statusreg_i[1];
assign spi_fbo_i		=	spi_statusreg_i[2];
assign spi_microSDwr_i	=	spi_statusreg_i[3];
assign spi_microSDrd_i	=	spi_statusreg_i[4];
assign clock_divider	=	(spi_statusreg_i[7:5]==3'b000) ? 5'h00: (spi_statusreg_i[7:5]==3'b001) ? 5'h01 : (spi_statusreg_i[7:5]==3'b010) ? 5'h03 :
							(spi_statusreg_i[7:5]==3'b011) ? 5'h07 : 5'h0F;
							
//FLAG REG
reg							spi_doneflag_o;
reg							spi_flagdatawr_o;
reg 						complete_word;					
assign spi_flagreg_o[0]= complete_word;							
assign spi_flagreg_o[1]= spi_doneflag_o;	
assign spi_flagreg_o[2]= spi_flagdatawr_o;	

//SCK OUT AND DATA OUT
assign SCK_SPI=(complete_word || word_counter == 8'h00 || word_counter == 8'h01)? 1'b0:SCK;

always @* begin
	if(complete_word || spi_doneflag_o) begin
		spi_data_o <= reg_data_MISO;
	end
	else begin
		spi_data_o <= spi_data_o;
	end
end						


always @* begin
	 next_state = state;
	 clear_reg	=	1'b0;
	 case(state)
		idle:begin
			clear_reg	=	1'b1;
			if(spi_operation_i && flag_edge_detector == 8'b10 && spi_enableoper_i)begin
					next_state	=	send;
					spi_doneflag_o	=	1'b0;
			end
		end 
		send:begin
			clear_reg	=	1'b0;
			if(spi_initSS_i)begin
				SS = 1'b1;
			end
			else begin
				SS = 1'b0;
			end
			clear_reg	=	1'b0;
			if (word_counter_send == 12'h013 && !spi_microSDwr_i && !spi_microSDrd_i)begin //corroborar
				next_state	=	finish;
			end
			else if (word_counter_send == 12'h268 && !spi_microSDwr_i && spi_microSDrd_i)begin //revisar
					next_state	=	finish;
			    end
				else if (word_counter_send == 12'h2BC && spi_microSDwr_i && !spi_microSDrd_i)begin
					next_state	=	finish;
				end
		end//send
			
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
end//always

always@* begin
	case(word_counter_send) //modificar tamano de palabra es modificar esta seccion
		12'h000: begin data_out_MOSI = spi_data_i[47:40]; complete_word =1'b0; spi_flagdatawr_o = 1'b0; R1=8'h00; end
		12'h001: begin data_out_MOSI = spi_data_i[39:32]; end
		12'h002: begin data_out_MOSI = spi_data_i[31:24]; end
		12'h003: begin data_out_MOSI = spi_data_i[23:16]; end
		12'h004: begin data_out_MOSI = spi_data_i[15:8]; end
		12'h005: begin data_out_MOSI = spi_data_i[7:0]; end
		12'h006: begin data_out_MOSI = 8'hFF; end
		12'h007: begin R1 = (word_counter == 8'h09 && flag_edge_detector == 2'b11)? received_reg:R1; end
		12'h008: begin if(spi_microSDwr_i)begin spi_flagdatawr_o = 1'b1; end 
						else begin spi_flagdatawr_o = 1'b0; end end  //BITS EN ALTO
		12'h009: begin if(spi_microSDwr_i || spi_microSDrd_i )begin data_out_MOSI = 8'hFE;end end //START BLOCK TOKENS
		12'h00A+(12'h005*word_counter_wroper): begin //FIRST BYTE
				if(spi_microSDwr_i)begin data_out_MOSI = spi_data_i[47:40]; end 
				else if(spi_microSDrd_i) begin data_out_MOSI = 8'hFF; end
				reg_data_MISO[31:24]=received_reg; 
				complete_word =1'b0;
				end
		12'h00B+(12'h005*word_counter_wroper): begin //SECOND BYTE
				if(spi_microSDwr_i)begin data_out_MOSI = spi_data_i[39:32]; end 
				reg_data_MISO[23:16] = received_reg;
				end
		12'h00C+(12'h005*word_counter_wroper): begin //THIRD BYTE
				if(spi_microSDwr_i)begin data_out_MOSI = spi_data_i[31:24]; end 
				reg_data_MISO[15:8] = received_reg;
				end
		12'h00D+(12'h005*word_counter_wroper): begin //FOURTH BYTE
				if(spi_microSDwr_i)begin data_out_MOSI = spi_data_i[23:16]; end 
				reg_data_MISO[7:0] = received_reg; 
				end
		12'h00E+(12'h005*word_counter_wroper): begin //END WORD
					data_out_MOSI = 8'hFF;
					if(spi_microSDwr_i || spi_microSDrd_i)begin
						complete_word = 1'b1;
					end
					else begin
						complete_word = 1'b0;
					end
				end
	endcase
end




//state transistion
always@(posedge spi_clk_i  or posedge spi_rst_i) begin
	if(spi_rst_i) 
		state <= idle;
	else 
		state <= next_state;
 end

	
//SPI SCK CLOCK GENERATOR
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
 
 //FLAG EDGE DETECTOR
always@(negedge spi_clk_i or posedge spi_rst_i)begin
	if(spi_rst_i)begin
		flag_edge_detector = 2'b00;
	end
	else begin
		flag_edge_detector = {SCK,flag_edge_detector[1]};
	end
end	
 
  //CUENTAS DE PALABRAS Y PROCESOS
always @(posedge spi_clk_i or posedge spi_rst_i or posedge clear_reg)begin
	if(spi_rst_i || clear_reg) begin
		word_counter_send <= 12'h00;
	end
	else if((word_counter == 8'h09 && flag_edge_detector == 2'b01)||(word_counter_send > 12'h009 && word_counter == down_clock && complete_word && flag_edge_detector == 2'b01))begin//!spi_protocole_i && word_counter == 8'h09 && flag_edge_detector == 2'b01
		word_counter_send <= word_counter_send + 12'h001;
	end
end
//REINICIA CONTADOR DE BITS
always @(posedge spi_clk_i)begin
	if((word_counter == 8'h09 && flag_edge_detector == 2'b01) || (word_counter_send > 12'h009 && word_counter == down_clock && complete_word && flag_edge_detector == 2'b01))begin
		clear_reg_word <= 1'b1;
	end
	else begin
		clear_reg_word <= 1'b0;
	end
end
	//OPERACION DE CONTADOR DE PALABRAS
	
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
 
//BIT COUNTER REG
 always@(posedge SCK or posedge spi_rst_i or posedge clear_reg_word or posedge clear_reg) begin
	if(clear_reg_word || spi_rst_i || clear_reg)  begin
		word_counter <= 8'd0;  
	end
    else begin 
		word_counter <= word_counter + 8'h01;
	end 
end
 
 
 //MISO INPUT DATA PROCESS
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


//MOSI OUTPUT DATA
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
`timescale 1ns / 1ps
//http://bikealive.nl/sd-v2-initialization.html
module spi_perifericos#(parameter DATA_WIDTH=8)(spi_clk_i, spi_rst_i, spi_data_i, spi_data_o, MOSI, MISO, SCK_SPI, SS, spi_doneflag_o, spi_statusreg_i);


parameter down_clock 		= 9;//tiempo que al terminar una palabra se queda en bajo el clock

parameter 	idle=2'b00;		
parameter 	send=2'b10; 
parameter 	finish=2'b11; 

input		[5:0]				spi_statusreg_i;
input 							spi_clk_i;
input 							spi_rst_i;
input 	   	[DATA_WIDTH-1:0]	spi_data_i;
input 							MISO;
output reg						spi_doneflag_o;
output wire	[2*DATA_WIDTH-1:0]  spi_data_o;
output reg						MOSI;
output wire						SS;
output wire						SCK_SPI;

//INTERNAL SIGNALS
reg	[4:0]				counter_divider;//CONTADOR PARA DIVISOR DE FRECUENCIA
reg [7:0]				word_counter;//CUENTA LOS BITS DE ENTRADA
reg [7:0]				received_reg;//REGISTRO DE DATO RECIBIDO
reg [DATA_WIDTH-1:0]	transmission_reg;//REGISTRO DE DATO A ENVIAR
reg [DATA_WIDTH-1:0]	data_out_MOSI;//DIVIDE LAS PALABRAS EN BYTES
reg						clear_reg; //LIMPIA REGISTROS DE CUENTAS
reg [1:0]				flag_edge_detector;//DETECTOR DE RELOJ MASTER
reg [11:0]				word_counter_send;//CONTADOR DE BYTES ENVIADOS
reg [1:0]				state, next_state; //MAQUINA DE ESTADOS
reg						clear_reg_word; //LIMPIA REGISTROS DE CUENTA DE BYTES
reg [2*DATA_WIDTH-1:0]	reg_data_MISO; //REGISTRO DE DATOS FINAL
reg						SCK;//RELOJ INTERNO DEL SPI

//STATUS REG
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
							
//FLAG REG
reg 						complete_word;						

//SCK OUT AND DATA OUT
assign SCK_SPI=(complete_word || word_counter == 8'h00 || word_counter == 8'h01)? 1'b0:SCK;
assign SS=(complete_word || word_counter == 8'h00)? 1'b1:1'b0;
assign spi_data_o = (complete_word || spi_doneflag_o) ? reg_data_MISO : spi_data_o;

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
//state transistion
always@(posedge spi_clk_i  or posedge spi_rst_i) begin
	if(spi_rst_i) 
		state <= finish;
	else 
		state <= next_state;
 end

//-----------------CLOCK GENERATOR---------------------	
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
 //------------CUENTA DE BITS Y PALABRAS---------------
//REINICIA CONTADOR DE BITS
always @(posedge spi_clk_i)begin
	if(word_counter == 8'h09 && flag_edge_detector == 2'b01)begin
		clear_reg_word <= 1'b1;
	end
	else begin
		clear_reg_word <= 1'b0;
	end
end
//CUENTAS DE PALABRAS Y PROCESOS
always @(posedge spi_clk_i or posedge spi_rst_i or posedge clear_reg)begin
	if(spi_rst_i || clear_reg) begin
		word_counter_send <= 12'h00;
	end
	else if(word_counter == 8'h09 && flag_edge_detector == 2'b01)begin
		word_counter_send <= word_counter_send + 12'h001;
	end
end
//BIT COUNTER REG
 always@(posedge SCK or posedge spi_rst_i or posedge clear_reg_word or posedge clear_reg) begin
	if(clear_reg_word || spi_rst_i || clear_reg)  begin
		word_counter <= 8'd0;  
	end
    else begin 
		word_counter <= word_counter + 8'd1;
	end 
end
 //--------------ENVIO Y RECEPCION---------------
 //MISO INPUT DATA PROCESS
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
//MOSI OUTPUT DATA
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
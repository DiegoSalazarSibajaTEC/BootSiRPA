`timescale 1ns / 1ps
//http://bikealive.nl/sd-v2-initialization.html
module spi(spi_clk_i, spi_rst_i, spi_data_i, spi_data_o, spi_protocole_i, spi_operation_i, MOSI, MISO, SCK, SS, spi_doneflag_o, 
				spi_fbo_i , spi_microSDwr_i, spi_microSDrd_i,spi_doneword_o, spi_flagdatawr_o, R1, SCK_SPI);
parameter word_widht   = 48;
parameter word_out_wid = 80;	
parameter word_to_send = 8;
parameter freq_divisor = 5'd10;
//parameter spi_fbo	   = 0; // 1 LSB first 0 MSB first
parameter 	idle=2'b00;		
parameter 	send=2'b10; 
parameter 	finish=2'b11; 

input 						spi_clk_i;
input 						spi_rst_i;
input 	   [word_widht-1:0]	spi_data_i;
input 						spi_operation_i;
input 						spi_protocole_i;//0 is  microSD  1 is arduino
input 						MISO;
input						spi_fbo_i;
input						spi_microSDwr_i;
input						spi_microSDrd_i;
output wire[word_widht-1:0] spi_data_o;
output reg					MOSI;
output reg					SCK;
output reg					SS;
output reg [7:0]			R1;
output reg					spi_doneflag_o;
output wire					spi_doneword_o;
output reg					spi_flagdatawr_o;
output wire					SCK_SPI;

reg	[4:0]	counter_divider;
reg [7:0]	word_counter;
reg [7:0]	received_reg;
reg [7:0]	transmission_reg;
reg [7:0]	data_out_MOSI;
reg			clear_reg;
reg [7:0]	flag_edge_detector;
reg [11:0]	word_counter_send;
reg [7:0]	word_counter_wroper;
reg [1:0]	state, next_state;
reg			clear_reg_word;
reg [word_out_wid-1:0] reg_data_MISO;
reg 		complete_word;

always @(spi_operation_i or flag_edge_detector or word_counter_send or state) begin
	 next_state = state;
	 clear_reg	=	1'b0;
	 case(state)
		idle:begin
			clear_reg	=	1'b1;
			if(spi_operation_i && flag_edge_detector == 8'h80)begin
					next_state	=	send;
					spi_doneflag_o	=	1'b0;
			end
		end 
			
		send:begin
			clear_reg	=	1'b0;
			if(!spi_protocole_i)begin
				SS = 1'b0;
			end
			else begin
				SS = 1'b0;
			end
			clear_reg	=	1'b0;
			if (word_counter_send == 12'h013 && !spi_protocole_i && !spi_microSDwr_i && !spi_microSDrd_i)begin //corroborar
				next_state	=	finish;
			end
			else if (word_counter_send == 12'h002 && spi_protocole_i && !spi_microSDwr_i && !spi_microSDrd_i)begin //corroborar
				next_state	=	finish;
			end
			if (word_counter_send == 12'h268 && !spi_protocole_i && !spi_microSDwr_i && spi_microSDrd_i)begin //revisar
				next_state	=	finish;
			end
			else if (word_counter_send == 12'h2BC && !spi_protocole_i && spi_microSDwr_i && !spi_microSDrd_i)begin
				next_state	=	finish;
			end
		end//send
			
		finish:begin
			if(!spi_protocole_i)begin
				SS = 1'b0;
			end
			else begin
				SS = 1'b1;
			end
			clear_reg	=	1'b1;
			next_state	=	idle;
			spi_doneflag_o	=	1'b1;
		end
		
		default: next_state	=	finish;
	endcase
end//always

always@(word_counter or spi_data_i or received_reg or word_counter_wroper or spi_microSDrd_i or spi_microSDwr_i)begin
	if(!spi_protocole_i) begin
		case(word_counter_send) //modificar tamano de palabra es modificar esta seccion
			12'h000: begin data_out_MOSI = spi_data_i[47:40]; complete_word =1'b0; spi_flagdatawr_o = 1'b0; R1=8'h00; end
			12'h001: begin data_out_MOSI = spi_data_i[39:32]; end
			12'h002: begin data_out_MOSI = spi_data_i[31:24]; end
			12'h003: begin data_out_MOSI = spi_data_i[23:16]; end
			12'h004: begin data_out_MOSI = spi_data_i[15:8]; end
			12'h005: begin data_out_MOSI = spi_data_i[7:0]; end
			12'h006: begin data_out_MOSI = 8'hFF; end
			12'h007: begin R1 = (complete_word)? received_reg:R1; end
			12'h008: begin if(spi_microSDwr_i)begin spi_flagdatawr_o = 1'b1; end end  //bits en alto
			12'h009: begin if(spi_microSDwr_i)begin data_out_MOSI = 8'hFE;end end //start block token
			12'h00A+(12'h005*word_counter_wroper): begin 
					if(spi_microSDwr_i)begin data_out_MOSI = spi_data_i[47:40]; end 
					else if(spi_microSDrd_i) begin reg_data_MISO[31:24]=received_reg;end
					complete_word =1'b0;
					end
			12'h00B+(12'h005*word_counter_wroper): begin 
					if(spi_microSDwr_i)begin data_out_MOSI = spi_data_i[39:32]; end 
					else if(spi_microSDrd_i) begin reg_data_MISO[23:16] = received_reg; end
					end
			12'h00C+(12'h005*word_counter_wroper): begin 
					if(spi_microSDwr_i)begin data_out_MOSI = spi_data_i[31:24]; end 
					else if(spi_microSDrd_i) begin reg_data_MISO[15:8] = received_reg; end
					end
			12'h00D+(12'h005*word_counter_wroper): begin 
					if(spi_microSDwr_i)begin data_out_MOSI = spi_data_i[23:16]; end 
					else if(spi_microSDrd_i) begin reg_data_MISO[7:0] = received_reg; end
					end
			12'h00E+(12'h005*word_counter_wroper): begin 
					complete_word = 1'b1;
					end
		endcase
	end
	else begin
		case(word_counter_send) //modificar tamano de palabra es modificar esta seccion
			8'h00: begin data_out_MOSI = spi_data_i[47:40]; end
			8'h01: begin data_out_MOSI = 8'hFF; reg_data_MISO = {received_reg,72'h000000000}; end
		endcase
	end
end


assign spi_data_o = (complete_word)? reg_data_MISO:spi_data_o; 
assign spi_doneword_o = complete_word;

//state transistion
always@(posedge spi_clk_i  or posedge spi_rst_i) begin
	if(spi_rst_i) 
		state <= finish;
	else 
		state <= next_state;
 end

 
always @(posedge spi_clk_i or posedge spi_rst_i)begin
	if(spi_rst_i || clear_reg) begin
		word_counter_send <= 12'h00;
	end
	else if(!spi_protocole_i && word_counter == 8'h09 && flag_edge_detector == 8'h0F)begin
		word_counter_send <= word_counter_send + 12'h001;
	end
	
	if(word_counter == 8'h09 && flag_edge_detector == 8'h01)begin
		clear_reg_word <= 1'b1;
	end
	else begin
		clear_reg_word <= 1'b0;
	end
	if(spi_rst_i || clear_reg) begin
		word_counter_wroper <= 8'h00;
	end
	else if(word_counter_send > 12'h009 && word_counter == 8'h09 && complete_word && flag_edge_detector == 8'h0F) begin
			word_counter_wroper <= word_counter_wroper + 8'h01;
		end
		else begin
			word_counter_wroper <= word_counter_wroper;
		end
end


//FLAG EDGE DETECTOR
always@(posedge spi_clk_i or posedge spi_rst_i)begin
	if(spi_rst_i)begin
		flag_edge_detector = 8'h00;
	end
	else begin
		flag_edge_detector = {SCK,flag_edge_detector[7:1]};
	end
end	
	
//SPI SCK CLOCK GENERATOR
always @(negedge spi_clk_i or posedge spi_rst_i or posedge clear_reg_word) begin
  if(spi_rst_i || clear_reg_word ) begin
		counter_divider	=	5'h0; 
		SCK	= 1'b0; 
	end
  else begin
		counter_divider = counter_divider + 5'h01; 
		if(counter_divider == freq_divisor) begin
			SCK	=~ SCK;
			counter_divider = 5'h00;
		end 
	end 
	
 end 
 assign SCK_SPI=(complete_word || word_counter == 8'h00 || word_counter == 8'h01)? 1'b0:SCK;
 //WORD COUNTER REG
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
		  if(spi_fbo_i) 
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
`timescale 1ns / 1ps
//http://bikealive.nl/sd-v2-initialization.html
module controlmicro_sd(sd_address_i, control_rst_i, control_clk_i, control_we_i, control_re_i, control_dataw_i, MISO, control_nextoper_i, 
					  SCK, mem_data_o, MOSI, control_done_o, SS);

input		[31:0]	sd_address_i;
input 				control_rst_i;
input 				control_clk_i;
input 				control_we_i;
input 				control_re_i;
input 		[31:0]	control_dataw_i;
input 				MISO;
input				control_nextoper_i;
output 	reg			SCK;
output 	reg	[31:0] 	mem_data_o;
output 	reg			SS;
output 	reg			MOSI;
output	reg			control_done_o;
					
//INSTRUCTION
parameter IWAIT  = 48'hFFFFFFFFFFFF;
parameter ICMD0  = 48'h400000000095; //r1
parameter ICMD8  = 48'h48000001AA87; //r7 87 o 0F
parameter IACMD47= 48'h770000000001;
parameter ICMD58 = 48'h7A0000000001;

parameter RCMDX	 = 8'h01;
parameter RCMDY	 = 8'h00;


//STATE
parameter idle  = 3'b000;
parameter CMD0  = 3'b001;
parameter CMD8  = 3'b010;
parameter CMD58 = 3'b011;
parameter ACMD41= 3'b100;
parameter write = 3'b101;  //CRC off in SD Card
parameter read	= 3'b110;
parameter veri	= 3'b111;



parameter spi_fbo = 1'b1;//1= MLS first out 0= LSB first out
parameter divider = 5'd10; //tomar en cuenta clk de FPGA


//Internal signals

reg    	[2:0]  	state;
reg	   	[2:0]  	next_state;
reg	   	[4:0] 	counter_divider;
reg	   	[7:0]	edge_detector_reg;
reg				transmission;
reg	   	[7:0]	word_counter;
reg		[79:0]	received_reg;
reg		[47:0]	transmission_reg;
reg				write_enable_sd;
reg		[47:0]	instruction_sd;
reg 	[7:0]	R7;
reg		[7:0]	flag_edge_detector;
reg				flag;


always @(state or word_counter or R7 or received_reg or control_nextoper_i or control_we_i or control_re_i or sd_address_i or control_dataw_i)begin
	next_state = state;
	
	case(state)
		idle:begin
			transmission	=	1'b0;
			instruction_sd	=   IWAIT;
			mem_data_o		= 	32'hFFFFFFFF;
			write_enable_sd	= 	1'b0;
			SS = 1'b1;
			control_done_o	=	1'b0;
			flag			=	1'b0;
			case(word_counter)
				8'h89 : begin next_state 	= 	CMD0; end
				8'h8A : begin transmission	=	1'b1; end
			endcase
		end
		
		CMD0: begin
			transmission	=	1'b0;
			instruction_sd	=   ICMD0;
			write_enable_sd	= 	1'b0;
			mem_data_o		= 	32'hFFFFFFFF;
			SS = 1'b0;
			case(word_counter)
				8'h89 : begin next_state 	= 	CMD8; end
				8'h8A : begin transmission	=	1'b1; end
			endcase
		end
			
		CMD8: begin
			transmission	=	1'b0;
			instruction_sd	=   ICMD8;
			write_enable_sd	= 	1'b0;
			mem_data_o		= 	32'hFFFFFFFF;
			case(word_counter)
				8'h89 : begin next_state 	= 	ACMD41;end
				8'h8A : begin transmission	=	1'b1; end
			endcase
		end
		
		ACMD41: begin
			transmission	=	1'b0;
			instruction_sd	=   IACMD47;
			write_enable_sd	= 	1'b0;
			case (word_counter)
				8'h87: begin mem_data_o	=	received_reg[47:16]; R7	=	received_reg[79:72];end
				8'h89: begin if(R7 == RCMDX || R7 == RCMDY)begin next_state = CMD58;end end
				8'h8A: begin transmission	=	1'b1; end
			endcase		
		end
		
		CMD58: begin
			transmission	=	1'b0;
			instruction_sd	=   ICMD58;
			write_enable_sd	= 	1'b0;
			case (word_counter)
				8'h87: begin mem_data_o	=	received_reg[47:16]; R7	=	received_reg[79:72]; flag=1'b1;end
				8'h89: begin 
						if((R7 == RCMDX || R7 == RCMDY) && control_we_i && !control_re_i)begin 
							next_state 		= 	write; end
						else if((R7 == RCMDX || R7 == RCMDY) && !control_we_i && control_re_i) begin
							next_state 		= 	read; end
					   end
				8'h8A: begin transmission	=	1'b1; end
			endcase	
		end
		
		write: begin
			transmission	=	1'b0;
			write_enable_sd	= 	1'b1;
			control_done_o	=	1'b0;
			case (word_counter)
				8'h00: begin instruction_sd = {8'h58, sd_address_i , 8'h01 }; end
				8'h2F: begin instruction_sd = {8'b11111110,control_dataw_i,8'h00}; end
				8'h87: begin R7	=	received_reg[79:72]; end
			endcase
			if(flag)begin
				transmission = 1'b1;
				flag = 1'b0; 
			end
			if(word_counter > 8'h88 && (R7 ==RCMDX || R7 == RCMDY) && received_reg[1:0] == 2'b01) begin
				flag	=	1'b1;
				write_enable_sd	= 	1'b0;
				next_state 		= 	veri;
			end

		
		end
		
		read: begin //modificar
			transmission	=	1'b0;
			flag = 1'b0;
			write_enable_sd	= 	1'b0;
			control_done_o	=	1'b0;
			instruction_sd	=   {2'b01, 6'b010001, sd_address_i , 8'b00000001} ;
			case (word_counter)
				8'h87: begin mem_data_o	=	received_reg[47:16]; R7	=	received_reg[79:72];end
				8'h89: begin if(R7 == RCMDX || R7 == RCMDY)begin next_state = veri;end end
				8'h8A: begin transmission	=	1'b1; end
			endcase
		end
		
		veri: begin
			transmission	=	1'b0;
			write_enable_sd	= 	1'b0;
			instruction_sd	=   IWAIT;
			control_done_o	=	1'b1;
			SS = 1'b0;
			case (word_counter)
			8'h8A: begin transmission	=	1'b1; end
			endcase
			if(word_counter > 8'h88 && flag)begin
				transmission = 1'b1;
				flag = 1'b0; 
			end
			if(control_nextoper_i && control_we_i && !control_re_i) begin
				next_state 		= 	write; 
				control_done_o	=	1'b0;
				transmission	=	1'b1;
				flag = 1'b1;
				end
			if(control_nextoper_i && !control_we_i && control_re_i) begin
				next_state 		= 	read; 
				control_done_o	=	1'b0;
				transmission	=	1'b1;
				end
			end
		
	
		
		default: next_state = idle;

	endcase

end
	
//STATE MACHINE CONTROL
always @(posedge control_clk_i or posedge control_rst_i )begin
	if(control_rst_i)begin
		state <= idle;
	end
	else if(flag_edge_detector == 8'h80)begin
		state <= next_state;
	end
end

//FLAG EDGE DETECTOR SCK
always@(posedge control_clk_i or posedge control_rst_i)begin
	if(control_rst_i)begin
		flag_edge_detector <= 8'h00;
	end
	else begin
		flag_edge_detector <= {SCK,flag_edge_detector[7:1]};
	end
end	

	
	
//SPI SCK CLOCK GENERATOR
always @(negedge control_clk_i or posedge transmission or posedge control_rst_i) begin
  if(transmission || control_rst_i) begin
		counter_divider	=	5'h0; 
		SCK	= 1'b1; 
	end
  else begin
		counter_divider = counter_divider + 5'h01; 
		if(counter_divider == divider) begin
			SCK	=~ SCK;
			counter_divider = 5'h00;
		end 
	end 
 end 
 
 //WORD COUNTER REG
 always@(posedge SCK or posedge transmission or posedge control_rst_i) begin // or negedge spi_rst_i
	if(transmission || control_rst_i)  begin
		word_counter <= 8'd0;  
	end
    else begin 
		word_counter <= word_counter + 8'h01;
	end 
end
 
 
 //MISO INPUT DATA PROCESS
 always@(posedge SCK or posedge transmission or posedge control_rst_i) begin
	if(transmission || control_rst_i)  begin
			received_reg = 80'hFFFFFFFFFFFFFFFFFFFF;  
	end
    else begin 
		  if(spi_fbo == 1'b0) 
			begin  received_reg = {MISO,received_reg[79:1]};  end 
		  else  
			begin  received_reg = {received_reg[78:0],MISO};  end
	end 
end 


//MOSI OUTPUT DATA
always@(negedge SCK or posedge transmission or posedge control_rst_i) begin
	if(transmission || control_rst_i) begin
	  transmission_reg = 48'hFFFFFFFFFFFF;  
	  MOSI = 1'b1;  
	end  
	else begin
		if(word_counter == 8'h00 ||(word_counter == 8'h48 && write_enable_sd) ) begin //load data into transmission_reg
			transmission_reg = instruction_sd; 
			MOSI= spi_fbo ? transmission_reg[47]:transmission_reg[0];
		end 
		else begin
			if(spi_fbo == 1'b0) begin //LSB first, shift right
				transmission_reg = {1'b1,transmission_reg[47:1]}; 
				MOSI = transmission_reg[0]; 
			end
			else begin//MSB first shift LEFT
				transmission_reg = {transmission_reg[46:0],1'b1}; 
				MOSI = transmission_reg[47]; 
			end
		end
	end 
end 
	
	
endmodule
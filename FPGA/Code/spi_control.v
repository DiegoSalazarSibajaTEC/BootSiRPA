`timescale 1ns / 1ps

module spi_master(spi_rst_i, spi_clk_i, spi_fbo_i, spi_start_i, transmission_data_i, clock_divider_i, MISO, SS, SCK, MOSI, done, received_data_o);
    input 		spi_rst_i;		//RESET
	input 		spi_clk_i;		//CLOCK INPUT
	input 		spi_fbo_i;		//FIRST BIT OUT FLAG
	input 		spi_start_i;	//START 
    input [47:0] transmission_data_i;  //DATA TO TRANSMIT
    input [1:0] clock_divider_i;  //clock divider
	input 		MISO;
	output reg 	SS; 
	output reg 	SCK; 
	output reg 	MOSI; 
    output reg  done;
	output reg [47:0] received_data_o; //received data

	parameter 	idle=2'b00;		
	parameter 	send=2'b10; 
	parameter 	finish=2'b11; 
	
	reg [1:0] 	state;
	reg [1:0]	next_state;

	reg [47:0] 	transmission_reg;
	reg	[47:0]	received_reg;
	reg [7:0] 	word_counter;
	reg [4:0] 	divider,counter_divider;
	reg 		shift,clear_reg;

//FSM i/o
always @(spi_start_i or state or word_counter or clock_divider_i or received_reg) begin
		 next_state = state;
		 clear_reg 	= 1'b0;  
		 shift		= 1'b0;//SS=0;
		 case(state)
		 
			idle:begin
				if(spi_start_i == 1'b1)
		               begin 
							 case (clock_divider_i)
								2'b00: divider = 5'd2;
								2'b01: divider = 5'd4;
								2'b10: divider = 5'd8;
								2'b11: divider = 5'd16;
 							 endcase
						shift		=	1'b1;
						done		=	1'b0;
						next_state	=	send;	 
						end
		        end //idle
				
			send:begin
				SS=0;
				if(word_counter!=8'h67)
					begin shift=1; end
				else begin
						received_data_o	=	received_reg;
						done			=	1'b1;
						next_state		=	finish;
					end
				end//send
				
			finish:begin
					shift		=	1'b0;
					//SS			=	1'b1;
					clear_reg	=	1'b1;
					next_state	=	idle;
				 end
			default: next_state	=	finish;
      endcase
    end//always

//state transistion
always@(negedge spi_clk_i or negedge spi_rst_i) begin
	if(spi_rst_i == 0) 
		state <= finish;
	else 
		state <= next_state;
 end

//setup falling edge (shift MOSI) sample rising edge (read MISO)
always@(negedge spi_clk_i or posedge clear_reg) begin
  if(clear_reg==1) begin
		counter_divider	=	1'b0; 
		SCK	= 1'b1; 
	end
  else begin
	if(shift==1) begin
		counter_divider = counter_divider + 1'b1; 
	  if(counter_divider == divider) begin
	  	SCK	=~ SCK;
		counter_divider = 1'b0;
		end 
	end 
 end 
end 

//sample @ rising edge (read MISO)
always@(posedge SCK or posedge clear_reg ) begin // or negedge spi_rst_i
	if(clear_reg == 1'b1)  begin
			word_counter = 8'd0;  
			received_reg = 48'hFFFFFFFFFFFF;  
	end
    else begin 
		  if(spi_fbo_i == 1'b0) //LSB first, MISO@msb -> right shift
			begin  received_reg = {MISO,received_reg[47:1]};  end 
		  else  //MSB first, MISO@lsb -> left shift
			begin  received_reg = {received_reg[46:0],MISO};  end
		  word_counter = word_counter + 8'b1;
 end 
end 

always@(negedge SCK or posedge clear_reg) begin
	if(clear_reg == 1) begin
	  transmission_reg = 48'hFFFFFFFFFFFF;  
	  MOSI = 1'b1;  
	end  
	else begin
		if(word_counter == 1'b0) begin //load data into transmission_reg
			transmission_reg = transmission_data_i; 
			MOSI= spi_fbo_i ? transmission_reg[47]:transmission_reg[0];
		end 
		else begin
			if(spi_fbo_i==0) begin //LSB first, shift right
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

`timescale 1ns / 1ps
//http://bikealive.nl/sd-v2-initialization.html
module control(sd_address_i, control_rst_i, control_clk_i, MISO, mem_data_o, instruction_sd, SS, SCK, MOSI);


input  		[31:0] 	sd_address_i;
input		  		control_rst_i;
input		  		control_clk_i;
input 				MISO;
output  reg [31:0] 	mem_data_o;
output  reg [47:0] 	instruction_sd;
output	reg 		SS; 
output 	reg 		SCK; 
output 	reg 		MOSI; 

reg [1:0]  	clock_divider;
reg			spi_rst;		//RESET
reg 		spi_fbo;		//FIRST BIT OUT FLAG
reg 		spi_start;	//START 
reg  		spi_done;
reg [47:0] 	received_data; //received data
reg [1:0] 	state1;
reg [1:0]	next_state1;
reg [47:0] 	transmission_reg;
reg	[47:0]	received_reg;
reg [7:0] 	word_counter;
reg [4:0] 	divider,counter_divider;
reg 		shift,clear_reg;
reg [2:0]  	state;
reg	[2:0]  	next_state;
reg	[8:0]	edge_detector_reg;

parameter 	idle1=2'b00;		
parameter 	send1=2'b10; 
parameter 	finish1=2'b11; 

//INSTRUCTION
parameter IWAIT  = 48'hFFFFFFFFFFFF;
parameter ICMD0  = 48'h400000000095; //r1
parameter ICMD8  = 48'h48000001AA87; //r7 87 o 0F
parameter IACMD47= 48'h770000000001;
parameter ICMD58 = 48'h7A0000000001;

parameter RCMD0  = 48'h370000012083;
parameter R1ACMD41 = 48'h3F00FF8000FF;
parameter R2ACMD41 = 48'h3F80FF8000FF;

parameter RCMDX	 = 8'h01;
parameter RCMDY	 = 8'h00;

parameter spi_CLK_DIV =2'b00;

//STATE
parameter idle  = 3'b000;
parameter CMD0  = 3'b001;
parameter CMD8  = 3'b010;
parameter CMD58 = 3'b011;
parameter ACMD41= 3'b100;
//parameter CRC_7 = 3'b101;  CRC off in SD Card
parameter send	= 3'b110;
parameter veri	= 3'b111;



always @(spi_done or state or received_data or edge_detector_reg)begin
	next_state = state;
	
	case(state)
		idle:begin
			spi_rst		=	1'b1;
			spi_fbo 		=	1'b1;
			spi_start		=	1'b1;
			clock_divider	=	spi_CLK_DIV;
			instruction_sd=   IWAIT;
			if(edge_detector_reg != 8'h00) begin
				spi_start= 1'b0;
				spi_rst  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				next_state = CMD0;
			end
		end
		
		CMD0: begin
			spi_rst		=	1'b1;//negative logic
			spi_fbo		=	1'b1;
			spi_start		=	1'b1;
			clock_divider	=	spi_CLK_DIV;
			instruction_sd=   ICMD0;
			if(edge_detector_reg != 8'h00) begin
				spi_start= 1'b0;
				spi_rst  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				next_state = CMD8;
			end
		end
			
		CMD8: begin
			spi_rst		=	1'b1;//negative logic
			spi_fbo		=	1'b1;//MSB first
			spi_start		=	1'b1;
			clock_divider	=	spi_CLK_DIV;
			instruction_sd=   ICMD8;
			if(edge_detector_reg != 8'h00) begin
				spi_start= 1'b0;
				spi_rst  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				next_state = ACMD41;
			end
			
		end
		
		ACMD41: begin
			spi_rst		=	1'b1;
			spi_fbo		=	1'b1;
			spi_start		=	1'b1;
			clock_divider	=	spi_CLK_DIV;
			instruction_sd=   IACMD47;
			if(edge_detector_reg != 8'h00) begin
				spi_start= 1'b0;
				spi_rst  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				if(received_data[47:40] == RCMDY)begin
					next_state = CMD58;
				end
			end
		end
		
		CMD58: begin
			spi_rst		=	1'b1;
			spi_fbo		=	1'b1;
			spi_start		=	1'b1;
			clock_divider	=	spi_CLK_DIV;
			instruction_sd=   ICMD58;
			if(edge_detector_reg != 8'h00) begin
				spi_start= 1'b0;
				spi_rst  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				if(received_data[47:40] == RCMDY)begin
					next_state = send;
				end
			end
		end
		
		send: begin //modificar
			spi_rst		=	1'b1;
			spi_fbo		=	1'b1;
			spi_start		=	1'b1;
			clock_divider	=	spi_CLK_DIV;
			instruction_sd=   {2'b01, 6'b010001, sd_address_i , 8'b00000001 } ;
			if(spi_done)begin
				if(received_data[47:40] == RCMDY)begin
					mem_data_o =  received_data[39:8];
				end
			end
			if(edge_detector_reg != 8'h00) begin
				spi_start= 1'b0;
				spi_rst  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				next_state = veri;
			end
		end
		
		veri: begin
			spi_rst		=	1'b1;//negative logic
			spi_fbo		=	1'b1;
			spi_start		=	1'b1;
			clock_divider	=	spi_CLK_DIV;
			instruction_sd=   IWAIT;
			if(edge_detector_reg != 8'h00) begin
				spi_start= 1'b0;
				spi_rst  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				next_state = send;
			end
		end

		default: next_state = idle;

	endcase

end
	

always @(spi_start or state1 or word_counter or clock_divider or received_reg) begin
		 next_state1 = state1;
		 clear_reg 	= 1'b0;  
		 shift		= 1'b0;//SS=0;
		 case(state1)
		 
			idle1:begin
				if(spi_start == 1'b1)
		               begin 
							 case (clock_divider)
								2'b00: divider = 5'd10; //ADAPTADOS PARA NEXYS 4
								2'b01: divider = 5'd6;
								2'b10: divider = 5'd4;
								2'b11: divider = 5'd2;
 							 endcase
						shift		=	1'b1;
						spi_done		=	1'b0;
						next_state1	=	send1;	 
						end
		        end //idle
				
			send1:begin
				SS=0;
				if(word_counter!=8'h67)
					begin shift=1; end
				else begin
						received_data	=	received_reg;
						spi_done			=	1'b1;
						next_state1		=	finish1;
					end
				end//send
				
			finish1:begin
					shift		=	1'b0;
					//SS			=	1'b1;
					clear_reg	=	1'b1;
					next_state1	=	idle1;
				 end
			default: next_state1	=	finish1;
      endcase
    end//always

	//detector de done
always @(posedge control_clk_i or posedge control_rst_i )begin
	if(control_rst_i)begin
		state <= idle;
		edge_detector_reg <= 2'b00;
	end
	else begin
		state <= next_state;
		edge_detector_reg <= {spi_done, edge_detector_reg[7:1]};
	end
end
	
	//maquina de transmision spi
always@(negedge control_clk_i or negedge spi_rst) begin
	if(spi_rst == 0 || control_rst_i) 
		state1 <= finish1;
	else 
		state1 <= next_state1;
 end

//setup falling edge (shift MOSI) sample rising edge (read MISO)
always@(negedge control_clk_i or posedge clear_reg) begin
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
		  if(spi_fbo == 1'b0) //LSB first, MISO@msb -> right shift
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
			transmission_reg = instruction_sd; 
			MOSI= spi_fbo ? transmission_reg[47]:transmission_reg[0];
		end 
		else begin
			if(spi_fbo==0) begin //LSB first, shift right
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

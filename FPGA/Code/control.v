`timescale 1ns / 1ps
//http://bikealive.nl/sd-v2-initialization.html
module control(spi_rst_o, spi_fbo_o, spi_start_o, instruction_sd_o, clock_divider_o, spi_data_i, control_rst_i, control_clk_i, spi_SCK_i,spi_done_i);

input  [47:0] spi_data_i;
input		  control_rst_i;
input		  control_clk_i;
input		  spi_SCK_i;
input		  spi_done_i;
output		  spi_rst_o;
output		  spi_fbo_o;
output		  spi_start_o;
output [47:0] instruction_sd_o;
output [1:0]  clock_divider_o;

//INSTRUCTION
parameter IWAIT	 = 48'FFFFFFFFFFFFF;
parameter ICMD0  = 48'h400000000095; //r1
parameter ICMD8  = 48'h48000001AA87; //r7 87 o 0F
parameter IACMD47= 48'h770000000001;
parameter ICMD58 = 48'h7A0000000001;

parameter RCMD0  = 48'h370000012083;
parameter R1ACMD41 = 48'h3F00FF8000FF;
parameter R2ACMD41 = 48'h3F80FF8000FF;

parameter RCMX	 = 8'h01;
parameter RCMY	 = 8'h00;

parameter spi_CLK_DIV =2'b00;

//STATE
parameter idle  = 3'b000;
parameter CMD0  = 3'b001
parameter CMD8  = 3'b010;
parameter CMD58 = 3'b011;
parameter ACMD41= 3'b100;
parameter CRC_7 = 3'b101;
parameter send	= 3'b110;
parameter veri	= 3'b111;


reg    [2:0]  	state;
reg	   [2:0]  	next_state;

reg	   [2:0] 	counter_CMD0;


reg	   [7:0]	edge_detector_reg;
reg				flag_edge_detector;	

reg	   [39:0]	data_crc;
	
always @(posedge control_clk_i or posedge control_rst_i )begin
	if(control_rst_i)begin
		state <= idle;
	end
	else begin
		state <= next_state;
	end
end

always @()begin
	next_state = state;
	
	case(state)
		idle:
			spi_rst_o		=	1'b1;//negative logic
			spi_fbo_o		=	1'b0;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   IWAIT;
			if(spi_done_i)begin
				next_state = CMD0;
				spi_rst_o  = 1'b0;
				spi_start_o= 1'b1;
			end
		
		CMD0:
			spi_rst_o		=	1'b1;//negative logic
			spi_fbo_o		=	1'b0;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   ICMD0;
			if(spi_done_i)begin
				next_state = CMD8;
				spi_rst_o  = 1'b0;
				spi_start_o= 1'b1;
			end
			
			
			
		CMD8:
			spi_rst_o		=	1'b1;//negative logic
			spi_fbo_o		=	1'b0;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   ICMD8;
			if(spi_done_i)begin
				if(spi_data_i[47:40] == RCMDX)begin
					next_state = ACMD41;
				end
				spi_rst_o  = 1'b0;
				spi_start_o= 1'b1;
			end
			
		ACMD41:
			spi_rst_o		=	1'b1;//negative logic
			spi_fbo_o		=	1'b0;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   IACMD47;
			if(spi_done_i)begin
				if(spi_data_i[47:40] == RCMDX)begin
					next_state = CMD58;
				end
				spi_rst_o  = 1'b0;
				spi_start_o= 1'b1;
			end
			
		CMD58:
			spi_rst_o		=	1'b1;//negative logic
			spi_fbo_o		=	1'b0;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   ICMD58;
			if(spi_done_i)begin
				if(spi_data_i[47:40] == RCMDY)begin
					next_state = CMD58;
				end
				spi_rst_o  = 1'b0;
				spi_start_o= 1'b1;
			end	
			
		CRC_7:

	endcase

end
	

always @(posedge control_clk_i or posedge control_rst_i )begin
	if(control_rst_i)begin
		counter_CMD0 <= 3'h0;
		edge_detector_reg <= 8'h00;
	end
	else begin
		edge_detector_reg <= {spi_SCK_i, edge_detector_reg[7:1]};
		if(flag_edge_detector==1'b1) begin
			counter_CMD0 <= counter_CMD0 + 3'h1;
		end
	end	

end
	
	
always @(posedge control_clk_i or posedge control_rst_i )begin //EDGE DETECTOR
	if(control_rst_i)begin
		flag_edge_detector = 1'b0;
	end
	else begin
		if(edge_detector_reg == 8'b10000000)begin
			flag_edge_detector = 1'b1;
		end
		else if(edge_detector_reg != 8'b10000000)begin
			flag_edge_detector = 1'b0;
		end
	end
end
	
////////////////////////////////////
reg		[39:0]	data_crc; 
reg 			crc_7_enable;                          
reg 	[6:0] 	CRC; 
reg 			flag_crc_done;
reg 			BITVAL;
reg		[39:0]	reg_data_crc;
reg 	[7:0]	counter;
reg 	[6:0] 	CRC_INT; 
wire         	inv;
  
assign inv = BITVAL ^ CRC_INT[6];                   // XOR required  



always @(posedge control_clk_i or posedge control_rst_i) begin
	
	if(control_rst_i)begin
		flag_crc_done <= 1'b0;
		counter<= 6'h00;
		BITVAL <= 1'B0;
		CRC_INT <= 0;
		CRC <= 0;
	end 
	
	if(counter == 8'h29) begin
		flag_crc_done <= 1'b1;
		CRC <= CRC_INT;
	end
	else if(counter != 8'h29)begin
		flag_crc_done <= 1'b0;
		CRC <=CRC;
	end
	

	if(crc_7_enable==1'b0)begin
		reg_data_crc <= data_crc;
		counter<= 6'h00;
		CRC_INT <= 0;
	end

	else if (crc_7_enable==1'b1)begin 
		BITVAL <= reg_data_crc[39];
		reg_data_crc <= {reg_data_crc[38:0],1'b0};
		counter <= counter+8'h01;
		CRC_INT[6] <= CRC_INT[5];  
		CRC_INT[5] <= CRC_INT[4];  
		CRC_INT[4] <= CRC_INT[3];  
		CRC_INT[3] <= CRC_INT[2] ^ inv;  
		CRC_INT[2] <= CRC_INT[1];  
		CRC_INT[1] <= CRC_INT[0];  
		CRC_INT[0] <= inv;
	end  

end  	




endmodule
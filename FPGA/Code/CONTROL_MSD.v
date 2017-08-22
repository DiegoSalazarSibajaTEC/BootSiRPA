`timescale 1ns / 1ps
//http://bikealive.nl/sd-v2-initialization.html
module CONTROL_MSD(spi_rst_o, sd_address_i, spi_fbo_o, spi_start_o, instruction_sd_o, clock_divider_o, spi_data_i, control_rst_i, control_clk_i,
					spi_SCK_i,spi_done_i,mem_data_o, control_we_i, control_re_i,spi_datawe_i, spi_sendenb_o,control_dataw_i);

input  		[79:0] 	spi_data_i;
input  		[31:0] 	sd_address_i;
input		  		control_rst_i;
input		  		control_clk_i;
input		  		spi_SCK_i;
input		  		spi_done_i;
input 				control_we_i; //write enable
input				control_re_i; //read enable
input				spi_datawe_i; //data send
input 		[31:0]	control_dataw_i; //data to write
output	reg			spi_sendenb_o;//send modo
output	reg  		spi_rst_o;
output	reg  		spi_fbo_o;
output	reg	  		spi_start_o;
output  reg [31:0] 	mem_data_o;
output  reg [47:0] 	instruction_sd_o;
output  reg [1:0]  	clock_divider_o;

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
parameter write = 3'b101;  //CRC off in SD Card
parameter read	= 3'b110;
parameter veri	= 3'b111;


reg    [2:0]  	state;
reg	   [2:0]  	next_state;

reg	   [2:0] 	counter_CMD0;


reg	   [8:0]	edge_detector_reg;


reg	   [39:0]	data_crc;
	
always @(posedge control_clk_i or posedge control_rst_i )begin
	if(control_rst_i)begin
		state <= idle;
		edge_detector_reg <= 8'h00;
	end
	else begin
		state <= next_state;
		edge_detector_reg <= {spi_done_i, edge_detector_reg[7:1]};
	end
end

always @(spi_done_i or state or spi_data_i or edge_detector_reg)begin
	next_state = state;
	
	case(state)
		idle:begin
			spi_rst_o		=	1'b1;
			spi_fbo_o 		=	1'b1;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   IWAIT;
			if(edge_detector_reg != 8'h00) begin
				spi_start_o= 1'b0;
				spi_rst_o  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				next_state = CMD0;
			end
		end
		
		CMD0: begin
			spi_rst_o		=	1'b1;//negative logic
			spi_fbo_o		=	1'b1;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   ICMD0;
			if(edge_detector_reg != 8'h00) begin
				spi_start_o= 1'b0;
				spi_rst_o  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				next_state = CMD8;
			end
		end
			
		CMD8: begin
			spi_rst_o		=	1'b1;//negative logic
			spi_fbo_o		=	1'b1;//MSB first
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   ICMD8;
			if(edge_detector_reg != 8'h00) begin
				spi_start_o= 1'b0;
				spi_rst_o  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				next_state = ACMD41;
			end
			
		end
		
		ACMD41: begin
			spi_rst_o		=	1'b1;
			spi_fbo_o		=	1'b1;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   IACMD47;
			if(edge_detector_reg != 8'h00) begin
				spi_start_o= 1'b0;
				spi_rst_o  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				if(spi_data_i[79:72] == RCMDY)begin
					next_state = CMD58;
				end
			end
		end
		
		CMD58: begin
			spi_rst_o		=	1'b1;
			spi_fbo_o		=	1'b1;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   ICMD58;
			if(edge_detector_reg != 8'h00) begin
				spi_start_o= 1'b0;
				spi_rst_o  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				if(control_re_i == 1'b1 && control_we_i == 1'b0)begin
						next_state = read;
				end
				else if (control_re_i == 1'b0 && control_we_i == 1'b1) begin
						next_state = write;
				end
			end
		end
		
		write: begin
			spi_rst_o		=	1'b1;//negative logic
			spi_fbo_o		=	1'b1;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			spi_sendenb_o	=	1'b1;
			instruction_sd_o=   {2'b01, 6'b011000, sd_address_i , 8'b00000001 } ;
			if(spi_datawe_i) begin
				instruction_sd_o = {8'b11111110,control_dataw_i,8'h00};
			end
			else if(edge_detector_reg != 8'h00) begin
				spi_start_o= 1'b0;
				spi_rst_o  = 1'b0;
				spi_sendenb_o = 1'b0;
				end
				else if(edge_detector_reg == 8'h01)begin
				next_state = veri;
				end
		
		
		end
		
		read: begin //modificar
			spi_rst_o		=	1'b1;
			spi_fbo_o		=	1'b1;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   {2'b01, 6'b010001, sd_address_i , 8'b00000001 } ;
			if(spi_done_i)begin
				if(spi_data_i[79:72] == RCMDY)begin
					mem_data_o =  spi_data_i[47:16];
				end
			end
			if(edge_detector_reg != 8'h00) begin
				spi_start_o= 1'b0;
				spi_rst_o  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				next_state = veri;
			end
		end
		
		veri: begin
			spi_rst_o		=	1'b1;//negative logic
			spi_fbo_o		=	1'b1;
			spi_start_o		=	1'b1;
			clock_divider_o	=	spi_CLK_DIV;
			instruction_sd_o=   IWAIT;
			if(edge_detector_reg != 8'h00) begin
				spi_start_o= 1'b0;
				spi_rst_o  = 1'b0;
			end
			if(edge_detector_reg == 8'h01)begin
				if(control_re_i == 1'b1 && control_we_i == 1'b0)begin
						next_state = read;
				end
				else if (control_re_i == 1'b0 && control_we_i == 1'b1) begin
						next_state = write;
				end
			end
		end
		
		default: next_state = idle;

	endcase

end
	

endmodule
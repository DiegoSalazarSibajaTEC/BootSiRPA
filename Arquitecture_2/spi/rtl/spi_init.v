`timescale 1ns / 1ps

module spi_init(spi_clk_i, spi_rst_i, SCK_SPI, spi_init_i, spi_enableoper_i, spi_datamicro_i, spi_statusregmicro_i, R1, spi_flagreg_i, spi_datainit_o, spi_statusreginit_o,
				spi_initdone_o);

parameter IWAIT  = 48'hFFFFFFFFFFFF;
parameter ICMD0  = 48'h400000000095; //r1
parameter ICMD8  = 48'h48000001AA87; //r7 87 o 0F
parameter IACMD47= 48'h770000000001;
parameter ICMD58 = 48'h7A0000000001;

parameter RCMDX	 = 8'h01;
parameter RCMDY	 = 8'h00;



input 				spi_clk_i;
input 				spi_rst_i;
input 				SCK_SPI;
input 				spi_init_i;
input 				spi_enableoper_i;
input [47:0] 		spi_datamicro_i;
input [7:0] 		spi_statusregmicro_i;
input [7:0] 		R1;
input [2:0] 		spi_flagreg_i;
output wire [47:0] 	spi_datainit_o;
output wire [7:0]  	spi_statusreginit_o;
output reg 			spi_initdone_o;

reg [47:0]	datainit;
reg [7:0] 	statusreg;
reg [7:0] 	counter_operation;
reg 		enable_count;
reg 		r_acmd47;
reg [1:0] 	flag_edge_detector;

assign spi_datainit_o =(spi_init_i) ? datainit : spi_datamicro_i;
assign spi_statusreginit_o = (spi_init_i) ? statusreg : spi_statusregmicro_i;


always@(negedge spi_clk_i or posedge spi_rst_i)begin
	if(spi_rst_i)begin
		flag_edge_detector = 2'b00;
	end
	else begin
		flag_edge_detector = {SCK_SPI,flag_edge_detector[1]};
	end
end	

always @(posedge spi_clk_i or posedge spi_rst_i)begin
	if(spi_rst_i)begin
		counter_operation <= 8'h00;
	end
	else if (enable_count && spi_init_i && spi_enableoper_i && spi_flagreg_i == 3'b010) begin
		if(	r_acmd47) begin
			counter_operation <= 8'h03;
		end
		else begin
		 counter_operation <= counter_operation +8'h01;
		end
	end
end

always @* begin
	enable_count = 1'b0;
	r_acmd47 = 1'b0;
	spi_initdone_o = 1'b0;
	datainit = IWAIT;
	statusreg = 8'h00;

	case(counter_operation)
		8'h00: begin 
			datainit = IWAIT;
			statusreg = 8'b01000111; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 1 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end
		8'h01: begin 
			datainit = ICMD0;
			statusreg = 8'b01000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end		
		8'h02: begin 
			datainit = ICMD8;
			statusreg = 8'b01000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end	
		8'h03: begin 
			datainit = ICMD58;
			statusreg = 8'b01000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end	
		8'h04: begin 
			datainit = IACMD47;
			statusreg = 8'b01000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
			if(R1 == RCMDX || R1== RCMDY)begin
				r_acmd47 = 1'b0;
			end
			else begin
				r_acmd47 = 1'b1;
			end
		end
		8'h05: begin 
			datainit = ICMD58;
			statusreg = 8'b01000101; //010 1:4 clock divider -- 0 microSDwr 0 microSDrd -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			enable_count = 1'b1;
		end
		8'h06: begin 
			datainit = {2'b01, 6'b010001, 32'h00002800, 8'b00000001};
			statusreg = 8'b01010101; //010 1:4 clock divider -- 1 microSDrd 0 microSDwr -- 1 MSB fbo -- 0 spiinitSS -- 1 spi_operation
			if(R1 == RCMDX || R1== RCMDY)begin
				enable_count = 1'b1; 
			end
			else begin
				enable_count = 1'b0;
			end
		end
		8'h07: begin
			spi_initdone_o = 1'b1;
			enable_count = 1'b0;
			r_acmd47 = 1'b0;
		end

	endcase
end

endmodule
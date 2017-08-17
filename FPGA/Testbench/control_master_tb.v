`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:38:10 08/16/2017
// Design Name:   control
// Module Name:   D:/Dropbox/TEC/Semestres/XI Semestre/BootSiRPA/control_tb.v
// Project Name:  BootSiRPA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: control
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module control_tb;

	// Inputs
	reg [31:0] sd_address_i;
	reg [47:0] spi_data_i;
	reg control_rst_i;
	reg control_clk_i;
	reg spi_SCK_i;
	reg spi_done_i;

	// Outputs
	wire spi_rst_o;
	wire spi_fbo_o;
	wire spi_start_o;
	wire [47:0] instruction_sd_o;
	wire [1:0] clock_divider_o;
	wire [31:0] mem_data_o;

	// Instantiate the Unit Under Test (UUT)
	control uut (
		.spi_rst_o(spi_rst_o), 
		.sd_address_i(sd_address_i), 
		.spi_fbo_o(spi_fbo_o), 
		.spi_start_o(spi_start_o), 
		.instruction_sd_o(instruction_sd_o), 
		.clock_divider_o(clock_divider_o), 
		.spi_data_i(spi_data_i), 
		.control_rst_i(control_rst_i), 
		.control_clk_i(control_clk_i), 
		.spi_SCK_i(spi_SCK_i), 
		.spi_done_i(spi_done_i), 
		.mem_data_o(mem_data_o)
	);

	initial begin
		// Initialize Inputs
		sd_address_i = 0;
		spi_data_i = 0;
		control_rst_i = 0;
		control_clk_i = 0;
		#10;
		control_rst_i = 1'b1;
		repeat (2) begin 
			@ (posedge control_clk_i); 
		end 
		control_rst_i = 1'b0;
		sd_address_i = 32'hF1F1AF01;
		repeat (2000) begin 
			@ (posedge control_clk_i); 
		end 
		$stop;

	end
	
	initial begin
	#10
	spi_SCK_i = 0;
	spi_done_i = 0;
	repeat (120) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i=1'b1;
	repeat (2) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i = 0;
	repeat (120) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i=1'b1;
	repeat (2) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i = 0;
	repeat (120) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i=1'b1;
	repeat (2) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i = 0;
	repeat (120) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i=1'b1;
	repeat (2) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i = 0;
	repeat (120) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i=1'b1;
	repeat (2) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i = 0;
	repeat (120) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i=1'b1;
	repeat (2) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i = 0;
	repeat (120) begin 
			@ (posedge spi_SCK_i); 
		end 
	spi_done_i=1'b1;
	repeat (2) begin 
			@ (posedge spi_SCK_i); 
		end 
		
	end
	
	always begin
	 #2 control_clk_i = ~ control_clk_i;
	
	end
	always begin
	 #4 spi_SCK_i = ~ spi_SCK_i;
	end
      
endmodule


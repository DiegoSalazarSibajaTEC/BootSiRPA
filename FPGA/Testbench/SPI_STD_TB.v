`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:26:42 07/26/2017
// Design Name:   spi_master
// Module Name:   D:/Dropbox/TEC/DCiLab/ALE01BTP/FPGA/BootSiRPA/spi_testbench2.v
// Project Name:  BootSiRPA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: spi_master
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module spi_testbench;

	// Inputs
	reg spi_rst_i;
	reg spi_clk_i;
	reg spi_fbo_i;
	reg spi_start_i;
	reg [47:0] transmission_data_i;
	reg [1:0] clock_divider_i;
	reg MISO;

	// Outputs
	wire SS;
	wire SCK;
	wire MOSI;
	wire done;
	wire [47:0] received_data_o;

	// Instantiate the Unit Under Test (UUT)
	spi_master uut (
		.spi_rst_i(spi_rst_i), 
		.spi_clk_i(spi_clk_i), 
		.spi_fbo_i(spi_fbo_i), 
		.spi_start_i(spi_start_i), 
		.transmission_data_i(transmission_data_i), 
		.clock_divider_i(clock_divider_i), 
		.MISO(MISO), 
		.SS(SS), 
		.SCK(SCK), 
		.MOSI(MOSI), 
		.done(done), 
		.received_data_o(received_data_o)
	);

	initial begin
		// Initialize Inputs
		spi_rst_i = 0;
		spi_clk_i = 0;
		spi_fbo_i = 0;
		spi_start_i = 0; 
		transmission_data_i = 48'h001F001F001F;
		clock_divider_i = 2'b00;
		MISO = 0;

		// Wait 100 ns for global reset to finish
		#20;
		spi_rst_i = 1;
		spi_start_i = 1;
		spi_fbo_i = 1;
		#10;
		spi_fbo_i = 0;
		#2005;	
		MISO=0;
		#20
		MISO=1;
		#20
		MISO=0;
		#20
		MISO=1;
		#20
		MISO=0;
		#200
		MISO=1;
		#4000;
		$stop;

	end
	
	always begin
	#5 spi_clk_i=~spi_clk_i;
	end
      
endmodule


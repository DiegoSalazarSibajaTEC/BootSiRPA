`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:47:13 08/24/2017
// Design Name:   spi_microsd
// Module Name:   D:/Dropbox/TEC/DCiLab/ALE01BTP/FPGA/T/Test/bootstrap_tb.v
// Project Name:  Test
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: spi_microsd
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module bootstrap_tb;

	// Inputs
	reg [31:0] sd_address_i;
	reg control_rst_i;
	reg control_clk_i;
	reg control_we_i;
	reg control_re_i;
	reg [31:0] control_dataw_i;
	reg MISO;

	// Outputs
	wire SCK;
	wire [31:0] mem_data_o;
	wire SS;
	wire MOSI;

	// Instantiate the Unit Under Test (UUT)
	spi_microsd uut (
		.sd_address_i(sd_address_i), 
		.control_rst_i(control_rst_i), 
		.control_clk_i(control_clk_i), 
		.SCK(SCK), 
		.mem_data_o(mem_data_o), 
		.control_we_i(control_we_i), 
		.control_re_i(control_re_i), 
		.control_dataw_i(control_dataw_i), 
		.SS(SS), 
		.MISO(MISO), 
		.MOSI(MOSI)
	);

	initial begin
		// Initialize Inputs
		sd_address_i = 0;
		control_rst_i = 0;
		control_clk_i = 0;
		control_we_i = 0;
		control_re_i = 0;
		control_dataw_i = 0;
		MISO = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule


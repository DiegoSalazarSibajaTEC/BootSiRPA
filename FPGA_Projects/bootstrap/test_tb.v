`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:51:29 10/18/2017
// Design Name:   test
// Module Name:   D:/Dropbox/TEC/Semestres/XI Semestre-PdG/Github/BootSiRPA/FPGA_Projects/bootstrap/test_tb.v
// Project Name:  bootstrap
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: test
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_tb;

	// Inputs
	reg master_clk_i;
	reg master_rst_i;
	reg MISO;

	// Outputs
	wire [21:0] sram_address_o;
	wire [15:0] sram_datain_o;
	wire sram_cs_o;
	wire sram_oe_o;
	wire sram_wait_o;
	wire sram_adv_o;
	wire MOSI;
	wire SS;
	wire SCK_SPI;
	wire error;
	wire [1:0] sram_lb_ub_o;
	wire sram_we_o;

	// Instantiate the Unit Under Test (UUT)
	test uut (
		.master_clk_i(master_clk_i), 
		.master_rst_i(master_rst_i), 
		.MISO(MISO), 
		.sram_address_o(sram_address_o), 
		.sram_datain_o(sram_datain_o), 
		.sram_cs_o(sram_cs_o), 
		.sram_oe_o(sram_oe_o), 
		.sram_wait_o(sram_wait_o), 
		.sram_adv_o(sram_adv_o), 
		.MOSI(MOSI), 
		.SS(SS), 
		.SCK_SPI(SCK_SPI), 
		.error(error), 
		.sram_lb_ub_o(sram_lb_ub_o), 
		.sram_we_o(sram_we_o)
	);

	initial begin
		// Initialize Inputs
		master_clk_i = 0;
		master_rst_i = 0;
		MISO = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule


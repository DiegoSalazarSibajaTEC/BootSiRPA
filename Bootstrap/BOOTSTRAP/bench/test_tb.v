`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   04:58:33 10/20/2017
// Design Name:   test
// Module Name:   D:/Dropbox/TEC/DCiLab/ALE01BTP/FPGA/IntegracionA/test_tb.v
// Project Name:  IntegracionA
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
	wire bootstrap_initdone_o;
	wire sram_clk_o;
	wire reset;
	wire MISO1;
	wire MOSI1;
	wire SS1;
	wire SCK1;

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
		.sram_we_o(sram_we_o), 
		.bootstrap_initdone_o(bootstrap_initdone_o), 
		.sram_clk_o(sram_clk_o), 
		.reset(reset), 
		.MISO1(MISO1), 
		.MOSI1(MOSI1), 
		.SS1(SS1), 
		.SCK1(SCK1)
	);

	initial begin
		// Initialize Inputs
		master_clk_i = 0;
		master_rst_i = 1;
		MISO = 0;
		repeat (30) begin 
			@ (posedge master_clk_i); 
		end
		master_rst_i = 0;
		repeat (40000) begin 
			@ (posedge master_clk_i); 
		end
		$stop;
	end
      
	  
	always begin
	#1 master_clk_i = ~master_clk_i;
	end
endmodule


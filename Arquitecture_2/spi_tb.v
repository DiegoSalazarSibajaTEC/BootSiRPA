`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:53:35 09/06/2017
// Design Name:   spi
// Module Name:   D:/Dropbox/TEC/DCiLab/ALE01BTP/FPGA/T/Test/spi_tb.v
// Project Name:  Test
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: spi
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module spi_tb;

	// Inputs
	reg spi_clk_i;
	reg spi_rst_i;
	reg [47:0] spi_data_i;
	reg spi_protocole_i;
	reg spi_operation_i;
	reg MISO;
	reg spi_fbo_i;
	reg spi_microSDwr_i;
	reg spi_microSDrd_i;

	// Outputs
	wire [31:0] spi_data_o;
	wire MOSI;
	wire SCK;
	wire SS;
	wire spi_doneflag_o;
	wire spi_doneword_o;
	wire spi_flagdatawr_o;
	wire [7:0] R1;
	wire SCK_SPI;

	// Instantiate the Unit Under Test (UUT)
	spi uut (
		.spi_clk_i(spi_clk_i), 
		.spi_rst_i(spi_rst_i), 
		.spi_data_i(spi_data_i), 
		.spi_data_o(spi_data_o), 
		.spi_protocole_i(spi_protocole_i), 
		.spi_operation_i(spi_operation_i), 
		.MOSI(MOSI), 
		.MISO(MISO), 
		.SCK(SCK), 
		.SS(SS), 
		.spi_doneflag_o(spi_doneflag_o), 
		.spi_fbo_i(spi_fbo_i), 
		.spi_microSDwr_i(spi_microSDwr_i), 
		.spi_microSDrd_i(spi_microSDrd_i), 
		.spi_doneword_o(spi_doneword_o), 
		.spi_flagdatawr_o(spi_flagdatawr_o), 
		.R1(R1),
		.SCK_SPI(SCK_SPI)
	);

	initial begin
		// Initialize Inputs
		spi_clk_i = 0;
		spi_rst_i = 1;
		spi_data_i = 48'h56781234ABCD;
		spi_protocole_i = 0;
		spi_operation_i = 0;
		MISO = 0;
		spi_fbo_i = 1;
		spi_microSDwr_i = 0;
		spi_microSDrd_i = 0;
		repeat (2) begin 
			@ (posedge spi_clk_i); 
		end
		spi_rst_i = 0;
		repeat (300) begin 
			@ (posedge spi_clk_i); 
		end
		spi_operation_i = 1;
		spi_microSDwr_i = 0;
		spi_microSDrd_i = 1;
		repeat (200000) begin 
			@ (posedge spi_clk_i); 
		end
		spi_operation_i = 0;
		repeat (30) begin 
			@ (posedge spi_clk_i); 
		end
		$stop;

	end

	  
	always begin
	#1 spi_clk_i = ~spi_clk_i;
	end
endmodule


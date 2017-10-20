`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:58:03 10/20/2017
// Design Name:   spi
// Module Name:   D:/Dropbox/TEC/DCiLab/ALE01BTP/FPGA/IntegracionA/spi_tb.v
// Project Name:  IntegracionA
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
	reg [8:0] spi_statusreg_i;
	reg [47:0] spi_data_i;
	reg spi_init_i;
	reg MISO;

	// Outputs
	wire MOSI;
	wire SCK_SPI;
	wire SS;
	wire spi_initdone_o;
	wire [2:0] spi_flagreg_o;
	wire [31:0] spi_data_o;

	// Instantiate the Unit Under Test (UUT)
	spi uut (
		.spi_clk_i(spi_clk_i), 
		.spi_rst_i(spi_rst_i), 
		.spi_statusreg_i(spi_statusreg_i), 
		.spi_data_i(spi_data_i), 
		.spi_init_i(spi_init_i), 
		.MISO(MISO), 
		.MOSI(MOSI), 
		.SCK_SPI(SCK_SPI), 
		.SS(SS), 
		.spi_initdone_o(spi_initdone_o), 
		.spi_flagreg_o(spi_flagreg_o), 
		.spi_data_o(spi_data_o)
	);

	initial begin
		// Initialize Inputs
		spi_clk_i = 0;
		spi_rst_i = 1;
		spi_statusreg_i = 0;
		spi_data_i = 0;
		spi_init_i = 0;
		MISO = 0;
        repeat (10) begin 
           @ (posedge spi_clk_i); 
        end
        spi_rst_i = 0;
        spi_init_i = 1;
        spi_statusreg_i = 9'b110000000;
        repeat (30000) begin 
            @ (posedge spi_clk_i); 
        end
        $stop;
	end
	
	
always begin
    #1 spi_clk_i = ~spi_clk_i;
 end  
 
   
endmodule



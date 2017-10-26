`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:07:55 10/14/2017
// Design Name:   bootstrap
// Module Name:   D:/Dropbox/TEC/Semestres/XI Semestre-PdG/Github/BootSiRPA/FPGA_Projects/bootstrap/bootstrap_tb.v
// Project Name:  bootstrap
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: bootstrap
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
	reg master_clk_i;
	reg master_rst_i;
	reg [43:0] micro_sram_controller_i;
	reg bootstrap_init_i;
	reg [31:0] spi_data_i;
	reg [8:0] spi_statusreg_i;
	reg bootstrap_writeenable_i;
	reg micro_controlmem_i;
	reg MISO;

	// Outputs
	wire [2:0] spi_flagreg_o;
	wire bootstrap_initdone_o;
	wire [21:0] sram_address_o;
	wire [15:0] sram_datain_o;
	wire sram_cs_o;
	wire sram_we_o;
	wire sram_oe_o;
	wire [1:0] sram_lb_ub_o;
	wire sram_adv_o;
	wire sram_wait_o;
	wire error;
	wire MOSI;
	wire SS;
	wire SCK_SPI;

	// Instantiate the Unit Under Test (UUT)
	bootstrap uut (
		.master_clk_i(master_clk_i), 
		.master_rst_i(master_rst_i), 
		.micro_sram_controller_i(micro_sram_controller_i), 
		.bootstrap_init_i(bootstrap_init_i), 
		.spi_data_i(spi_data_i), 
		.spi_statusreg_i(spi_statusreg_i), 
		.bootstrap_writeenable_i(bootstrap_writeenable_i), 
		.micro_controlmem_i(micro_controlmem_i), 
		.spi_flagreg_o(spi_flagreg_o), 
		.bootstrap_initdone_o(bootstrap_initdone_o), 
		.sram_address_o(sram_address_o), 
		.sram_datain_o(sram_datain_o), 
		.sram_cs_o(sram_cs_o), 
		.sram_we_o(sram_we_o), 
		.sram_oe_o(sram_oe_o), 
		.sram_lb_ub_o(sram_lb_ub_o), 
		.sram_adv_o(sram_adv_o), 
		.sram_wait_o(sram_wait_o), 
		.error(error), 
		.MISO(MISO), 
		.MOSI(MOSI), 
		.SS(SS), 
		.SCK_SPI(SCK_SPI)
	);

	initial begin
		// Initialize Inputs
		master_clk_i = 0;
		master_rst_i = 1;
		micro_sram_controller_i = 0;
		bootstrap_init_i = 0;
		spi_data_i = 0;
		spi_statusreg_i = 9'b110100011;
		bootstrap_writeenable_i = 0;
		micro_controlmem_i = 0;
		MISO = 0;
		repeat (10) begin 
			@ (posedge master_clk_i); 
		end
		master_rst_i = 0;
		bootstrap_init_i = 1;
		repeat (30000) begin 
			@ (posedge master_clk_i); 
		end
		bootstrap_init_i = 0;
		$stop;
	end
	
	always begin
	#1 master_clk_i = ~master_clk_i;
	end
      
endmodule


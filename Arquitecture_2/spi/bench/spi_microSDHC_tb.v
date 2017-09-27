`timescale 1ns / 1ps

module spi_microSDHC_tb;

	// Inputs
	reg spi_clk_i;
	reg spi_rst_i;
	reg [7:0] spi_statusreg_i;
	reg [47:0] spi_data_i;
	reg MISO;
	reg spi_init_i;
	reg spi_enableoper_i;

	// Outputs
	wire [31:0] spi_data_o;
	wire [2:0] spi_flagreg_o;
	wire MOSI;
	wire SS;
	wire SCK_SPI;
	wire spi_initdone_o;

	// Instantiate the Unit Under Test (UUT)
	spi_microSDHC uut (
		.spi_clk_i(spi_clk_i), 
		.spi_rst_i(spi_rst_i), 
		.spi_statusreg_i(spi_statusreg_i), 
		.spi_data_i(spi_data_i), 
		.MISO(MISO), 
		.spi_init_i(spi_init_i), 
		.spi_enableoper_i(spi_enableoper_i), 
		.spi_data_o(spi_data_o), 
		.spi_flagreg_o(spi_flagreg_o), 
		.MOSI(MOSI), 
		.SS(SS), 
		.SCK_SPI(SCK_SPI), 
		.spi_initdone_o(spi_initdone_o)
	);

	initial begin
		// Initialize Inputs
		spi_clk_i = 0;
		spi_rst_i = 1;
		spi_statusreg_i = 0;
		spi_data_i = 0;
		MISO = 0;
		spi_init_i = 0;
		spi_enableoper_i = 0;

		repeat (10) begin 
			@ (posedge spi_clk_i); 
		end
		spi_rst_i = 0;
		spi_init_i = 1;
		repeat (100) begin 
			@ (posedge spi_clk_i); 
		end
		spi_enableoper_i = 1;
		repeat (30000) begin 
			@ (posedge spi_clk_i); 
		end
		$stop;
	end
	
	always begin
	#1 spi_clk_i = ~spi_clk_i;
	end
      
endmodule


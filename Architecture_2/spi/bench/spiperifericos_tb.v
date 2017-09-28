`timescale 1ns / 1ps

module spiperifericos_tb;

	// Inputs
	reg spi_clk_i;
	reg spi_rst_i;
	reg [7:0] spi_data_i;
	reg MISO;
	reg [5:0] spi_statusreg_i;

	// Outputs
	wire [15:0] spi_data_o;
	wire MOSI;
	wire SCK_SPI;
	wire SS;
	wire spi_doneflag_o;

	// Instantiate the Unit Under Test (UUT)
	spi_perifericos uut (
		.spi_clk_i(spi_clk_i), 
		.spi_rst_i(spi_rst_i), 
		.spi_data_i(spi_data_i), 
		.spi_data_o(spi_data_o), 
		.MOSI(MOSI), 
		.MISO(MISO), 
		.SCK_SPI(SCK_SPI), 
		.SS(SS), 
		.spi_doneflag_o(spi_doneflag_o), 
		.spi_statusreg_i(spi_statusreg_i)
	);

	initial begin
		// Initialize Inputs
		spi_clk_i = 0;
		spi_rst_i = 1;
		spi_data_i = 0;
		MISO = 0;
		spi_statusreg_i = 0;
		repeat (2) begin 
			@ (posedge spi_clk_i); 
		end
		spi_rst_i = 0;
		repeat (2) begin 
			@ (posedge spi_clk_i); 
		end
		spi_statusreg_i = 6'b010110;
		spi_data_i = 8'hA8;
		repeat (2) begin 
			@ (posedge spi_clk_i); 
		end
		spi_statusreg_i = 6'b010111;
		repeat (170) begin 
			@ (posedge spi_clk_i); 
		end
		spi_statusreg_i = 6'b010110;
		repeat (10) begin 
			@ (posedge spi_clk_i); 
		end
		$stop;
	end
	
	
	
	always begin
	#1 spi_clk_i = ~spi_clk_i;
	end
      
endmodule


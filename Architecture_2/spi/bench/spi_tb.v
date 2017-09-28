`timescale 1ns / 1ps



module spi_tb;

	// Inputs
	reg spi_clk_i;
	reg spi_rst_i;
	reg [47:0] spi_data_i;
	reg MISO;
	reg [7:0] spi_statusreg_i;

	// Outputs
	wire [31:0] spi_data_o;
	wire MOSI;
	wire SCK_SPI;
	wire SS;
	wire [7:0] R1;
	wire [2:0] spi_flagreg_o;

	// Instantiate the Unit Under Test (UUT)
	spi uut (
		.spi_clk_i(spi_clk_i), 
		.spi_rst_i(spi_rst_i), 
		.spi_data_i(spi_data_i), 
		.spi_data_o(spi_data_o), 
		.MOSI(MOSI), 
		.MISO(MISO), 
		.SCK_SPI(SCK_SPI), 
		.SS(SS), 
		.R1(R1), 
		.spi_flagreg_o(spi_flagreg_o), 
		.spi_statusreg_i(spi_statusreg_i)
	);

	initial begin
		// Initialize Inputs
		spi_clk_i = 0;
		spi_rst_i = 0;
		spi_data_i = 48'h56781234ABCD;
		MISO = 1;
		spi_statusreg_i = 8'b01000100;
		repeat (2) begin 
			@ (posedge spi_clk_i); 
		end
		spi_rst_i = 1;
		repeat (30) begin 
			@ (posedge spi_clk_i); 
		end
		spi_rst_i = 0;
		spi_statusreg_i = 8'b01000101;
		repeat (680) begin 
			@ (posedge spi_clk_i); 
		end
		spi_statusreg_i = 8'b01000100;
		repeat (80) begin 
			@ (posedge spi_clk_i); 
		end
		$stop;
	end

	  
	always begin
	#1 spi_clk_i = ~spi_clk_i;
	end
endmodule


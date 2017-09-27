`timescale 1ns / 1ps



module spi_init_tb;

	// Inputs
	reg spi_clk_i;
	reg spi_rst_i;
	reg SCK_SPI;
	reg spi_init_i;
	reg spi_enableoper_i;
	reg [47:0] spi_datamicro_i;
	reg [7:0] spi_statusregmicro_i;
	reg [7:0] R1;
	reg [2:0] spi_flagreg_i;

	// Outputs
	wire [47:0] spi_datainit_o;
	wire [7:0] spi_statusreginit_o;
	wire spi_initdone_o;

	// Instantiate the Unit Under Test (UUT)
	spi_init uut (
		.spi_clk_i(spi_clk_i), 
		.spi_rst_i(spi_rst_i), 
		.SCK_SPI(SCK_SPI),
		.spi_init_i(spi_init_i), 
		.spi_enableoper_i(spi_enableoper_i), 
		.spi_datamicro_i(spi_datamicro_i), 
		.spi_statusregmicro_i(spi_statusregmicro_i), 
		.R1(R1), 
		.spi_flagreg_i(spi_flagreg_i), 
		.spi_datainit_o(spi_datainit_o), 
		.spi_statusreginit_o(spi_statusreginit_o), 
		.spi_initdone_o(spi_initdone_o)
	);

	initial begin
		// Initialize Inputs
		spi_clk_i = 0;
		spi_rst_i = 1;
		SCK_SPI = 0;
		spi_init_i = 0;
		spi_enableoper_i = 0;
		spi_datamicro_i = 0;
		spi_statusregmicro_i = 0;
		R1 = 0;
		spi_flagreg_i = 0;
		repeat (2) begin 
			@ (posedge spi_clk_i); 
		end
		spi_rst_i = 0;
		spi_init_i = 1;
		spi_enableoper_i = 1;
		R1 = 8'h00;
		repeat (10) begin 
			@ (posedge spi_clk_i); 
		end
		spi_flagreg_i = 3'b010;
		repeat (10) begin 
			@ (posedge spi_clk_i); 
		end
		spi_flagreg_i = 3'b000;
		repeat (10) begin 
			@ (posedge spi_clk_i); 
		end
		spi_flagreg_i = 3'b010;
		repeat (10) begin 
			@ (posedge spi_clk_i); 
		end
		spi_flagreg_i = 3'b000;
		$stop;
	end
	
	always begin
	#1 spi_clk_i = ~spi_clk_i;
	end
	always begin
	#4 SCK_SPI = ~SCK_SPI;
	end
      
endmodule

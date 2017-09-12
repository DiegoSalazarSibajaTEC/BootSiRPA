`timescale 1ns / 1ps

module spi_std_tb;

	// Inputs
	reg spi_rst_i;
	reg spi_clk_i;
	reg spi_fbo_i;
	reg spi_start_i;
	reg [47:0] transmission_data_i;
	reg [1:0] clock_divider_i;
	reg MISO;
	reg spi_sendenb_i;

	// Outputs
	wire SS;
	wire SCK;
	wire MOSI;
	wire done;
	wire [79:0] received_data_o;
	wire spi_datawe_o;

	// Instantiate the Unit Under Test (UUT)
	spi_std uut (
		.spi_rst_i(spi_rst_i), 
		.spi_clk_i(spi_clk_i), 
		.spi_fbo_i(spi_fbo_i), 
		.spi_start_i(spi_start_i), 
		.transmission_data_i(transmission_data_i), 
		.clock_divider_i(clock_divider_i), 
		.MISO(MISO), 
		.SS(SS), 
		.SCK(SCK), 
		.MOSI(MOSI), 
		.done(done), 
		.received_data_o(received_data_o), 
		.spi_datawe_o(spi_datawe_o), 
		.spi_sendenb_i(spi_sendenb_i)
	);

	initial begin
		// Initialize Inputs
		spi_rst_i = 1;
		spi_clk_i = 0;
		spi_fbo_i = 0;
		spi_start_i = 0;
		transmission_data_i = 0'h00000000;
		clock_divider_i = 2'b00;
		MISO = 0;
		spi_sendenb_i = 0;
		repeat (3) begin 
			@ (posedge spi_clk_i); 
		end 
		spi_rst_i = 1'b0;
		repeat (3) begin 
			@ (posedge spi_clk_i); 
		end 
		spi_rst_i = 1'b1;
		repeat (3) begin 
			@ (posedge spi_clk_i); 
		end 
		spi_start_i = 1'b1;
		spi_sendenb_i = 1'b1;
		repeat (2748) begin 
			@ (posedge spi_clk_i); 
		end
		spi_start_i = 1'b0;
		repeat (1000) begin 
			@ (posedge spi_clk_i); 
		end
		spi_start_i = 1'b1;
		repeat (3000) begin 
			@ (posedge spi_clk_i); 
		end
		spi_start_i = 1'b0;
		repeat (1000) begin 
			@ (posedge spi_clk_i); 
		end
		spi_start_i = 1'b1;
		spi_sendenb_i = 1'b0;
		repeat (3000) begin 
			@ (posedge spi_clk_i); 
		end
		spi_start_i = 1'b0;
		repeat (1000) begin 
			@ (posedge spi_clk_i); 
		end
		$stop;
	end
	
	
	always begin
	#1 spi_clk_i = ~spi_clk_i;
	end
      
endmodule


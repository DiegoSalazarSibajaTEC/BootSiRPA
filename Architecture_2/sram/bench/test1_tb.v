`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:18:07 09/27/2017
// Design Name:   test1
// Module Name:   D:/Dropbox/TEC/DCiLab/ALE01BTP/FPGA/IntegracionA/test1_tb.v
// Project Name:  IntegracionA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: test1
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test1_tb;

	// Inputs
	reg test1_clk_i;
	reg test1_rst_i;
	reg [12:0] micro_sram_address_i;
	reg [31:0] micro_sram_datain_i;
	reg micro_sram_cs_i;
	reg micro_sram_we_i;
	reg micro_control;
	reg write_mem_init_i;
	reg fifo_writeflag_i;
	reg [31:0] fifo_writedata_i;

	// Outputs
	wire flag_writefinish_o;
	wire fifo_fullflag_o;
	wire [31:0] sram_data_o;

	// Instantiate the Unit Under Test (UUT)
	test1 uut (
		.test1_clk_i(test1_clk_i), 
		.test1_rst_i(test1_rst_i), 
		.micro_sram_address_i(micro_sram_address_i), 
		.micro_sram_datain_i(micro_sram_datain_i), 
		.micro_sram_cs_i(micro_sram_cs_i), 
		.micro_sram_we_i(micro_sram_we_i), 
		.micro_control(micro_control), 
		.write_mem_init_i(write_mem_init_i), 
		.fifo_writeflag_i(fifo_writeflag_i), 
		.fifo_writedata_i(fifo_writedata_i), 
		.flag_writefinish_o(flag_writefinish_o), 
		.fifo_fullflag_o(fifo_fullflag_o), 
		.sram_data_o(sram_data_o)
	);

	initial begin
		// Initialize Inputs
		test1_clk_i = 0;
		test1_rst_i = 1;
		micro_sram_address_i = 0;
		micro_sram_datain_i = 0;
		micro_sram_cs_i = 0;
		micro_sram_we_i = 0;
		micro_control = 0;
		write_mem_init_i = 0;
		fifo_writeflag_i = 0;
		fifo_writedata_i = 0;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end
		test1_rst_i = 0;
		micro_control = 1;
		write_mem_init_i = 0;//----ESCRITURA FIFO
		fifo_writeflag_i = 1;
		fifo_writedata_i = 32'hADAD0011;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end
		fifo_writeflag_i = 0;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end//---
		fifo_writeflag_i = 1;
		fifo_writedata_i = 32'h000A0201;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end
		fifo_writeflag_i = 0;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end//---
		fifo_writeflag_i = 1;
		fifo_writedata_i = 32'h00000001;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end
		fifo_writeflag_i = 0;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end//---
		fifo_writeflag_i = 1;
		fifo_writedata_i = 32'hABCD1234;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end
		fifo_writeflag_i = 0;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end//---ESCRITURA SRAM
		write_mem_init_i = 1;
		repeat (20) begin 
			@ (posedge test1_clk_i); 
		end//--LECTURA SRAM
		write_mem_init_i = 0;
		micro_control = 0;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end
		micro_sram_address_i = 13'h0000;
		micro_sram_datain_i = 0;
		micro_sram_cs_i = 0;
		micro_sram_we_i = 1;
		repeat (1) begin 
			@ (posedge test1_clk_i); 
		end
		micro_sram_cs_i = 1;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end//---
		micro_sram_address_i = 13'h0001;
		micro_sram_datain_i = 0;
		micro_sram_cs_i = 0;
		micro_sram_we_i = 1;
		repeat (1) begin 
			@ (posedge test1_clk_i); 
		end
		micro_sram_cs_i = 1;
		repeat (2) begin 
			@ (posedge test1_clk_i); 
		end//--
		micro_sram_address_i = 13'h0002;
		micro_sram_datain_i = 0;
		micro_sram_cs_i = 0;
		micro_sram_we_i = 1;
		repeat (1) begin 
			@ (posedge test1_clk_i); 
		end
		micro_sram_cs_i = 1;
		repeat (5) begin 
			@ (posedge test1_clk_i); 
		end//--
		$stop;
	end
      
	  
always begin
	#1 test1_clk_i = ~test1_clk_i;
	end	  

endmodule


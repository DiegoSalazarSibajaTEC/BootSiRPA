`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:13:52 10/13/2017
// Design Name:   control_fpgaram
// Module Name:   D:/Dropbox/TEC/Semestres/XI Semestre-PdG/Github/BootSiRPA/FPGA_Projects/bootstrap/control_fpgaram_tb.v
// Project Name:  bootstrap
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: control_fpgaram
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module control_fpgaram_tb;

	// Inputs
	reg control_mem_clk_i;
	reg control_mem_rst_i;
	reg [21:0] micro_sram_address_i;
	reg [31:0] micro_sram_datain_i;
	reg micro_sram_cs_i;
	reg micro_sram_we_i;
	reg micro_sram_oe_i;
	reg [1:0] micro_sram_lb_ub_i;
	reg micro_sram_adv_i;
	reg micro_control;
	reg [1:0] write_enable_i;
	reg [31:0] fifo_datain_i;

	// Outputs
	wire read_fifo_o;
	wire [21:0] sram_address_o;
	wire [31:0] sram_datain_o;
	wire sram_cs_o;
	wire sram_we_o;
	wire sram_oe_o;
	wire [1:0] sram_lb_ub_o;
	wire sram_adv_o;
	wire sram_wait_o;

	// Instantiate the Unit Under Test (UUT)
	control_fpgaram uut (
		.control_mem_clk_i(control_mem_clk_i), 
		.control_mem_rst_i(control_mem_rst_i), 
		.micro_sram_address_i(micro_sram_address_i), 
		.micro_sram_datain_i(micro_sram_datain_i), 
		.micro_sram_cs_i(micro_sram_cs_i), 
		.micro_sram_we_i(micro_sram_we_i), 
		.micro_sram_oe_i(micro_sram_oe_i), 
		.micro_sram_lb_ub_i(micro_sram_lb_ub_i), 
		.micro_sram_adv_i(micro_sram_adv_i), 
		.micro_control(micro_control), 
		.write_enable_i(write_enable_i), 
		.fifo_datain_i(fifo_datain_i), 
		.read_fifo_o(read_fifo_o), 
		.sram_address_o(sram_address_o), 
		.sram_datain_o(sram_datain_o), 
		.sram_cs_o(sram_cs_o), 
		.sram_we_o(sram_we_o), 
		.sram_oe_o(sram_oe_o), 
		.sram_lb_ub_o(sram_lb_ub_o), 
		.sram_adv_o(sram_adv_o), 
		.sram_wait_o(sram_wait_o)
	);

	initial begin
		// Initialize Inputs
		control_mem_clk_i = 0;
		control_mem_rst_i = 0;
		micro_sram_address_i = 0;
		micro_sram_datain_i = 0;
		micro_sram_cs_i = 0;
		micro_sram_we_i = 0;
		micro_sram_oe_i = 0;
		micro_sram_lb_ub_i = 0;
		micro_sram_adv_i = 0;
		micro_control = 0;
		write_enable_i = 0;
		fifo_datain_i = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule


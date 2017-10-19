`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:30:26 10/19/2017
// Design Name:   CRC_7
// Module Name:   D:/Dropbox/TEC/Semestres/XI Semestre-PdG/Github/BootSiRPA/FPGA_Projects/bootstrap/crctb.v
// Project Name:  bootstrap
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CRC_7
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module crctb;

	// Inputs
	reg crc_7_enable;
	reg control_clk_i;
	reg control_rst_i;
	reg [39:0] data_crc;

	// Outputs
	wire [6:0] CRC;
	wire flag_crc_done;

	// Instantiate the Unit Under Test (UUT)
	CRC_7 uut (
		.crc_7_enable(crc_7_enable), 
		.control_clk_i(control_clk_i), 
		.control_rst_i(control_rst_i), 
		.CRC(CRC), 
		.flag_crc_done(flag_crc_done), 
		.data_crc(data_crc)
	);

	initial begin
		// Initialize Inputs
		crc_7_enable = 0;
		control_clk_i = 0;
		control_rst_i = 0;
		data_crc = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule


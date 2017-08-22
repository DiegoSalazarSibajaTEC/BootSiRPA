`timescale 1ns / 1ps

module CRC_tb2;

	// Inputs
	reg Enable;
	reg CLK;
	reg RST;
	reg [39:0] data_i;

	// Outputs
	wire [6:0] CRC;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	CRC_7 uut (
		.Enable(Enable), 
		.CLK(CLK), 
		.RST(RST), 
		.CRC(CRC), 
		.done(done), 
		.data_i(data_i)
	);

	initial begin
		// Initialize Inputs
		Enable = 0;
		CLK = 0;
		RST = 0;
		data_i = 0;
		#2;
		RST=1;
		#4
		data_i= 40'h4000000000;
		RST=0;
		#2
		Enable = 1;
		#170;
		Enable = 0;
		data_i= 40'h5100000000;
		#50
		Enable = 1;
		#200
		$stop;
        
	

	end
	
	always begin
	#2 CLK=~CLK;
	end
      
endmodule


`timescale 1ns / 1ps

module CRC_tb;

	reg BITVAL;// Next input bit  
    reg Enable;  
    reg CLK;                           // Current bit valid (Clock)  
    reg RST;                             // Init CRC value  
    wire [6:0] CRC;      

	// Instantiate the Unit Under Test (UUT)
	CRC_7 uut (
		.BITVAL(BITVAL), 
		.Enable(Enable), 
		.CLK(CLK), 
		.RST(RST), 
		.CRC(CRC)
	);
	
	
	initial begin
	BITVAL=0;
	Enable=0;
	CLK=0;
	RST=0;
	#2
	RST=1;
	#4
	RST=0;
	Enable=1;
	#4
	BITVAL=0;
	#4
	BITVAL=1;
	#4
	BITVAL=0;//1
	#4
	BITVAL=1;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=1;//6
	#4
	BITVAL=0;//1
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;//20
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	BITVAL=0;
	#4
	Enable=0;
	#8
	$stop;
	
	
	
	
	
	end
	
	
	always begin
	#2 CLK=~CLK;
	end
	
	endmodule
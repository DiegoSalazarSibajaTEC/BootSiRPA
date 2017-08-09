`timescale 1ns / 1ps
module CRC_7( Enable, CLK, RST, CRC, done,data_i);  
input	[39:0]	data_i; 
input 			Enable;  
input        	CLK;                            
input        	RST;                            
output	[6:0]	CRC;                         
output  		done;
reg 	[6:0] 	CRC; 
reg 			done;

reg 			BITVAL;
reg		[39:0]	data_int;
reg 	[7:0]	counter;
reg 	[6:0] 	CRC_INT; 
wire         	inv;
  
assign inv = BITVAL ^ CRC_INT[6];                   // XOR required  



always @(posedge CLK or posedge RST) begin
	
	if(RST)begin
		done <= 1'b0;
		counter<= 6'h00;
		BITVAL <= 1'B0;
		CRC_INT <= 0;
		CRC <= 0;
	end 
	
	if(counter == 8'h29) begin
		done <= 1'b1;
		CRC <= CRC_INT;
	end
	else if(counter != 8'h29)begin
		done <= 1'b0;
		CRC <=CRC;
	end
	

	if(Enable==1'b0)begin
		data_int <= data_i;
		counter<= 6'h00;
		CRC_INT <= 0;
	end

	else if (Enable==1'b1)begin 
		BITVAL <= data_int[39];
		data_int <= {data_int[38:0],1'b0};
		counter <= counter+8'h01;
		CRC_INT[6] <= CRC_INT[5];  
		CRC_INT[5] <= CRC_INT[4];  
		CRC_INT[4] <= CRC_INT[3];  
		CRC_INT[3] <= CRC_INT[2] ^ inv;  
		CRC_INT[2] <= CRC_INT[1];  
		CRC_INT[1] <= CRC_INT[0];  
		CRC_INT[0] <= inv;
	end  

end  

	 
endmodule  
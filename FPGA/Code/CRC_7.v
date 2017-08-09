`timescale 1ns / 1ps
module CRC_7( crc_7_enable, control_clk_i, control_rst_i, CRC, flag_crc_done,data_crc);  
input	[39:0]	data_crc; 
input 			crc_7_enable;  
input        	control_clk_i;                            
input        	control_rst_i;                            
output	[6:0]	CRC;                         
output  		flag_crc_done;
reg 	[6:0] 	CRC; 
reg 			flag_crc_done;

reg 			BITVAL;
reg		[39:0]	reg_data_crc;
reg 	[7:0]	counter;
reg 	[6:0] 	CRC_INT; 
wire         	inv;
  
assign inv = BITVAL ^ CRC_INT[6];                   // XOR required  



always @(posedge control_clk_i or posedge control_rst_i) begin
	
	if(control_rst_i)begin
		flag_crc_done <= 1'b0;
		counter<= 6'h00;
		BITVAL <= 1'B0;
		CRC_INT <= 0;
		CRC <= 0;
	end 
	
	if(counter == 8'h29) begin
		flag_crc_done <= 1'b1;
		CRC <= CRC_INT;
	end
	else if(counter != 8'h29)begin
		flag_crc_done <= 1'b0;
		CRC <=CRC;
	end
	

	if(crc_7_enable==1'b0)begin
		reg_data_crc <= data_crc;
		counter<= 6'h00;
		CRC_INT <= 0;
	end

	else if (crc_7_enable==1'b1)begin 
		BITVAL <= reg_data_crc[39];
		reg_data_crc <= {reg_data_crc[38:0],1'b0};
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
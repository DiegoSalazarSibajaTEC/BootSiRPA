
`timescale 1ns / 1ps

module sram #(parameter ADDRESS_WIDTH =13, DATA_WIDTH=32)(sram_clk, sram_address, sram_data_i, sram_data_o, sram_cs, sram_we);

parameter  data_width = 32;
parameter  address_width = 13; 

input 							sram_clk;
input 		[ADDRESS_WIDTH-1:0]	sram_address;
input 		[DATA_WIDTH-1:0]	sram_data_i;
input 							sram_cs;
input 							sram_we;
output wire	[DATA_WIDTH-1:0]	sram_data_o;

reg		[DATA_WIDTH-1:0] data_out;
reg		[DATA_WIDTH-1:0] mem  [0:(2*ADDRESS_WIDTH)-1];


assign sram_data_o = (!sram_cs && sram_we) ? data_out : sram_data_o;

always @ (posedge sram_clk)
  begin 
     if ( !sram_cs && !sram_we ) begin
         mem[sram_address] = sram_data_i;
     end
 end


always @ (posedge sram_clk)
  begin 
    if (!sram_cs &&  sram_we ) begin
      data_out = mem[sram_address];
    end else begin
      data_out = data_out;
    end
  end

endmodule
`timescale 1ns / 1ps

module sram(sram_clk, sram_address, sram_data_i, sram_data_o, sram_cs, sram_we, sram_oe, sram_oe_r);

parameter  data_width = 32;
parameter  address_width = 13; 
parameter  ram_depth = 8192; //8k directions
input 							sram_clk;
input 		[address_width-1:0]	sram_address;
input 		[data_width-1:0]	sram_data_i;
input 							sram_cs;
input 							sram_we;
input 							sram_oe;
output wire	[data_width-1:0]	sram_data_o;
output reg						sram_oe_r;

reg		[data_width-1:0] data_out;
reg		[data_width-1:0] mem  [0:ram_depth-1];


assign sram_data_o = (sram_cs && sram_oe && !sram_we) ? data_out : 32'bz;

always @ (posedge sram_clk)
  begin 
     if ( sram_cs && sram_we ) begin
         mem[sram_address] = sram_data_i;
     end
 end


always @ (posedge sram_clk)
  begin 
    if (sram_cs &&  ! sram_we && sram_oe) begin
      data_out = mem[sram_address];
      sram_oe_r = 1;
    end else begin
      sram_oe_r = 0;
    end
  end

endmodule
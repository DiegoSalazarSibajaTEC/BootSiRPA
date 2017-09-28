`timescale 1ns / 1ps

module control_mem #(parameter ADDRESS_WIDTH =13, DATA_WIDTH=32)(control_mem_clk_i, control_mem_rst_i, micro_sram_address_i, micro_sram_datain_i, micro_sram_cs_i, 
					micro_sram_we_i, micro_control, write_mem_init_i, fifo_datain_i, fifo_empty_i, sram_address_o, sram_datain_o, sram_cs_o, sram_we_o, read_fifo_o, 
					flag_writefinish_o);
input							control_mem_clk_i;
input							control_mem_rst_i;
input  		[ADDRESS_WIDTH-1:0]	micro_sram_address_i;
input 		[DATA_WIDTH-1:0]	micro_sram_datain_i;
input  							micro_sram_cs_i;
input 							micro_sram_we_i;
input							micro_control; //1 controlado por init 0 controlado por micro
input							write_mem_init_i;
input 		[DATA_WIDTH-1:0]	fifo_datain_i;
input							fifo_empty_i;
output wire [ADDRESS_WIDTH-1:0]	sram_address_o;
output wire	[DATA_WIDTH-1:0]	sram_datain_o;
output wire 					sram_cs_o;
output wire						sram_we_o;
output reg						read_fifo_o;
output reg						flag_writefinish_o;

reg [ADDRESS_WIDTH-1:0]	sram_address;
//reg	[DATA_WIDTH-1:0]	sram_datain;
reg						sram_cs;
reg						sram_we;

assign sram_address_o 	= (micro_control) ?  sram_address : micro_sram_address_i;
assign sram_datain_o  	= (micro_control) ?  fifo_datain_i  : micro_sram_datain_i;
assign sram_cs_o 		= (micro_control) ?  sram_cs      : micro_sram_cs_i;
assign sram_we_o 		= (micro_control) ?  sram_we      : micro_sram_we_i;


reg	[1:0]	write_init_counter;
reg 		address_count_en;

always@(posedge control_mem_clk_i or posedge control_mem_rst_i)begin
	if(control_mem_rst_i)begin
		write_init_counter <= 2'b00;
		sram_address	<= 32'd0;
	end
	else if(write_mem_init_i)begin
		write_init_counter <= write_init_counter + 2'b01;
		if(address_count_en) begin
			sram_address <= sram_address + 1'd1;
		end
		else begin
			sram_address <= sram_address;
		end
	end
end

always@(posedge control_mem_clk_i)begin	
	if(fifo_empty_i)begin
		flag_writefinish_o <= 1'b1;
	end
	else begin
		flag_writefinish_o <= 1'b0;
	end
end

always@* begin
	read_fifo_o = 1'b0;
	address_count_en = 1'b0;
	sram_cs = 1; 
	sram_we = 1;
	if(write_mem_init_i)begin
	case(write_init_counter)
		2'b00: begin read_fifo_o=1'b1; address_count_en = 1'b1; end
		2'b01: begin read_fifo_o=1'b0; address_count_en = 1'b0; end
		2'b10: begin sram_cs = 0; sram_we = 0; end
		2'b11: begin sram_cs = 1; sram_we = 1; end
	endcase
	end
end




endmodule
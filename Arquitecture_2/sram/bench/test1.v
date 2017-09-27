`timescale 1ns / 1ps

module test1 (test1_clk_i, test1_rst_i, micro_sram_address_i, micro_sram_datain_i, micro_sram_cs_i, micro_sram_we_i, micro_control, write_mem_init_i,  
			 fifo_writeflag_i, fifo_writedata_i, flag_writefinish_o, fifo_fullflag_o, sram_data_o);
parameter DATA_WIDTH = 32;
parameter ADDRESS_WIDTH =13;

input							test1_clk_i;
input							test1_rst_i;
input  		[ADDRESS_WIDTH-1:0]	micro_sram_address_i;
input 		[DATA_WIDTH-1:0]	micro_sram_datain_i;
input  							micro_sram_cs_i;
input 							micro_sram_we_i;
input							micro_control; //1 controlado por init 0 controlado por micro
input							write_mem_init_i;
input							fifo_writeflag_i;
input		[DATA_WIDTH-1:0]	fifo_writedata_i;
output wire						flag_writefinish_o;
output wire						fifo_fullflag_o;
output wire [DATA_WIDTH-1:0]	sram_data_o;


wire	[DATA_WIDTH-1:0]	fifo_data;
wire 	[ADDRESS_WIDTH-1:0]	sram_address;
wire	[DATA_WIDTH-1:0]	sram_datain;
wire 						sram_cs;
wire						sram_we;
wire						read_fifo_flag;
wire						fifo_empty;

fifo #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH))A1 (
    .fifo_clk_i(test1_clk_i), //
    .fifo_rst_i(test1_rst_i), //
    .fifo_readflag_i(read_fifo_flag), //
    .fifo_writeflag_i(fifo_writeflag_i), //
    .fifo_writedata_i(fifo_writedata_i), //
    .fifo_emptyflag_o(fifo_empty), //
    .fifo_fullflag_o(fifo_fullflag_o), //
    .fifo_readdata_o(fifo_data)//
    );

sram A2 (
    .sram_clk(test1_clk_i), //
    .sram_address(sram_address), //
    .sram_data_i(sram_datain), //
    .sram_data_o(sram_data_o), 
    .sram_cs(sram_cs), //
    .sram_we(sram_we)//
    );
	
control_mem A3 (
    .control_mem_clk_i(test1_clk_i), //
    .control_mem_rst_i(test1_rst_i), //
    .micro_sram_address_i(micro_sram_address_i), //
    .micro_sram_datain_i(micro_sram_datain_i), //
    .micro_sram_cs_i(micro_sram_cs_i), //
    .micro_sram_we_i(micro_sram_we_i), //
    .micro_control(micro_control), //
    .write_mem_init_i(write_mem_init_i), //
    .fifo_datain_i(fifo_data), //
	.fifo_empty_i(fifo_empty),//
    .sram_address_o(sram_address), //
    .sram_datain_o(sram_datain), //
    .sram_cs_o(sram_cs), //
    .sram_we_o(sram_we), //
    .read_fifo_o(read_fifo_flag), //
    .flag_writefinish_o(flag_writefinish_o)//
    );

endmodule
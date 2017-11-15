`timescale 1ns / 1ps
/********************************************************************************
Bootstrap DCILAB 2017
Instituto Tecnológico de Costa Rica

Diego Salazar Sibaja

Modulo: RAM

Descripción general: RAM auxiliar para la unidad FIFO.

*********************************************************************************/
module ram_dual#( parameter ADDRESS_WIDTH = 6, DATA_WIDTH = 32)(dualram_clk_i, dualram_writeen_i, dualram_read_addr_i, dualram_write_addr_i, 
																dualram_writedata_i, dualram_readdata_o);

input 	wire 						dualram_clk_i;                                            // clk for synchronous read/write 
input 	wire 						dualram_writeen_i;                                        // signal to enable synchronous write
input 	wire [ADDRESS_WIDTH-1:0] 	dualram_read_addr_i, dualram_write_addr_i; // inputs for dual port addresses
input 	wire [DATA_WIDTH-1:0]  		dualram_writedata_i;                 // input for data to write to ram
output 	wire [DATA_WIDTH-1:0]  		dualram_readdata_o;  // outputs for dual data ports


// internal signal declarations
reg [DATA_WIDTH-1:0] ram [0:2**ADDRESS_WIDTH-1];             // ADDRESS_WIDTH x DATA_WIDTH RAM declaration
reg [ADDRESS_WIDTH-1:0] read_address_reg; // dual port address declarations
	
	// synchronous write and address update
always @(posedge dualram_clk_i)begin
	if(dualram_writeen_i)begin						 // if write enabled
	   ram[dualram_write_addr_i] <= dualram_writedata_i; // write data to ram and write_address 
	end
	read_address_reg  <= dualram_read_addr_i;      // store read_address to reg
end
	
	// assignments for two data out ports
assign  dualram_readdata_o = ram[dualram_read_addr_i];

endmodule
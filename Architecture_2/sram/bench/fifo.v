`timescale 1ns / 1ps
module fifo#(parameter ADDRESS_WIDTH =13, DATA_WIDTH=32)(fifo_clk_i, fifo_rst_i, fifo_readflag_i, fifo_writeflag_i, fifo_writedata_i, fifo_emptyflag_o, 
														fifo_fullflag_o, fifo_readdata_o);
	
input 	wire 					fifo_clk_i, fifo_rst_i;
input 	wire 					fifo_readflag_i, fifo_writeflag_i;
input 	wire [DATA_WIDTH-1:0] 	fifo_writedata_i;
output 	wire 					fifo_emptyflag_o, fifo_fullflag_o;
output 	wire [DATA_WIDTH-1:0] 	fifo_readdata_o;


// internal signal declarations
reg [ADDRESS_WIDTH-1:0] write_address_reg, write_address_next, write_address_after;
reg [ADDRESS_WIDTH-1:0] read_address_reg, read_address_next, read_address_after;
reg 					full_reg, empty_reg, full_next, empty_next;
wire 					write_en;

// write enable is asserted when write input is asserted and FIFO isn't full
assign write_en = fifo_writeflag_i & ~full_reg;
// assign full/empty status to output ports
assign fifo_fullflag_o  = full_reg;
assign fifo_emptyflag_o = empty_reg;
// instantiate synchronous block ram
ram_dual #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ram
		(.dualram_clk_i(fifo_clk_i), .dualram_writeen_i(write_en), .dualram_read_addr_i(read_address_reg),
		 .dualram_write_addr_i(write_address_reg), .dualram_writedata_i(fifo_writedata_i),.dualram_readdata_o(fifo_readdata_o));

// register for address pointers, full/empty status
always @(posedge fifo_clk_i or posedge fifo_rst_i)begin
	if (fifo_rst_i)
		begin
				write_address_reg <= 0;
				read_address_reg  <= 0;
				full_reg          <= 1'b0;
				empty_reg         <= 1'b1;
		end
	else
		begin
				write_address_reg <= write_address_next;
				read_address_reg  <= read_address_next;
				full_reg          <= full_next;
				empty_reg         <= empty_next;
		end
end		
// next-state logic for address index values after read/write operations
always @*
	begin
	write_address_after = write_address_reg + 1'd1;
	read_address_after  = read_address_reg + 1'd1;
	end
	
// next-state logic for address pointers
always @*
	begin
	// defaults
	write_address_next = write_address_reg;
	read_address_next  = read_address_reg;
	full_next          = full_reg;
	empty_next         = empty_reg;
	
	// if read input asserted and FIFO isn't empty
	if(fifo_readflag_i && ~empty_reg && ~fifo_writeflag_i)begin
		read_address_next = read_address_after;       // read address moves forward
		full_next = 1'b0;                             // FIFO isn't full if a read occured
		if (read_address_after == write_address_reg)  // if read address caught up with write address,
			empty_next = 1'b1;                        // FIFO is empty
		end
	
	// if write input asserted and FIFO isn't full
	else if(fifo_writeflag_i && ~full_reg && ~fifo_readflag_i)	begin
			write_address_next = write_address_after;     // write address moves forward
			empty_next = 1'b0;                            // FIFO isn't empty if write occured
			if (write_address_after == read_address_reg)    // if write address caught up with read address
				full_next = 1'b1;                         // FIFO is full
			end
	// if write and read are asserted
			else if(fifo_writeflag_i && fifo_readflag_i)begin
				write_address_next = write_address_after;     // write address moves forward
				read_address_next  = read_address_after;      // read address moves forward
			end
	end 

endmodule
`timescale 1ns / 1ps

module fifo_tb;

	// Inputs
	reg fifo_clk_i;
	reg fifo_rst_i;
	reg fifo_readflag_i;
	reg fifo_writeflag_i;
	reg [31:0] fifo_writedata_i;

	// Outputs
	wire fifo_emptyflag_o;
	wire fifo_fullflag_o;
	wire [31:0] fifo_readdata_o;

	// Instantiate the Unit Under Test (UUT)
	fifo uut (
		.fifo_clk_i(fifo_clk_i), 
		.fifo_rst_i(fifo_rst_i), 
		.fifo_readflag_i(fifo_readflag_i), 
		.fifo_writeflag_i(fifo_writeflag_i), 
		.fifo_writedata_i(fifo_writedata_i), 
		.fifo_emptyflag_o(fifo_emptyflag_o), 
		.fifo_fullflag_o(fifo_fullflag_o), 
		.fifo_readdata_o(fifo_readdata_o)
	);

	initial begin
		// Initialize Inputs
		fifo_clk_i = 0;
		fifo_rst_i = 1;
		fifo_readflag_i = 0;
		fifo_writeflag_i = 0;
		fifo_writedata_i = 0;

		repeat (2) begin 
			@ (posedge fifo_clk_i); 
		end
		fifo_rst_i = 0;
		fifo_writedata_i =32'h0000AD00;
		fifo_writeflag_i =1'b1;
		repeat (1) begin 
			@ (posedge fifo_clk_i); 
		end
		fifo_writeflag_i =1'b0;
		repeat (4) begin 
			@ (posedge fifo_clk_i); 
		end//-------
		fifo_writedata_i =32'h00000001;
		fifo_writeflag_i =1'b1;
		repeat (1) begin 
			@ (posedge fifo_clk_i); 
		end
		fifo_writeflag_i =1'b0;
		repeat (4) begin 
			@ (posedge fifo_clk_i); 
		end
		fifo_writedata_i =32'h00000002;
		fifo_writeflag_i =1'b1;
		repeat (1) begin 
			@ (posedge fifo_clk_i); 
		end
		fifo_writeflag_i =1'b0;
		repeat (4) begin 
			@ (posedge fifo_clk_i); 
		end//-------
		fifo_writedata_i =32'h00000003;
		fifo_writeflag_i =1'b1;
		repeat (1) begin 
			@ (posedge fifo_clk_i); 
		end
		fifo_writeflag_i =1'b0;
		repeat (4) begin 
			@ (posedge fifo_clk_i); 
		end//-------
		fifo_writedata_i =32'h00000005;
		fifo_writeflag_i =1'b1;
		repeat (1) begin 
			@ (posedge fifo_clk_i); 
		end
		fifo_writeflag_i =1'b0;
		repeat (4) begin 
			@ (posedge fifo_clk_i); 
		end//-------
		fifo_readflag_i =1'b1;
		repeat (40) begin 
			@ (posedge fifo_clk_i); 
		end
		
		$stop;
	end
      
	always begin
	#1 fifo_clk_i = ~fifo_clk_i;
	end
	  
	  
	  
endmodule
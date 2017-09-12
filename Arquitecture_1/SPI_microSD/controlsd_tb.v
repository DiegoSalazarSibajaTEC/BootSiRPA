`timescale 1ns / 1ps

module controlsd_tb;

	// Inputs
	reg [31:0] sd_address_i;
	reg control_rst_i;
	reg control_clk_i;
	reg control_we_i;
	reg control_re_i;
	reg [31:0] control_dataw_i;
	reg MISO;
	reg control_nextoper_i;

	// Outputs
	wire SCK;
	wire [31:0] mem_data_o;
	wire MOSI;
	wire control_done_o;
	wire SS;

	// Instantiate the Unit Under Test (UUT)
	controlmicro_sd uut (
		.sd_address_i(sd_address_i), 
		.control_rst_i(control_rst_i), 
		.control_clk_i(control_clk_i), 
		.control_we_i(control_we_i), 
		.control_re_i(control_re_i), 
		.control_dataw_i(control_dataw_i), 
		.MISO(MISO), 
		.control_nextoper_i(control_nextoper_i), 
		.SCK(SCK), 
		.mem_data_o(mem_data_o), 
		.MOSI(MOSI), 
		.control_done_o(control_done_o), 
		.SS(SS)
	);

	initial begin
		// Initialize Inputs
		sd_address_i = 0'hFAFAFAFA;
		control_rst_i = 1;
		control_clk_i = 0;
		control_we_i = 0;
		control_re_i = 1;
		control_dataw_i = 0'hEDEDEDE1;
		MISO = 0;
		control_nextoper_i = 0;
		repeat (4) begin 
			@ (posedge control_clk_i); 
		end 
		control_rst_i = 0;
		repeat (13600) begin 
			@ (posedge control_clk_i); 
		end 
		repeat (2720) begin 
			@ (posedge control_clk_i); 
		end 
		/*repeat (2400) begin  //read
			@ (posedge control_clk_i); 
		end 
		control_nextoper_i = 1;
		repeat (2) begin 
			@ (posedge control_clk_i); 
		end 
		control_nextoper_i = 0;
		repeat (5000) begin 
			@ (posedge control_clk_i); 
		end */
		
		repeat (2398) begin 
			@ (posedge control_clk_i); 
		end 
		control_nextoper_i = 1;
		repeat (2) begin 
			@ (posedge control_clk_i); 
		end 
		control_nextoper_i = 0;
		repeat (5000) begin 
			@ (posedge control_clk_i); 
		end 
		control_nextoper_i = 1;
		control_we_i = 1;
		control_re_i = 0;
		repeat (2) begin 
			@ (posedge control_clk_i); 
		end 
		control_nextoper_i = 0;
		repeat (2720) begin 
			@ (posedge control_clk_i); 
		end 
		$stop;
		
	end
      
	  
	always begin
	#1 control_clk_i = ~control_clk_i;
	end
	  
endmodule


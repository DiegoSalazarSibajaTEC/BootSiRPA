`timescale 1ns / 1ps

module control_sram #(parameter ADDRESS_WIDTH =13, DATA_WIDTH=32)(control_mem_clk_i, control_mem_rst_i, micro_sram_address_i, micro_sram_datain_i, micro_sram_cs_i, 
					micro_sram_we_i, micro_control, write_enable_i, fifo_datain_i, read_fifo_o, sram_address_o, sram_datain_o, sram_cs_o, sram_we_o);
					
input							control_mem_clk_i;
input							control_mem_rst_i;
//------------------------------------------------------------------------------
input  		[ADDRESS_WIDTH-1:0]	micro_sram_address_i;//----SEÑAL MICROPROCESADOR
input 		[DATA_WIDTH-1:0]	micro_sram_datain_i;//-----SEÑAL MICROPROCESADOR
input  							micro_sram_cs_i;//---------SEÑAL MICROPROCESADOR
input 							micro_sram_we_i;//---------SEÑAL MICROPROCESADOR
//------------------------------------------------------------------------------
input							micro_control; //INDICA SI MICRO CONTROLA ESCRITURA 1-INIT 0-MICROPROCESADOR
input		[1:0]				write_enable_i; //----INDICA ESCRITURA HABILITADA
//------------------------------------------------------------------------------
input 		[DATA_WIDTH-1:0]	fifo_datain_i;//------FIFO CONTROL
output reg						read_fifo_o; //-------FIFO CONTROL
//------------------------------------------------------------------------------
output wire [ADDRESS_WIDTH-1:0]	sram_address_o;//----SRAM CONTROL
output wire	[DATA_WIDTH-1:0]	sram_datain_o;//-----SRAM CONTROL
output wire 					sram_cs_o;//---------SRAM CONTROL
output wire						sram_we_o;//---------SRAM CONTROL

reg [ADDRESS_WIDTH-1:0]	sram_address;
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
	else begin
		if(write_enable_i[1])begin
			write_init_counter <= write_init_counter + 2'b01;
			if(address_count_en) begin
				sram_address <= sram_address + 1'd1;
			end
			else begin
				sram_address <= sram_address;
			end
		end
		else if(!write_enable_i[1]) begin
			write_init_counter <= 2'b00;
		end
	end
end


always@* begin
	read_fifo_o = 1'b0;
	address_count_en = 1'b0;
	sram_cs = 1; 
	sram_we = 1;
	if(write_enable_i[0])begin
		case(write_init_counter)
			2'b00: begin read_fifo_o=1'b1; address_count_en = 1'b1; end
			2'b01: begin read_fifo_o=1'b0; address_count_en = 1'b0; end
			2'b10: begin sram_cs = 0; sram_we = 0; end
			2'b11: begin sram_cs = 1; sram_we = 1; end
		endcase
	end
	else if(!write_enable_i[0])begin
		case(write_init_counter)
			2'b00: begin read_fifo_o=1'b1; end
			2'b01: begin read_fifo_o=1'b0; end
		endcase
	end
	
end




endmodule
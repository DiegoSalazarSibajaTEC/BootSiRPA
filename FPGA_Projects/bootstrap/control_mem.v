`timescale 1ns / 1ps

module control_mem #(parameter ADDRESS_WIDTH =22, DATA_WIDTH=32, FPGA_DATA_WIDTH=16)
						(control_mem_clk_i, control_mem_rst_i, micro_sram_address_i, micro_sram_datain_i,micro_sram_control,
						micro_control, write_enable_i, fifo_datain_i, read_fifo_o, sram_address_o, sram_datain_o, sram_cs_o, 
						sram_we_o, sram_oe_o, sram_lb_ub_o, sram_adv_o, sram_wait_o);
					
input								control_mem_clk_i;
input								control_mem_rst_i;
//------------------------------------------------------------------------------
input  		[ADDRESS_WIDTH-1:0]		micro_sram_address_i;//----SEÑAL MICROPROCESADOR
input 		[FPGA_DATA_WIDTH-1:0]	micro_sram_datain_i;//-----SEÑAL MICROPROCESADOR
input		[5:0]					micro_sram_control;
/****************************************************
input  								micro_sram_cs_i;//---------SEÑAL MICROPROCESADOR
input 								micro_sram_we_i;//---------SEÑAL MICROPROCESADOR
input								micro_sram_oe_i;//
input		[1:0]					micro_sram_lb_ub_i;
input								micro_sram_adv_i;
*****************************************************/
//------------------------------------------------------------------------------
input								micro_control; //INDICA SI MICRO CONTROLA ESCRITURA 1-INIT 0-MICROPROCESADOR
input		[1:0]					write_enable_i; //----INDICA ESCRITURA HABILITADA
//------------------------------------------------------------------------------
input 		[DATA_WIDTH-1:0]		fifo_datain_i;//------FIFO CONTROL
output reg							read_fifo_o; //-------FIFO CONTROL
//------------------------------------------------------------------------------
output wire [ADDRESS_WIDTH-1:0]		sram_address_o;//----SRAM CONTROL
output wire	[FPGA_DATA_WIDTH-1:0]	sram_datain_o;//-----SRAM CONTROL
output wire 						sram_cs_o;//---------SRAM CONTROL
output wire							sram_we_o;//---------SRAM CONTROL
output wire							sram_oe_o;
output wire	[1:0]					sram_lb_ub_o;
output wire							sram_adv_o;
output reg							sram_wait_o;

reg [ADDRESS_WIDTH-1:0]	sram_address;
reg						sram_cs;
reg						sram_we;
reg						sram_oe;
reg	[1:0]				sram_lb_ub;
reg						sram_adv;
reg [15:0]				sram_data;
assign sram_address_o 	= (!micro_control) ?  sram_address : micro_sram_address_i;
assign sram_datain_o  	= (!micro_control) ?  sram_data	  : micro_sram_datain_i;
assign sram_cs_o 		= (!micro_control) ?  sram_cs      : micro_sram_control[0];//micro_sram_cs_i;
assign sram_we_o 		= (!micro_control) ?  sram_we      : micro_sram_control[1];//micro_sram_we_i;
assign sram_oe_o		= (!micro_control) ?  sram_oe      : micro_sram_control[2];//micro_sram_oe_i;
assign sram_lb_ub_o		= (!micro_control) ?  sram_lb_ub   : micro_sram_control[4:3];//micro_sram_lb_ub_i;
assign sram_adv_o		= (!micro_control) ?  sram_adv     : micro_sram_control[5];// micro_sram_adv_i;


reg	[5:0]	write_init_counter;
reg 		address_count_en;

always@(negedge control_mem_clk_i or posedge control_mem_rst_i)begin
	if(control_mem_rst_i)begin
		write_init_counter <= 2'b00;
		sram_address	<= 32'd0;
	end
	else begin
		if(write_enable_i[1])begin
			write_init_counter <= write_init_counter + 6'd1;
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
	sram_cs = 1'b1; 
	sram_we = 1'b1;
	sram_oe = 1'b1;
	sram_adv= 1'b1;
	sram_wait_o = 1'b1;
	sram_lb_ub = 2'b11;
	sram_data = 16'h0000;
	if(write_enable_i[0])begin
		case(write_init_counter)//modificar
			6'd0: begin read_fifo_o=1'b1; address_count_en = 1'b1; sram_adv = 1'b1; sram_oe = 1'b1; sram_cs = 1'b1; sram_wait_o = 1'b1; sram_lb_ub = 2'b11; end
			6'd1: begin read_fifo_o=1'b0; address_count_en = 1'b0; end
			6'd2: begin sram_adv = 1'b0; sram_cs = 1'b0; sram_we = 1'b0; sram_data = fifo_datain_i[31:16]; end
			6'd3: begin sram_adv = 1'b1; sram_wait_o = 1'b0; sram_cs = 1'b0; sram_we = 1'b0; sram_data = fifo_datain_i[31:16]; end
			6'd4: begin sram_cs = 1'b0; sram_we = 1'b0; sram_data = fifo_datain_i[31:16]; end
			6'd5: begin sram_wait_o = 1'b1; sram_lb_ub = 2'b00; sram_cs = 1'b0; sram_we = 1'b0; sram_data = fifo_datain_i[31:16]; end
			6'd6: begin sram_cs = 1'b1; sram_we = 1'b1; sram_lb_ub = 2'b11; sram_data = fifo_datain_i[31:16]; end
			6'd7: begin address_count_en = 1'b1; sram_data = fifo_datain_i[15:0]; end
			6'd8: begin address_count_en = 1'b0; sram_data = fifo_datain_i[15:0]; end
			6'd9: begin sram_adv = 1'b0; sram_cs = 1'b0; sram_we = 1'b0; sram_data = fifo_datain_i[15:0]; end
			6'd10: begin sram_adv = 1'b1; sram_wait_o = 1'b0; sram_cs = 1'b0; sram_we = 1'b0; sram_data = fifo_datain_i[15:0]; end
			6'd11: begin sram_cs = 1'b0; sram_we = 1'b0; sram_data = fifo_datain_i[15:0]; end
			6'd12: begin sram_wait_o = 1'b1; sram_lb_ub = 2'b00; sram_cs = 1'b0; sram_we = 1'b0; sram_data = fifo_datain_i[15:0]; end
			6'd13: begin sram_cs = 1'b1; sram_we = 1'b1; sram_lb_ub = 2'b11; sram_data = fifo_datain_i[15:0]; end
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
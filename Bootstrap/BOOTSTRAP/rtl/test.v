`timescale 1ns / 1ps
module test(master_clk_i, master_rst_i, MISO, sram_address_o, sram_datain_o,sram_cs_o, sram_oe_o, sram_wait_o, sram_adv_o,
			MOSI,SS, SCK_SPI, error, sram_lb_ub_o, sram_we_o, bootstrap_initdone_o,sram_clk_o,reset,MISO1, MOSI1, SS1, SCK1);

input master_clk_i,master_rst_i;

input MISO;
output [21:0] sram_address_o;
output [15:0] sram_datain_o;
output  sram_cs_o, sram_oe_o, sram_we_o, sram_wait_o, sram_adv_o;
output [1:0] sram_lb_ub_o;
output MOSI;
output SS;
output SCK_SPI;
output error;
output bootstrap_initdone_o;
output sram_clk_o;
output reset;
output MISO1,MOSI1,SS1,SCK1;

assign MISO1 = MISO;
assign MOSI1 = MOSI;
assign SS1 = SS;
assign SCK1 = SCK_SPI;

assign reset = master_rst_i;

assign sram_clk_o = master_clk_i;
wire [43:0] micro_sram_controller_i;
assign micro_sram_controller_i = 44'h00000000000;

wire bootstrap_init_i;
wire [2:0] spi_flagreg_o;
wire [47:0] spi_data_i;
wire [8:0] spi_statusreg_i;
reg [7:0] state;

always@(posedge master_clk_i)begin
  if (master_rst_i) begin
	 state <= 8'h00;
  end
  else begin
	 case (state)
		8'h00 : begin
			state <= 8'h01;
		end
		8'h01 : begin
		   if (bootstrap_initdone_o)
			  state <= 8'h02;
		   else 
			  state <= 8'h01;
		end
		8'h02 : begin ///comando de escritura sd
		   if (spi_flagreg_o==3'b100)begin
			  state <= 8'h03; end
		   else begin
			  state <= 8'h02; end
		end
		8'h03 : begin ///comando de escritura sd
		   if (spi_flagreg_o==3'b101)begin
			  state <= 8'h04;end
		   else begin
			  state <= 8'h03;end
		end
		8'h04 : begin ///mantiene palabra en 0 hasta que termine escritura
		   if (spi_flagreg_o==3'b110)begin
			  state <= 8'h05; end
		   else begin
			  state <= 8'h04;end
		end

	 endcase
	end
end


assign bootstrap_init_i = (state == 8'h01) ? 1'b1 : 1'b0;
assign spi_data_i = (state == 8'h02) ? 48'h5800004200FF : (state == 8'h03) ? 48'hFE8623220000: 48'hFFFFFFFFFFFF;
assign spi_statusreg_i = (state == 8'h01) ? 9'b110100011:(state == 8'h02 || state == 8'h03 || state == 8'h04 ) ? 9'b110100111: 9'b000000000;


bootstrap A1 (
    .master_clk_i(master_clk_i), //
    .master_rst_i(master_rst_i), //
    .micro_sram_controller_i(micro_sram_controller_i), //
    .bootstrap_init_i(bootstrap_init_i), 
    .spi_data_i(spi_data_i), 
    .spi_statusreg_i(spi_statusreg_i), 
    .bootstrap_writeenable_i(1'b0), //
    .micro_controlmem_i(1'b0), //
    .spi_flagreg_o(spi_flagreg_o), //
    .bootstrap_initdone_o(bootstrap_initdone_o), //
    .sram_address_o(sram_address_o), //
    .sram_datain_o(sram_datain_o), //
    .sram_cs_o(sram_cs_o), //
    .sram_we_o(sram_we_o), //
    .sram_oe_o(sram_oe_o), //
    .sram_lb_ub_o(sram_lb_ub_o), //
    .sram_adv_o(sram_adv_o), //
    .sram_wait_o(sram_wait_o), //
    .error(error), //
    .MISO(MISO), //
    .MOSI(MOSI), //
    .SS(SS), //
    .SCK_SPI(SCK_SPI)//
    );

endmodule
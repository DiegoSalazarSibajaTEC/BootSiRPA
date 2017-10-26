`timescale 1ns / 1ps
/********************************************************************************
Bootstrap DCILAB 2017
Instituto Tecnológico de Costa Rica

Diego Salazar Sibaja

Modulo: FIFO

Descripción general: Este módulo es una FIFO circular, con una variante en sus 
punteros. Tiene un puntero que señala la dirección de lectura y otro en que señala
la dirección de la SRAM de escritura. Sepgun sea el caso, la FIFO tendrpa una señales
de vacía(empty) o llena (full) que indicarán el estado de la misma.
*********************************************************************************/
module bootstrap #(parameter MEM_DATA_WIDTH=16, SPI_DATA_WIDTH=48, MEM_ADDRESS_WIDTH=22, SPI_ADDRESS_WIDTH=32)
					(master_clk_i,master_rst_i, micro_sram_controller_i, bootstrap_init_i, spi_data_i, spi_statusreg_i, bootstrap_writeenable_i,
					micro_controlmem_i, spi_flagreg_o, bootstrap_initdone_o, sram_address_o, sram_datain_o, sram_cs_o, sram_we_o, sram_oe_o, 
					sram_lb_ub_o, sram_adv_o,sram_wait_o, error,MISO,MOSI,SS,SCK_SPI);

localparam sram_controller = MEM_ADDRESS_WIDTH+MEM_DATA_WIDTH+6;

//************************OUTPUTS and INPUTS********************************************
input 								master_clk_i;
input 								master_rst_i;
input 		[sram_controller-1:0] 	micro_sram_controller_i;
input								bootstrap_init_i; //controla variables
input								MISO;
input 		[SPI_DATA_WIDTH-1:0]	spi_data_i;
input 		[8:0]					spi_statusreg_i;
input								bootstrap_writeenable_i;
input								micro_controlmem_i;
output								MOSI;
output								SS;
output								SCK_SPI;
output 		[2:0]					spi_flagreg_o;
output								bootstrap_initdone_o;
output wire [MEM_ADDRESS_WIDTH-1:0]	sram_address_o;//----SRAM CONTROL
output wire	[MEM_DATA_WIDTH-1:0]	sram_datain_o;//-----SRAM CONTROL
output wire 						sram_cs_o;//---------SRAM CONTROL
output wire							sram_we_o;//---------SRAM CONTROL
output wire							sram_oe_o;
output wire	[1:0]					sram_lb_ub_o;
output wire							sram_adv_o;
output wire							sram_wait_o;
output reg							error;
//**************************************************************************************

//*************************Señales internas********************************************
wire driver_mem;
assign driver_mem = (bootstrap_init_i) ? 1'b0 : micro_controlmem_i;

wire [SPI_DATA_WIDTH-1:0] 	fifo_dataout;
wire [SPI_DATA_WIDTH-1:0] 	fifo_datain;
wire					  	fifo_readflag;
wire						fifo_fullflag;
wire						fifo_emptyflag;
reg						write_enable;


//***********************Controlador de FIFO********************************************
always@(posedge master_clk_i) begin
	//control lectura
	if(fifo_emptyflag && bootstrap_init_i || fifo_emptyflag && bootstrap_writeenable_i && spi_statusreg_i[8])begin
		write_enable <= 2'b11;
	end
	else begin
		if(fifo_emptyflag && spi_statusreg_i[8])begin
			write_enable <= 2'b10;
		end
		else begin
			write_enable <= 2'b00;
		end
	end
	//----CONTROL escritura
	if(fifo_fullflag) begin
		error <= 1'b1; //operation =
	end
	else begin
		error <= 1'b0;
	end
end

//*****************************Instanciación***********************************************
control_mem #(.ADDRESS_WIDTH(MEM_ADDRESS_WIDTH), .DATA_WIDTH(32), .FPGA_DATA_WIDTH(MEM_DATA_WIDTH)) CMEM (
    .control_mem_clk_i(master_clk_i), //
    .control_mem_rst_i(master_rst_i), //
    .micro_sram_address_i(micro_sram_controller_i[sram_controller-1:MEM_DATA_WIDTH+6]), //
    .micro_sram_datain_i(micro_sram_controller_i[MEM_DATA_WIDTH+6-1:6]), //
    .micro_sram_control(micro_sram_controller_i[5:0]), //
    .micro_control(driver_mem), //
    .write_enable_i(write_enable), //
    .fifo_datain_i(fifo_dataout),// 
    .read_fifo_o(fifo_readflag), //
    .sram_address_o(sram_address_o),// 
    .sram_datain_o(sram_datain_o), //
    .sram_cs_o(sram_cs_o), //
    .sram_we_o(sram_we_o), //
    .sram_oe_o(sram_oe_o), //
    .sram_lb_ub_o(sram_lb_ub_o), //
    .sram_adv_o(sram_adv_o), //
    .sram_wait_o(sram_wait_o)//
    );
	
fifo #(.ADDRESS_WIDTH(6),.DATA_WIDTH(32)) FIFO1 (
    .fifo_clk_i(master_clk_i), //
    .fifo_rst_i(master_rst_i), //
    .fifo_readflag_i(fifo_readflag), //
    .fifo_writeflag_i(spi_flagreg_o[0]), //
    .fifo_writedata_i(fifo_datain), //
    .fifo_emptyflag_o(fifo_emptyflag), //
    .fifo_fullflag_o(fifo_fullflag), //
    .fifo_readdata_o(fifo_dataout)//
    );
	
spi #(.DATA_WIDTH(8))SPI_MODULE (
    .spi_clk_i(master_clk_i), // 
    .spi_rst_i(master_rst_i), //
    .spi_statusreg_i(spi_statusreg_i), //mod
    .spi_data_i(spi_data_i), //
    .spi_init_i(bootstrap_init_i), //
    .MISO(MISO), //
    .MOSI(MOSI), //
    .SCK_SPI(SCK_SPI), //
    .SS(SS), //
    .spi_initdone_o(bootstrap_initdone_o),// 
    .spi_flagreg_o(spi_flagreg_o), //
    .spi_data_o(fifo_datain)//
    );


endmodule
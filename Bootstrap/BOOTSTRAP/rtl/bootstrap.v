`timescale 1ns / 1ps
/********************************************************************************
Bootstrap DCILAB 2017
Instituto TecnolÃ³gico de Costa Rica

Diego Salazar Sibaja

Modulo: FIFO

DescripciÃ³n general: Este mÃ³dulo es una FIFO circular, con una variante en sus 
punteros. Tiene un puntero que seÃ±ala la direcciÃ³n de lectura y otro en que seÃ±ala
la direcciÃ³n de la SRAM de escritura. Sepgun sea el caso, la FIFO tendrpa una seÃ±ales
de vacÃ­a(empty) o llena (full) que indicarÃ¡n el estado de la misma.
*********************************************************************************/
module bootstrap #(parameter MEM_DATA_WIDTH=32, SPI_DATA_WIDTH=48, MEM_ADDRESS_WIDTH=13, SPI_ADDRESS_WIDTH=32)
					(master_clk_i,master_rst_i, micro_sram_controller_i, micro_sram_cs_i, micro_sram_we_i, bootstrap_init_i, spi_data_i, spi_statusreg_i, 
					bootstrap_writeenable_i, micro_controlmem_i, spi_flagreg_o, bootstrap_initdone_o, sram_address_o, sram_datain_o, sram_cs_o, 
					sram_we_o, error, MISO, MOSI, SS,SCK_SPI, R1);

localparam sram_controller = MEM_ADDRESS_WIDTH+MEM_DATA_WIDTH;

//************************OUTPUTS and INPUTS********************************************
input 								master_clk_i;
input 								master_rst_i;
input 		[sram_controller-1:0] 	micro_sram_controller_i;
input								micro_sram_cs_i;
input								micro_sram_we_i;
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
output reg							error;
output wire [7:0]                   R1;
//**************************************************************************************

//*************************SeÃ±ales internas********************************************
wire driver_mem;
assign driver_mem = (bootstrap_init_i) ? 1'b0 : micro_controlmem_i;

wire [31:0] 	fifo_dataout;
wire [SPI_DATA_WIDTH-1:0] 	fifo_datain;
wire					  	fifo_readflag;
wire						fifo_fullflag;
wire						fifo_emptyflag;
reg	 [1:0]					write_enable;
wire						spi_initwritemem;

//***********************Controlador de FIFO********************************************
always@(posedge master_clk_i) begin
	//control lectura
	if(!fifo_emptyflag && bootstrap_init_i && spi_initwritemem || !fifo_emptyflag && bootstrap_writeenable_i && spi_statusreg_i[8])begin
		write_enable <= 2'b11;
	end
	else begin
		if(!fifo_emptyflag && spi_statusreg_i[8])begin
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

//*****************************InstanciaciÃ³n***********************************************
control_sram #(.ADDRESS_WIDTH(13), .DATA_WIDTH(32)) CMEM (
    .control_mem_clk_i(master_clk_i), 
    .control_mem_rst_i(master_rst_i), 
    .micro_sram_address_i(micro_sram_controller_i[sram_controller-1:MEM_DATA_WIDTH]), //
    .micro_sram_datain_i(micro_sram_controller_i[MEM_DATA_WIDTH-1:0]), //
    .micro_sram_cs_i(micro_sram_cs_i), //
    .micro_sram_we_i(micro_sram_we_i), //
    .micro_control(driver_mem), //
    .write_enable_i(write_enable), //
    .fifo_datain_i(fifo_dataout), //
    .read_fifo_o(fifo_readflag), 
    .sram_address_o(sram_address_o), //
    .sram_datain_o(sram_datain_o), //
    .sram_cs_o(sram_cs_o), //
    .sram_we_o(sram_we_o)//
    );
	
fifo #(.ADDRESS_WIDTH(6),.DATA_WIDTH(32)) FIFO1 (
    .fifo_clk_i(master_clk_i), //
    .fifo_rst_i(master_rst_i), //
    .fifo_readflag_i(fifo_readflag), //
    .fifo_writeflag_i(~spi_flagreg_o[2] && spi_flagreg_o[0]), //
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
    .spi_data_o(fifo_datain),//
	.spi_initwritemem_o(spi_initwritemem),
	.R1(R1)
    );


endmodule
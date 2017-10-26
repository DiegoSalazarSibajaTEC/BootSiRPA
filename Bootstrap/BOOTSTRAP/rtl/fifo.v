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

/********************************************************************************
Los parametros ADDRESS_WIDTH y DATA_WIDTH determinan caracteristicas de la memoria
de la FIFO. Con 6 se obtiene 256 espacios de memoria con datos de ancho de 32 bits.
Esto da una memoria de 256 bytes.
*********************************************************************************/
module fifo#(parameter ADDRESS_WIDTH =6, DATA_WIDTH=32)(fifo_clk_i, fifo_rst_i, fifo_readflag_i, fifo_writeflag_i, fifo_writedata_i, fifo_emptyflag_o, 
														fifo_fullflag_o, fifo_readdata_o);
	
//************************OUTPUTS and INPUTS********************************************
input 	wire 					fifo_clk_i, fifo_rst_i;//************Reloj y reset master 1:Reset/0:No reset
input 	wire 					fifo_readflag_i, fifo_writeflag_i;//*Banderas que activan lectura o escritura
input 	wire [DATA_WIDTH-1:0] 	fifo_writedata_i;//******************Dato a escribir
output 	wire 					fifo_emptyflag_o, fifo_fullflag_o;//*Banderas de memoria llena y vacia
output 	wire [DATA_WIDTH-1:0] 	fifo_readdata_o;//*******************Dato de lectura
//**************************************************************************************

//*************************Señales internas********************************************
reg [ADDRESS_WIDTH-1:0] write_address_reg, write_address_next, write_address_after; //**Direcciones de escritura
reg [ADDRESS_WIDTH-1:0] read_address_reg, read_address_next, read_address_after;//******Direcciones de lectura
reg 					full_reg, empty_reg, full_next, empty_next;//*******************Auxiliares de bandera vacio y lleno
wire 					write_en;//*****************************************************Habilitación de escritura

//******La escritura se habilita si la FIFO no esta llena*******************************
assign write_en = fifo_writeflag_i & ~full_reg;

//****Asigna los valores de bandera de FIFO vacia y FIFO llena**************************
assign fifo_fullflag_o  = full_reg;
assign fifo_emptyflag_o = empty_reg;


// ****Instaciación de la RAM***********************************************************
ram_dual #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ram
		(.dualram_clk_i(fifo_clk_i), .dualram_writeen_i(write_en), .dualram_read_addr_i(read_address_reg),
		 .dualram_write_addr_i(write_address_reg), .dualram_writedata_i(fifo_writedata_i),.dualram_readdata_o(fifo_readdata_o));

//****Actualizaciín de registros y punteros*********************************************
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
//*****next-state logic for address index values after read/write operations
always @*
	begin
	write_address_after = write_address_reg + 1'd1;
	read_address_after  = read_address_reg + 1'd1;
	end
	
//*************next-state logic for address pointers
always @*
	begin
	//*********defaults
	write_address_next = write_address_reg;
	read_address_next  = read_address_reg;
	full_next          = full_reg;
	empty_next         = empty_reg;
	
	//*********if read input asserted and FIFO isn't empty
	if(fifo_readflag_i && ~empty_reg && ~fifo_writeflag_i)begin
		read_address_next = read_address_after;       // read address moves forward
		full_next = 1'b0;                             // FIFO isn't full if a read occured
		if (read_address_after == write_address_reg)  // if read address caught up with write address,
			empty_next = 1'b1;                        // FIFO is empty
		end
	
	//*********if write input asserted and FIFO isn't full
	else if(fifo_writeflag_i && ~full_reg && ~fifo_readflag_i)	begin
			write_address_next = write_address_after;     // write address moves forward
			empty_next = 1'b0;                            // FIFO isn't empty if write occured
			if (write_address_after == read_address_reg)    // if write address caught up with read address
				full_next = 1'b1;                         // FIFO is full
			end
	//*********if write and read are asserted
			else if(fifo_writeflag_i && fifo_readflag_i)begin
				write_address_next = write_address_after;     // write address moves forward
				read_address_next  = read_address_after;      // read address moves forward
			end
	end 

endmodule
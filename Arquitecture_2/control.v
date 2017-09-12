`timescale 1ns / 1ps

module control_comunication();
parameter ram_add_width = 32;
parameter ram_word_widht= 32;
input	[ram_add_width-1:0]		sirpa_add_i;
input	[ram_word_widht-1:0]	sirpa_datainp_i;
input	 						sirpa_cen_;
input							sirpa_wen_i;


output reg [ram_word_widht-1:0]	control_dataout_o;
output wire[ram_add_width-1:0]	control_add_o;
output wire[ram_word_widht-1:0]	control_datainp_o;
output wire		control_cen_o;
output wire		control_wen_o;


reg		address_ram; //senales de boot
reg		datawrite_ram;
reg		cen_ram;
reg		wen_ram;

reg		bootstrap_operation;




assign control_add_o = (bootstrap_operation) ? address_ram : sirpa_add_i;

endmodule
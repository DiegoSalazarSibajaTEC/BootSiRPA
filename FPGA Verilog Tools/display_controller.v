`timescale 1ns / 1ps

module displayController(dC_data_i, dC_data_o, dC_clk_i, dC_rst_i);

input	[32:0] 	dC_data_i;
input 			dC_clk_i;
input 			dC_rst_i;
output	[6:0] 	dC_data_o;
output 	[7:0]	dC_display_o;

reg [3:0] counter;
reg 	  done;
reg [3:0] data_number;




always(posedge dC_clk_i or posedge dC_rst_i) begin
	if(dC_rst_i) begin
		counter = 4'h0;
	end
	else begin
		counter = counter + 4'h1;
	end
end

always @(counter)begin
	case(counter)
		4'h0 : begin dC_display_o = 8'b00000001; data_number = dC_data_i [3:0]; end
		4'h1 : begin dC_display_o = 8'b00000010; data_number = dC_data_i [7:4]; end
		4'h2 : begin dC_display_o = 8'b00000100; data_number = dC_data_i [11:8]; end
		4'h3 : begin dC_display_o = 8'b00001000; data_number = dC_data_i [15:12];end
		4'h4 : begin dC_display_o = 8'b00010000; data_number = dC_data_i [19:16]; end
		4'h5 : begin dC_display_o = 8'b00100000; data_number = dC_data_i [23:20]; end
		4'h6 : begin dC_display_o = 8'b01000000; data_number = dC_data_i [27:24]; end
		4'h7 : begin dC_display_o = 8'b10000000; data_number = dC_data_i [32:28];  end
	endcase
end


always @(data_number)begin
	case(data_number)
		4'h0 : begin dC_data_o = 7'b0000001; end
		4'h1 : begin dC_data_o = 7'b1001111; end
		4'h2 : begin dC_data_o = 7'b0010010; end
		4'h3 : begin dC_data_o = 7'b0000110; end
		4'h4 : begin dC_data_o = 7'b1001100; end
		4'h5 : begin dC_data_o = 7'b0100100; end
		4'h6 : begin dC_data_o = 7'b0100000; end
		4'h7 : begin dC_data_o = 7'b0001111; end
		4'h8 : begin dC_data_o = 7'b0000000; end
		4'h9 : begin dC_data_o = 7'b0000100; end
		4'hA : begin dC_data_o = 7'b0001000; end
		4'hB : begin dC_data_o = 7'b1000000; end
		4'hC : begin dC_data_o = 7'b0110001; end
		4'hD : begin dC_data_o = 7'b0011100; end
		4'hE : begin dC_data_o = 7'b0110000; end
		4'hF : begin dC_data_o = 7'b0111000; end
	endcase
end





endmodule
`timescale 1ns / 1ps

module selector(
			input 	clk,
//			input 	rx_data,
//			input 	uart_enw	,
//			input 	new_frm,
				/////
			input [9:0]	current_pos_x,
			input [9:0]	current_pos_y,
				/////
			input [9:0]	top_pos_x_1,
			input [9:0]	top_pos_y_1,
			input [9:0]	bottom_pos_x_1,
			input [9:0]	bottom_pos_y_1,
			input [9:0]	left_pos_x_1,
			input [9:0]	left_pos_y_1,
			input [9:0]	right_pos_x_1,
			input [9:0]	right_pos_y_1,
			input [11:0]	centre_pos_x_1,
			input [11:0]	centre_pos_y_1,
			input [9:0]	angle_x_1,
			input [9:0]	angle_y_1,
			input chieu_xoay_1,
			
			//////////////////
			input [9:0]	top_pos_x_2,
			input [9:0]	top_pos_y_2,
			input [9:0]	bottom_pos_x_2,
			input [9:0]	bottom_pos_y_2,
			input [9:0]	left_pos_x_2,
			input [9:0]	left_pos_y_2,
			input [9:0]	right_pos_x_2,
			input [9:0]	right_pos_y_2,
			input [11:0]	centre_pos_x_2,
			input [11:0]	centre_pos_y_2,
			input [9:0]	angle_x_2,
			input [9:0]	angle_y_2,
			input chieu_xoay_2,
			
			//////////////////
			
			output [11:0]	centre_pos_x_rs232,
			output [11:0]	centre_pos_y_rs232,
			output [9:0]	angle_x_rs232,
			output [9:0]	angle_y_rs232,
			output chieu_xoay_rs232,
			///////////////////
			output [9:0]	top_pos_x_vga,
			output [9:0]	top_pos_y_vga,
			output [9:0]	bottom_pos_x_vga,
			output [9:0]	bottom_pos_y_vga,
			output [9:0]	left_pos_x_vga,
			output [9:0]	left_pos_y_vga,
			output [9:0]	right_pos_x_vga,
			output [9:0]	right_pos_y_vga
			);	
	
////////////////////////////////////////////////
reg [11:0]	centre_pos_x_rs232_r;
reg [11:0]	centre_pos_y_rs232_r;
reg [9:0]	angle_x_rs232_r;
reg [9:0]	angle_y_rs232_r;
reg chieu_xoay_rs232_r;

reg [9:0]	top_pos_x_vga_r;
reg [9:0]	top_pos_y_vga_r;
reg [9:0]	bottom_pos_x_vga_r;
reg [9:0]	bottom_pos_y_vga_r;
reg [9:0]	left_pos_x_vga_r;
reg [9:0]	left_pos_y_vga_r;
reg [9:0]	right_pos_x_vga_r;
reg [9:0]	right_pos_y_vga_r;

assign	centre_pos_x_rs232 = centre_pos_x_rs232_r;
assign	centre_pos_y_rs232 = centre_pos_y_rs232_r;
assign	angle_x_rs232 = angle_x_rs232_r;
assign	angle_y_rs232 = angle_y_rs232_r;
assign   chieu_xoay_rs232 = chieu_xoay_rs232_r;


assign	top_pos_x_vga = top_pos_x_vga_r;
assign	top_pos_y_vga = top_pos_y_vga_r;
assign	bottom_pos_x_vga = bottom_pos_x_vga_r;
assign	bottom_pos_y_vga = bottom_pos_y_vga_r;
assign	left_pos_x_vga = left_pos_x_vga_r;
assign	left_pos_y_vga = left_pos_y_vga_r;
assign	right_pos_x_vga = right_pos_x_vga_r;
assign	right_pos_y_vga = right_pos_y_vga_r;

always@(posedge clk)
begin
	if (current_pos_y == 480)
		begin
			if (chieu_xoay_2 > chieu_xoay_1)
				begin
					centre_pos_x_rs232_r <= centre_pos_x_1;
					centre_pos_y_rs232_r <= centre_pos_y_1;
					angle_x_rs232_r <= angle_x_1;
					angle_y_rs232_r <= angle_y_1;
					chieu_xoay_rs232_r <= chieu_xoay_1;
					
					
					top_pos_x_vga_r <= top_pos_x_1;
					top_pos_y_vga_r <= top_pos_y_1;
					bottom_pos_x_vga_r <= bottom_pos_x_1;
					bottom_pos_y_vga_r <= bottom_pos_y_1;
					left_pos_x_vga_r <= left_pos_x_1;
					left_pos_y_vga_r <= left_pos_y_1;
					right_pos_x_vga_r <= right_pos_x_1;
					right_pos_y_vga_r <= right_pos_y_1;
				end
			else
				begin
					centre_pos_x_rs232_r <= centre_pos_x_2;
					centre_pos_y_rs232_r <= centre_pos_y_2;
					angle_x_rs232_r <= angle_x_2;
					angle_y_rs232_r <= angle_y_2;
					chieu_xoay_rs232_r <= chieu_xoay_2;
					
					
					top_pos_x_vga_r <= top_pos_x_2;
					top_pos_y_vga_r <= top_pos_y_2;
					bottom_pos_x_vga_r <= bottom_pos_x_2;
					bottom_pos_y_vga_r <= bottom_pos_y_2;
					left_pos_x_vga_r <= left_pos_x_2;
					left_pos_y_vga_r <= left_pos_y_2;
					right_pos_x_vga_r <= right_pos_x_2;
					right_pos_y_vga_r <= right_pos_y_2;
				end						
		end
	else
		begin
			centre_pos_x_rs232_r <= centre_pos_x_rs232_r;
			centre_pos_y_rs232_r <= centre_pos_y_rs232_r;
			angle_x_rs232_r <= angle_x_rs232_r;
			angle_y_rs232_r <= angle_y_rs232_r;
			chieu_xoay_rs232_r <= chieu_xoay_rs232_r;
			
			top_pos_x_vga_r <= top_pos_x_vga_r;
			top_pos_y_vga_r <= top_pos_y_vga_r;
			bottom_pos_x_vga_r <= bottom_pos_x_vga_r;
			bottom_pos_y_vga_r <= bottom_pos_y_vga_r;
			left_pos_x_vga_r <= left_pos_x_vga_r;
			left_pos_y_vga_r <= left_pos_y_vga_r;
			right_pos_x_vga_r <= right_pos_x_vga_r;
			right_pos_y_vga_r <= right_pos_y_vga_r;
		end
end	
	
	
endmodule
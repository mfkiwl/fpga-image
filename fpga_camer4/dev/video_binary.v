`timescale 1ns / 1ps

module video_binary(
			input 			clk,
			input 			clk_enable,
			input 			frame_enable,
			input   [15:0] pixel_color,
			input 			binary_enable1,
			input 			binary_enable2,
			
			//output	clk_out,
			output	clk_out_enable,
			output	frame_out_enable,
			output	[15:0] pixel_out_color,
				/////
			output [9:0]	current_pos_x,
			output [9:0]	current_pos_y,
			output	tx_int
			);


//////////////////xac dinh trong tam va goc do//////////////////////////////////
reg [9:0] vitrihientai_x;
reg [9:0] vitrihientai_y;

assign current_pos_x = vitrihientai_x;
assign current_pos_y = vitrihientai_y;

//////////////////////////////////////////////////////////////////////////
//reg	clk_out_r;
reg	clk_out_enable_r;
reg	frame_out_enable_r;
reg	[15:0] pixel_out_color_r;
wire   pixel_median_in;
wire [2:0]  pixel_median_out;

reg tx_int_r = 0;

//assign clk_out = clk_out_r;
assign clk_out_enable = clk_out_enable_r;
assign frame_out_enable = frame_out_enable_r;
assign pixel_out_color = pixel_out_color_r;
	
assign tx_int = tx_int_r;

always @ (posedge clk)
begin
	if(frame_enable == 1'b0)
		begin
			vitrihientai_x <= 10'h000;
			vitrihientai_y <= 10'h000;
		end
	else
		begin
			if (clk_enable == 1'b1)	
				begin
					if((vitrihientai_x < 639) && (vitrihientai_y < 480))
						begin
							vitrihientai_x <= vitrihientai_x + 1'b1;
							vitrihientai_y <= vitrihientai_y;
						end
					else if((vitrihientai_x == 639) && (vitrihientai_y < 480))
						begin
							vitrihientai_x <= 10'h000;
							vitrihientai_y <= vitrihientai_y + 1'b1;
						end
					else
						begin
							vitrihientai_x <= vitrihientai_x;
							vitrihientai_y <= vitrihientai_y;
						end
				end
		end
end

always @ (posedge clk)
begin
	if(vitrihientai_y == 0)
		begin
			tx_int_r <= 1;
		end
	else if(vitrihientai_y == 480)
		begin
			tx_int_r <= 0;
		end
	else
		begin
			tx_int_r <= tx_int_r;
		end
end


assign pixel_median_in = ((pixel_color[15:11] > 5'b01110) || (pixel_color[10:5] > 6'b011100) || (pixel_color[4:0] > 5'b01110)) ? 1'b1 : 1'b0;
Line_Buffer Line_Buffer1	(	
					.clken(clk_enable),
					.clock(clk),
					.shiftin(pixel_median_in),
					.taps(pixel_median_out));

reg [8:0] matrix_median; 
reg [3:0] sum_matrix_median;
always @ (posedge clk)
begin
	if(frame_enable == 1'b0)
		begin
			matrix_median <= 9'h1ff;
			sum_matrix_median <= 4'd5;
		end
	else
		begin
			if (clk_enable == 1'b1)	
				begin
					if ((binary_enable1 == 1'b0)&&(binary_enable2 == 1'b0))
						begin 
							matrix_median[2:0] <= pixel_median_out;
							matrix_median[5:3] <= matrix_median[2:0];
							matrix_median[8:6] <= matrix_median[5:3];
							sum_matrix_median <= matrix_median[0]+matrix_median[1]+matrix_median[2]+
														matrix_median[3]+matrix_median[4]+matrix_median[5]+
														matrix_median[6]+matrix_median[7]+matrix_median[8];
							if (sum_matrix_median > 4'd4)
								begin
									pixel_out_color_r <= 16'hffff;
								end
							else
								begin
									pixel_out_color_r <= 16'h0000;
								end
						end
					else if ((binary_enable1 == 1'b0)&&(binary_enable2 == 1'b1))
						begin 
							pixel_out_color_r <= {pixel_median_in,pixel_median_in,pixel_median_in,pixel_median_in,
														pixel_median_in,pixel_median_in,pixel_median_in,pixel_median_in,
														pixel_median_in,pixel_median_in,pixel_median_in,pixel_median_in,
														pixel_median_in,pixel_median_in,pixel_median_in,pixel_median_in};
						end
					else
						begin
							pixel_out_color_r <= pixel_color;
						end
				end
		end
end					

reg clk_out_enable_r_1;
reg clk_out_enable_r_2;
reg clk_out_enable_r_3;
reg clk_out_enable_r_4;
reg frame_out_enable_r_1;
reg frame_out_enable_r_2;
reg frame_out_enable_r_3;
reg frame_out_enable_r_4;

always @ (posedge clk)
begin
//	if (binary_enable == 1'b0)
//		begin
//			clk_out_enable_r_1 <= clk_enable;
//			frame_out_enable_r_1 <= frame_enable;
//	
//			clk_out_enable_r_2 <= clk_out_enable_r_1;
//			frame_out_enable_r_2 <= frame_out_enable_r_1;	
//			
//			clk_out_enable_r_3 <= clk_out_enable_r_2;
//			frame_out_enable_r_3 <= frame_out_enable_r_2;	
//			
//			clk_out_enable_r_4 <= clk_out_enable_r_3;
//			frame_out_enable_r_4 <= frame_out_enable_r_3;	
//			
//			clk_out_enable_r <= clk_out_enable_r_4;
//			frame_out_enable_r <= frame_out_enable_r_4;
//		end
//	else
//		begin
			clk_out_enable_r <= clk_enable;
			frame_out_enable_r <= frame_enable;
//		end
end
endmodule
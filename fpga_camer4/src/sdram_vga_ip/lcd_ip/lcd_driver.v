/*-------------------------------------------------------------------------
This confidential and proprietary software may be only used as authorized
by a licensing agreement from amfpga.
(C) COPYRIGHT 2013.www.amfpga.com ALL RIGHTS RESERVED
Filename			:		sdram_ov7670_vga.v
Author				:		Amfpga
Data				:		2013-02-1
Version				:		1.0
Description			:		sdram vga controller with ov7670 display.
Modification History	:
Data			By			Version			Change Description
===========================================================================
13/02/1
--------------------------------------------------------------------------*/
module lcd_driver
(  	
	//global clock
	input			clk,			//system clock
	input			rst_n,     		//sync reset
	
	//lcd interface
	output			lcd_dclk,   	//lcd pixel clock
	output			lcd_blank,		//lcd blank
	output			lcd_sync,		//lcd sync
	output			lcd_hs,	    	//lcd horizontal sync
	output			lcd_vs,	    	//lcd vertical sync
	output			lcd_en,			//lcd display enable
	output	[15:0]	lcd_rgb,		//lcd display data

	//user interface
	output			lcd_request,	//lcd data request
	output			lcd_framesync,	//lcd frame sync
	output	[9:0]	lcd_xpos,		//lcd horizontal coordinate
	output	[9:0]	lcd_ypos,		//lcd vertical coordinate
	input	[15:0]	lcd_data	,	//lcd data
	
	//vi tri goc
	input [9:0] top_pos_x,
	input [9:0] top_pos_y,
	input [9:0] bottom_pos_x,
	input [9:0] bottom_pos_y,
	input [9:0] left_pos_x,
	input [9:0] left_pos_y,
	input [9:0] right_pos_x,
	input [9:0] right_pos_y,
	input [11:0] centre_pos_x,
	input [11:0] centre_pos_y,
	
	input button_1
);	 
`include "lcd_para.v"  

/*******************************************
		SYNC--BACK--DISP--FRONT
*******************************************/
//------------------------------------------
//h_sync counter & generator
reg [9:0] hcnt; 
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
		hcnt <= 10'd0;
	else
		begin
        if(hcnt < `H_TOTAL - 1'b1)		//line over			
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= 10'd0;
		end
end 
//assign	lcd_hs = (hcnt <= `H_SYNC - 1'b1) ? 1'b0 : 1'b1;

reg lcd_hs_r;
always @ (posedge clk)
begin
	if (hcnt <= `H_SYNC - 1'b1)
		lcd_hs_r <= 1'b0;
	else
		lcd_hs_r <= 1'b1;
end
assign	lcd_hs = lcd_hs_r;

//------------------------------------------
//v_sync counter & generator
reg [9:0] vcnt;
always@(posedge clk or negedge rst_n)
begin
	if (!rst_n)
		vcnt <= 10'b0;
	else if(hcnt == `H_TOTAL - 1'b1)		//line over
		begin
		if(vcnt < `V_TOTAL - 1'b1)		//frame over
			vcnt <= vcnt + 1'b1;
		else
			vcnt <= 10'd0;
		end
end
//assign	lcd_vs = (vcnt <= `V_SYNC - 1'b1) ? 1'b0 : 1'b1;

reg lcd_vs_r;
always@(posedge clk)
begin
	if (vcnt <= `V_SYNC - 1'b1)
		lcd_vs_r <= 1'b0;
	else
		lcd_vs_r <= 1'b1;
end
assign	lcd_vs = lcd_vs_r;
//------------------------------------------
//LCELL	LCELL(.in(clk),.out(lcd_dclk));
assign	lcd_dclk = ~clk;
assign	lcd_blank = lcd_hs & lcd_vs;		
assign	lcd_sync = 1'b0;
assign	lcd_en		=	(hcnt >= `H_SYNC + `H_BACK  && hcnt < `H_SYNC + `H_BACK + `H_DISP) &&
						(vcnt >= `V_SYNC + `V_BACK  && vcnt < `V_SYNC + `V_BACK + `V_DISP) 
						? 1'b1 : 1'b0;
//assign	lcd_rgb 	= 	lcd_en ? lcd_data : 16'd0;
assign	lcd_framesync = lcd_vs;

//////////////them moi////////////////////////
//wire top_wire;
//wire bottom_wire;
//wire left_wire;
//wire right_wire;
//wire centre_wire;

//assign top_wire = (((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - top_pos_x < 3)||(top_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 3))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - top_pos_y < 3)||(top_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 3));
//assign bottom_wire = (((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - bottom_pos_x < 3)||(bottom_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 3))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - bottom_pos_y < 3)||(bottom_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 3));
//assign left_wire = (((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - left_pos_x < 3)||(left_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 3))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - left_pos_y < 3)||(left_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 3));
//assign right_wire = (((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - right_pos_x < 3)||(right_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 3))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - right_pos_y < 3)||(right_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 3));
//assign centre_wire = (((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - centre_pos_x[11:2] < 3)||(centre_pos_x[11:2] - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 3))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - centre_pos_y[11:2] < 3)||(centre_pos_y[11:2] - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 3));

//assign top_wire = ((lcd_xpos - top_pos_x < 3)||(top_pos_x - lcd_xpos < 3))&&((lcd_ypos - top_pos_y < 3)||(top_pos_y - lcd_ypos < 3));
//assign bottom_wire = ((lcd_xpos - bottom_pos_x < 3)||(bottom_pos_x - lcd_xpos < 3))&&((lcd_ypos - bottom_pos_y < 3)||(bottom_pos_y - lcd_ypos < 3));
//assign left_wire = ((lcd_xpos - left_pos_x < 3)||(left_pos_x - lcd_xpos < 3))&&((lcd_ypos - left_pos_y < 3)||(left_pos_y - lcd_ypos < 3));
//assign right_wire = ((lcd_xpos - right_pos_x < 3)||(right_pos_x - lcd_xpos < 3))&&((lcd_ypos - right_pos_y < 3)||(right_pos_y - lcd_ypos < 3));
//assign centre_wire = ((lcd_xpos - centre_pos_x[11:2] < 3)||(centre_pos_x[11:2] - lcd_xpos < 3))&&((lcd_ypos - centre_pos_y[11:2] < 3)||(centre_pos_y[11:2] - lcd_ypos < 3));
//
//assign	lcd_rgb 	= 	button_1 ? (lcd_en ? lcd_data : 16'd0) : (lcd_en ? (top_wire ? 16'h8000 : (bottom_wire ? 16'h8400 : (left_wire ? 16'h0400 : (right_wire ? 16'h0010 : (centre_wire ? 16'h0410 : (lcd_data)))))) : 16'd0);
//////////////////////////////////////////////////////////////////////////////////
//reg [15:0] lcd_rgb_r;
//always@(posedge clk)
//begin
//	if(button_1 == 1)
//		begin
//			if (lcd_en == 1)
//				begin
//					lcd_rgb_r <= lcd_data;
//				end
//			else
//				begin
//					lcd_rgb_r <= 16'd0;
//				end
//		end
//	else
//		begin
//			if (lcd_en == 1)
//				begin
//					if /*((hcnt - (`H_SYNC + `H_BACK - 1'b1)) == top_pos_x)*/ ((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - top_pos_x < 10'h003)||(top_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - top_pos_y < 10'h003)||(top_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003)))
//						begin
//							lcd_rgb_r <= 16'h8000;
//						end
//						
//						////////////////////
////					else if ((vcnt - (`V_SYNC + `V_BACK - 1'b1)) == top_pos_y) //((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - bottom_pos_x < 10'h003)||(bottom_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - bottom_pos_y < 10'h003)||(bottom_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003)))
////						begin
////							lcd_rgb_r <= 16'h0400;
////						end						
//						///////////////////////
//						
//						
//					if /*((hcnt - (`H_SYNC + `H_BACK - 1'b1)) == bottom_pos_x)*/  ((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - bottom_pos_x < 10'h003)||(bottom_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - bottom_pos_y < 10'h003)||(bottom_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003)))
//						begin
//							lcd_rgb_r <= 16'h8400;
//						end
////					else if /*((hcnt - (`H_SYNC + `H_BACK - 1'b1)) == left_pos_x)*/ ((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - left_pos_x < 10'h003)||(left_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - left_pos_y < 10'h003)||(left_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003)))
////						begin
////							lcd_rgb_r <= 16'h0400;
////						end
////					else if /*((hcnt - (`H_SYNC + `H_BACK - 1'b1)) == right_pos_x)*/ ((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - right_pos_x < 10'h003)||(right_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - right_pos_y < 10'h003)||(right_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003)))
////						begin
////							lcd_rgb_r <= 16'h0010;
////						end
////					else if /*((hcnt - (`H_SYNC + `H_BACK - 1'b1)) == centre_pos_x[11:2])*/ ((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - centre_pos_x[11:2] < 10'h003)||(centre_pos_x[11:2] - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - centre_pos_y[11:2] < 10'h003)||(centre_pos_y[11:2] - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003)))
////						begin
////							lcd_rgb_r <= 16'h0410;
////						end
//					if 
//						begin
//							lcd_rgb_r <= lcd_data;
//						end
//				end
//			else
//				begin
//					lcd_rgb_r <= 16'd0;
//				end
//		end
//end
//assign	lcd_rgb 	= 	lcd_rgb_r;
/////////////////////////////////////////////////////////////////////
reg [15:0] lcd_rgb_r;
wire top_enable = ((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - top_pos_x < 10'h003)||(top_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - top_pos_y < 10'h003)||(top_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003))) ? 1'b1 : 1'b0;
wire bottom_enable = ((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - bottom_pos_x < 10'h003)||(bottom_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - bottom_pos_y < 10'h003)||(bottom_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003))) ? 1'b1 :1'b0;
wire left_enable = ((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - left_pos_x < 10'h003)||(left_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - left_pos_y < 10'h003)||(left_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003))) ? 1'b1 :1'b0;
wire right_enable = ((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - right_pos_x < 10'h003)||(right_pos_x - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - right_pos_y < 10'h003)||(right_pos_y - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003))) ? 1'b1 :1'b0;
wire centre_enable = ((((hcnt - (`H_SYNC + `H_BACK - 1'b1)) - centre_pos_x[11:2] < 10'h003)||(centre_pos_x[11:2] - (hcnt - (`H_SYNC + `H_BACK - 1'b1)) < 10'h003))&&(((vcnt - (`V_SYNC + `V_BACK - 1'b1)) - centre_pos_y[11:2] < 10'h003)||(centre_pos_y[11:2] - (vcnt - (`V_SYNC + `V_BACK - 1'b1)) < 10'h003))) ? 1'b1 :1'b0;
always@(posedge clk)
begin
	if(button_1 == 1)
		begin
			if (lcd_en == 1)
				begin
					lcd_rgb_r <= lcd_data;
				end
			else
				begin
					lcd_rgb_r <= 16'd0;
				end
		end
	else
		begin
			if (lcd_en == 1)
				begin
					if (top_enable == 1'b1)
						begin
							lcd_rgb_r <= 16'h8000;
						end
												
					if (bottom_enable == 1'b1)
						begin
							lcd_rgb_r <= 16'h8010;
						end
					if (left_enable == 1'b1)
						begin
							lcd_rgb_r <= 16'h0400;
						end
					if (right_enable == 1'b1)
						begin
							lcd_rgb_r <= 16'h0010;
						end
					if (centre_enable == 1'b1)
						begin
							lcd_rgb_r <= 16'h0410;
						end
					if ((top_enable == 1'b0)&&(bottom_enable == 1'b0)&&(left_enable == 1'b0)&&(right_enable == 1'b0)&&(centre_enable == 1'b0))
						begin
							lcd_rgb_r <= lcd_data;
						end
				end
			else
				begin
					lcd_rgb_r <= 16'd0;
				end
		end
end
assign	lcd_rgb 	= 	lcd_rgb_r;

/////////////////////////////////////////////////////////////////////////

//------------------------------------------
//ahead a clock
assign	lcd_request	=	(hcnt >= `H_SYNC + `H_BACK - 1'd1 && hcnt < `H_SYNC + `H_BACK + `H_DISP - 1'd1) &&
						(vcnt >= `V_SYNC + `V_BACK && vcnt < `V_SYNC + `V_BACK + `V_DISP) 
						? 1'b1 : 1'b0;
assign	lcd_xpos	= 	lcd_request ? (hcnt - (`H_SYNC + `H_BACK - 1'b1)) : 10'd0;
assign	lcd_ypos	= 	lcd_request ? (vcnt - (`V_SYNC + `V_BACK - 1'b1)) : 10'd0;		

endmodule
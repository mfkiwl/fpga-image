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
module lcd_top
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
	output	[10:0]	lcd_xpos,		//lcd horizontal coordinate
	output	[10:0]	lcd_ypos,		//lcd vertical coordinate
	input	[15:0]	lcd_data,		//lcd data
	
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


//-------------------------------------
lcd_driver u_lcd_driver
(
	//global clock
	.clk			(clk),		
	.rst_n			(rst_n), 
	 
	 //lcd interface
	.lcd_dclk		(lcd_dclk),
	.lcd_blank		(lcd_blank),
	.lcd_sync		(lcd_sync),		    	
	.lcd_hs			(lcd_hs),		
	.lcd_vs			(lcd_vs),
	.lcd_en			(lcd_en),		
	.lcd_rgb		(lcd_rgb),	

	
	//user interface
	.lcd_request	(lcd_request),
	.lcd_framesync	(lcd_framesync),
	.lcd_data		(lcd_data),	
	.lcd_xpos		(lcd_xpos),	
	.lcd_ypos		(lcd_ypos),
	
	//vi tri goc
	.top_pos_x(top_pos_x),
	.top_pos_y(top_pos_y),
	.bottom_pos_x(bottom_pos_x),
	.bottom_pos_y(bottom_pos_y),
	.left_pos_x(left_pos_x),
	.left_pos_y(left_pos_y),
	.right_pos_x(right_pos_x),
	.right_pos_y(right_pos_y),
	.centre_pos_x(centre_pos_x),
	.centre_pos_y(centre_pos_y),
	
	.button_1(button_1)
);

endmodule



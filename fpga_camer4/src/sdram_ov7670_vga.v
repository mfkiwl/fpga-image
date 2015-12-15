
`timescale 1ns / 1ps
module sdram_ov7670_vga
(
	//global clock 50MHz
	//input			clk_27,			//27MHz
	input			CLOCK,	
	//input			rst_n,			//global reset
	
	//sdram control
	output			S_CLK,		//sdram clock
	output			S_CKE,		//sdram clock enable
	output			S_NCS,		//sdram chip select
	output			S_NWE,		//sdram write enable
	output			S_NCAS,	//sdram column address strobe
	output			S_NRAS,	//sdram row address strobe
	output[1:0] 	S_DQM,		//sdram data enable 
	output	[1:0]	S_BA,		//sdram bank address
	output	[11:0]	S_A,		//sdram address
	inout	[15:0]	S_DB,		//sdram data
	
	//VGA port			
	output			VGA_HSYNC,			//horizontal sync 
	output			VGA_VSYNC,			//vertical sync
	output		VGA_RED,		//VGA data
	output		VGA_GREEN,		//VGA data
	output		VGA_BLUE,		//VGA data
	
	//cmos interface
	output			CMOS_SCLK,		//cmos i2c clock
	inout			CMOS_SDAT,		//cmos i2c data
	input			CMOS_VSYNC,		//cmos vsync
	input			CMOS_HREF,		//cmos hsync refrence
	input			CMOS_PCLK,		//cmos pxiel clock
	output			CMOS_XCLK,		//cmos externl clock
	input	[7:0]	CMOS_DB,		//cmos data
//	output			cmos_rst_n,		//cmos reset
//	output			cmos_pwdn,		//cmos pwer down

	output rs232_tx,

	input BUTTON_1,
	input BUTTON_2,
	input BUTTON_3
);
assign rst_n = 1'b1;
//---------------------------------------------
wire	clk_vga;		//vga clock
wire	clk_ref;		//sdram ctrl clock
wire	clk_refout;		//sdram clock output
wire	sys_rst_n;		//global reset
system_ctrl	u_system_ctrl
(
	.clk				(CLOCK),			//global clock  50MHZ
	.rst_n				(rst_n),		//external reset
	
	.sys_rst_n			(sys_rst_n),	//global reset
	.clk_c0				(clk_vga),		//25MHz
	.clk_c1				(clk_ref),		//100MHz -45deg
	.clk_c2				(clk_refout)	//100MHz
);
 

//-----------------------------
wire	[7:0]	I2C_RDATA;		//i2c register data
wire	[7:0]	LUT_INDEX;		//lut index
wire			Config_Done;	//I2C config done		
I2C_AV_Config	u_I2C_AV_Config 
(
	//Global clock
	.iCLK				(clk_vga),		//25MHz
	.iRST_N				(sys_rst_n),	//Global Reset
	
	//I2C Side
	.I2C_SCLK			(CMOS_SCLK),	//I2C CLOCK
	.I2C_SDAT			(CMOS_SDAT),	//I2C DATA
	
	//CMOS Signal
	.Config_Done		(Config_Done),	//I2C Config done
	.I2C_RDATA			(I2C_RDATA),	//CMOS ID
	.LUT_INDEX			()//(LUT_INDEX)		//ID Index
);
//-----------------------------------------------               
wire			frame_valid;		//data valid, or address restart
wire	[7:0]	cmos_fps_data;		//cmos frame rate
CMOS_Capture	u_CMOS_Capture
(
	//Global Clock
	.iCLK				(clk_vga),		//25MHz
	.iRST_N				(sys_rst_n),	//global reset
	
	//I2C Initilize Done
	.Init_Done			(Config_Done & sdram_init_done),	//Init Done
	
	//Sensor Interface
	.CMOS_RST_N			(),//(cmos_rst_n),	//cmos work state 
	.CMOS_PWDN			(),//(cmos_pwdn),	//cmos power on	
	.CMOS_XCLK			(CMOS_XCLK),		//cmos
	.CMOS_PCLK			(CMOS_PCLK),		//25MHz
	.CMOS_iDATA			(CMOS_DB),    	//CMOS Data
	.CMOS_VSYNC			(CMOS_VSYNC),  	 	//L: Vaild
	.CMOS_HREF			(CMOS_HREF), 		//H: Vaild
	                                    
	//Ouput Sensor Data                 
	.CMOS_oCLK			(sys_we),			//Data PCLK
	.CMOS_oDATA			(sys_data_in),  	//16Bits RGB
	.CMOS_VALID			(frame_valid),		//Data Enable
	.CMOS_FPS_DATA		()//(cmos_fps_data)		//cmos frame rate
);

//-------------------------------------
//sdram vga ctrl system
wire			sys_we;						//system data write enable
wire	[15:0]	sys_data_in;				//system data input
wire			sdram_init_done;			//sdram init done

wire  [3:0]   vga_r_rw;
wire  [4:0]   vga_g_rw;
wire  [3:0]   vga_b_rw;
sdram_vga_top	u_sdram_vga_top
(
	//global clock
	.clk_vga			(clk_vga),			//vga clock
	.clk_ref			(clk_ref),			//sdram ctrl clock
	.clk_refout			(clk_refout),		//sdram clock output
	.rst_n				(sys_rst_n),		//global reset

	//sdram control
	.sdram_clk			(S_CLK),		//sdram clock
	.sdram_cke			(S_CKE),		//sdram clock enable
	.sdram_cs_n			(S_NCS),		//sdram chip select
	.sdram_we_n			(S_NWE),		//sdram write enable
	.sdram_cas_n		(S_NCAS),		//sdram column address strobe
	.sdram_ras_n		(S_NRAS),		//sdram row address strobe
	.sdram_udqm			(S_DQM[1]),		//sdram data enable (H:8)
	.sdram_ldqm			(S_DQM[0]),		//sdram data enable (L:8)
	.sdram_ba			(S_BA),			//sdram bank address
	.sdram_addr			(S_A),		//sdram address
	.sdram_data			(S_DB),		//sdram data
		
	//lcd port
	.lcd_dclk			(),			//lcd pixel clock			
	.lcd_hs				(VGA_HSYNC),			//lcd horizontal sync 
	.lcd_vs				(VGA_VSYNC),			//lcd vertical sync
	.lcd_sync			(),//(lcd_sync),			//lcd sync
	.lcd_blank			(),		//lcd blank(L:blank)
	.lcd_red			({VGA_RED,vga_r_rw[3:0]}),			//lcd red data
	.lcd_green			({VGA_GREEN,vga_g_rw[4:0]}),		//lcd green data
	.lcd_blue			({VGA_BLUE,vga_b_rw[3:0]}),			//lcd blue data
	
	//user interface
	.clk_write			(CMOS_PCLK),			//fifo write clock
	.sys_we				(sys_we),			//fifo write enable
	.sys_data_in		(pixel_out_color),		//fifo data input
	.sdram_init_done	(sdram_init_done),	//sdram init done
	.frame_valid		(frame_valid),		//frame valid

	//vi tri goc
	.top_pos_x(top_pos_x),
	.top_pos_y(top_pos_y),
	.bottom_pos_x(bottom_pos_x),
	.bottom_pos_y(bottom_pos_y),
	.left_pos_x(left_pos_x),
	.left_pos_y(left_pos_y),
	.right_pos_x(right_pos_x),
	.right_pos_y(right_pos_y),
	.centre_pos_x(centre_pos_x_rs232),
	.centre_pos_y(centre_pos_y_rs232),
	
	.button_1(BUTTON_3)
);

//wire clk_out;
wire clk_out_enable;
wire frame_out_enable;
wire [15:0] pixel_out_color;
video_binary video_binary1(
			.clk(CMOS_PCLK),
			.clk_enable(sys_we),
			.frame_enable(frame_valid),
			.pixel_color(sys_data_in),
			.binary_enable1(BUTTON_1),
			.binary_enable2(BUTTON_2),
			.tx_int(tx_int),
			
			//.clk_out(clk_out),
			.clk_out_enable(clk_out_enable),
			.frame_out_enable(frame_out_enable),
			.pixel_out_color(pixel_out_color),
			.current_pos_x(current_pos_x),
			.current_pos_y(current_pos_y)
);

////////////////////////////////////////////		
wire [9:0] current_pos_x;
wire [9:0] current_pos_y;
				/////
wire [9:0] top_pos_x_1;
wire [9:0] top_pos_y_1;
wire [9:0] bottom_pos_x_1;
wire [9:0] bottom_pos_y_1;
wire [9:0] left_pos_x_1;
wire [9:0] left_pos_y_1;
wire [9:0] right_pos_x_1;
wire [9:0] right_pos_y_1;
wire [11:0] centre_pos_x_1;
wire [11:0] centre_pos_y_1;
wire [9:0] angle_x_1;
wire [9:0] angle_y_1;
wire chieu_xoay_1;
analyst_image1   analyst_image_1(
			.clk(CMOS_PCLK),
			.rx_data(pixel_out_color[15]),
			.uart_enw(clk_out_enable)	,
			.new_frm(frame_out_enable),
				/////
			.current_pos_x(current_pos_x),
			.current_pos_y(current_pos_y),
				/////
			.top_pos_x(top_pos_x_1),
			.top_pos_y(top_pos_y_1),
			.bottom_pos_x(bottom_pos_x_1),
			.bottom_pos_y(bottom_pos_y_1),
			.left_pos_x(left_pos_x_1),
			.left_pos_y(left_pos_y_1),
			.right_pos_x(right_pos_x_1),
			.right_pos_y(right_pos_y_1),
			.centre_pos_x(centre_pos_x_1),
			.centre_pos_y(centre_pos_y_1),
			.angle_x(angle_x_1),
			.angle_y(angle_y_1),
			.chieu_xoay(chieu_xoay_1),
			
//			.centre_pos_x_rs232(centre_pos_x_rs232),
//			.centre_pos_y_rs232(centre_pos_y_rs232),
//			.angle_x_rs232(angle_x_rs232),
//			.angle_y_rs232(angle_y_rs232),
//			.chieu_xoay_rs232(chieu_xoay_rs232)
			);	
			
//////////////////////////////////
wire [9:0] top_pos_x_2;
wire [9:0] top_pos_y_2;
wire [9:0] bottom_pos_x_2;
wire [9:0] bottom_pos_y_2;
wire [9:0] left_pos_x_2;
wire [9:0] left_pos_y_2;
wire [9:0] right_pos_x_2;
wire [9:0] right_pos_y_2;
wire [11:0] centre_pos_x_2;
wire [11:0] centre_pos_y_2;
wire [9:0] angle_x_2;
wire [9:0] angle_y_2;
wire chieu_xoay_2;
analyst_image2   analyst_image_2(
			.clk(CMOS_PCLK),
			.rx_data(pixel_out_color[15]),
			.uart_enw(clk_out_enable)	,
			.new_frm(frame_out_enable),
				/////
			.current_pos_x(current_pos_x),
			.current_pos_y(current_pos_y),
				/////
			.top_pos_x(top_pos_x_2),
			.top_pos_y(top_pos_y_2),
			.bottom_pos_x(bottom_pos_x_2),
			.bottom_pos_y(bottom_pos_y_2),
			.left_pos_x(left_pos_x_2),
			.left_pos_y(left_pos_y_2),
			.right_pos_x(right_pos_x_2),
			.right_pos_y(right_pos_y_2),
			.centre_pos_x(centre_pos_x_2),
			.centre_pos_y(centre_pos_y_2),
			.angle_x(angle_x_2),
			.angle_y(angle_y_2),
			.chieu_xoay(chieu_xoay_2),
			
//			.centre_pos_x_rs232(centre_pos_x_rs232),
//			.centre_pos_y_rs232(centre_pos_y_rs232),
//			.angle_x_rs232(angle_x_rs232),
//			.angle_y_rs232(angle_y_rs232),
//			.chieu_xoay_rs232(chieu_xoay_rs232)
			);	
			
//////////////////////////////////
wire [9:0] top_pos_x;
wire [9:0] top_pos_y;
wire [9:0] bottom_pos_x;
wire [9:0] bottom_pos_y;
wire [9:0] left_pos_x;
wire [9:0] left_pos_y;
wire [9:0] right_pos_x;
wire [9:0] right_pos_y;
selector  selector1(
			.clk(CMOS_PCLK),
				/////
			.current_pos_x(current_pos_x),
			.current_pos_y(current_pos_y),
				/////
			.top_pos_x_1(top_pos_x_1),
			.top_pos_y_1(top_pos_y_1),
			.bottom_pos_x_1(bottom_pos_x_1),
			.bottom_pos_y_1(bottom_pos_y_1),
			.left_pos_x_1(left_pos_x_1),
			.left_pos_y_1(left_pos_y_1),
			.right_pos_x_1(right_pos_x_1),
			.right_pos_y_1(right_pos_y_1),
			.centre_pos_x_1(centre_pos_x_1),
			.centre_pos_y_1(centre_pos_y_1),
			.angle_x_1(angle_x_1),
			.angle_y_1(angle_y_1),
			.chieu_xoay_1(chieu_xoay_1),
			
			//////////////////
			.top_pos_x_2(top_pos_x_2),
			.top_pos_y_2(top_pos_y_2),
			.bottom_pos_x_2(bottom_pos_x_2),
			.bottom_pos_y_2(bottom_pos_y_2),
			.left_pos_x_2(left_pos_x_2),
			.left_pos_y_2(left_pos_y_2),
			.right_pos_x_2(right_pos_x_2),
			.right_pos_y_2(right_pos_y_2),
			.centre_pos_x_2(centre_pos_x_2),
			.centre_pos_y_2(centre_pos_y_2),
			.angle_x_2(angle_x_2),
			.angle_y_2(angle_y_2),
			.chieu_xoay_2(chieu_xoay_2),
			
			//////////////////
			
			.centre_pos_x_rs232(centre_pos_x_rs232),
			.centre_pos_y_rs232(centre_pos_y_rs232),
			.angle_x_rs232(angle_x_rs232),
			.angle_y_rs232(angle_y_rs232),
			.chieu_xoay_rs232(chieu_xoay_rs232),
			///////////////////
			.top_pos_x_vga(top_pos_x),
			.top_pos_y_vga(top_pos_y),
			.bottom_pos_x_vga(bottom_pos_x),
			.bottom_pos_y_vga(bottom_pos_y),
			.left_pos_x_vga(left_pos_x),
			.left_pos_y_vga(left_pos_y),
			.right_pos_x_vga(right_pos_x),
			.right_pos_y_vga(right_pos_y)
			);	


//////////////////////////////////////
wire clk_ph;
wire tx_int;

wire [11:0] centre_pos_x_rs232;
wire [11:0] centre_pos_y_rs232;
wire [9:0] angle_x_rs232;
wire [9:0] angle_y_rs232;
wire chieu_xoay_rs232;

phat_pll phat_pll1(	
			.inclk0(CLOCK),
			.c0(clk_ph),
			.c1(),
			.c2()
); 

my_uart_tx			my_uart_tx1(		
							.clk(clk_ph),	
							.tx_int(tx_int),
							.rs232_tx(rs232_tx),
							.centre_pos_x(centre_pos_x_rs232),
							.centre_pos_y(centre_pos_y_rs232),
							.angle_x(angle_x_rs232),
							.angle_y(angle_y_rs232),
							.chieu_xoay(chieu_xoay_rs232)
						);
			
endmodule

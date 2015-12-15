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

`timescale 1 ns / 1 ns
module dcfifo_ctrl
(
	//global clock
	input				clk_ref,		//ȫ��ʱ��
	input 				clk_write,		//fifoд����ʱ��
	input				clk_read,		//fifo������ʱ��
	input 				rst_n,			//ȫ�ָ�λ
	
	//burst length
	input		[8:0]	wr_length,		//sdram��ͻ������
	input		[8:0]	rd_length,		//sdramдͻ������
	input				wr_load,		//sdramд��ַ������λ
	input		[21:0]	wr_addr,		//sdramд��ַ
	input		[21:0]	wr_max_addr,	//sdram����д��ַ
	input				rd_load,		//sdram���ַ������λ
	input		[21:0]	rd_addr,		//sdram���ַ
	input		[21:0]	rd_max_addr,	//sdram�������ַ
	
	//wrfifo:  fifo 2 sdram
	input 				wrf_wrreq,		//д��sdram���ݻ���fifo��������,��Ϊfifoд�ź�
	input		[15:0] 	wrf_din,		//д��sdram���ݻ���fifoд�����ߣ�д��sdram���ݣ�
	output 	reg			sdram_wr_req,	//д��sdram�����ź�
	input 				sdram_wr_ack,	//д��sdram��Ӧ�ź�,��Ϊfifo���ź�
	output		[15:0] 	sdram_din,		//д��sdram���ݻ���fifo������������
	output	reg	[21:0] 	sdram_wraddr,	//д��sdramʱ��ַ�ݴ�����{bank[1:0],row[11:0],column[7:0]} 

	//rdfifo: sdram 2 fifo
	input 				rdf_rdreq,		//��ȡsdram���ݻ���fifo��������
	output		[15:0] 	rdf_dout,		//��ȡsdram���ݻ���fifo�������ߣ���ȡsdram���ݣ�
	output 	reg			sdram_rd_req,	//��ȡsdram�����ź�
	input 				sdram_rd_ack,	//��ȡsdram��Ӧ�ź�,��Ϊfifo����д��Ч�ź�
	input		[15:0] 	sdram_dout,		//��ȡsdram���ݻ���fifo��������
	output	reg	[21:0] 	sdram_rdaddr,	//��ȡsdramʱ��ַ�ݴ�����{bank[1:0],row[11:0],column[7:0]} 
	
	//sdram address control	
	input				sdram_init_done,	//sdram��ʼ�������ź�
	output	reg			frame_write_done,	//sdram write one frame
	output	reg			frame_read_done,	//sdram read one frame
	input 				data_valid			//ʹ��sdram�����ݵ�Ԫ����Ѱַ����ַ����
);

//------------------------------------------------
//sdram��д��Ӧ���ɱ����½��ز���
reg	sdram_wr_ackr1, sdram_wr_ackr2;	
reg sdram_rd_ackr1, sdram_rd_ackr2;
always @(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n) 
		begin
		sdram_wr_ackr1 <= 1'b0;
		sdram_wr_ackr2 <= 1'b0;
		sdram_rd_ackr1 <= 1'b0;
		sdram_rd_ackr2 <= 1'b0;
		end
	else 
		begin
		sdram_wr_ackr1 <= sdram_wr_ack;
		sdram_wr_ackr2 <= sdram_wr_ackr1;
		sdram_rd_ackr1 <= sdram_rd_ack;
		sdram_rd_ackr2 <= sdram_rd_ackr1;		
		end
end	
wire write_done = sdram_wr_ackr2 & ~sdram_wr_ackr1;	//sdram_wr_ack�½��ر�־λ
wire read_done = sdram_rd_ackr2 & ~sdram_rd_ackr1;	//sdram_rd_ack�½��ر�־λ

//------------------------------------------------
//ͬ��sdram��д��ַ��ʼֵ��λ�ź�
reg	wr_load_r1, wr_load_r2;	
reg	rd_load_r1, rd_load_r2;	
always@(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n)
		begin
		wr_load_r1 <= 1'b0;
		wr_load_r2 <= 1'b0;
		rd_load_r1 <= 1'b0;
		rd_load_r2 <= 1'b0;
		end
	else
		begin
		wr_load_r1 <= wr_load;
		wr_load_r2 <= wr_load_r1;
		rd_load_r1 <= rd_load;
		rd_load_r2 <= rd_load_r1;
		end
end
wire	wr_load_flag = ~wr_load_r2 & wr_load_r1;	//��ַ���������ر�־λ
wire	rd_load_flag = ~rd_load_r2 & rd_load_r1;	//��ַ���������ر�־λ

//------------------------------------------------
//sdramд��ַ����ģ�飨���ȣ�
always @(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n)
		begin
		sdram_wraddr <= 22'd0;	
		frame_write_done <= 1'b0;
		end			
	else if(wr_load_flag)						//����sdramд������ַ
		begin
		sdram_wraddr <= wr_addr;	
		frame_write_done <= 1'b0;	
		end
	else if(write_done)						//ͻ��д������
		begin
		if(sdram_wraddr < wr_max_addr - wr_length)
			begin
			sdram_wraddr <= sdram_wraddr + wr_length;
			frame_write_done <= 1'b0;
			end
		else
			begin
			sdram_wraddr <= sdram_wraddr;		//��ֹ������������ַ
			frame_write_done <= 1'b1;
			end
		end
	else
		begin
		sdram_wraddr <= sdram_wraddr;			//������ַ
		frame_write_done <= frame_write_done;
		end
end

//------------------------------------------------
//sdram���ַ����ģ��(����)
always @(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n)
		begin
		sdram_rdaddr <= 22'd0;
		frame_read_done <= 0;
		end
	else if(rd_load_flag)						//����sdram��ȡ����ַ
		begin
		sdram_rdaddr <= rd_addr;
		frame_read_done <= 0;
		end
	else if(~data_valid_r)						//��ʾ��Ч��
		begin
		sdram_rdaddr <= rd_addr;
		frame_read_done <= 0;
		end
	else if(read_done)							//ͻ��д������
		begin
		if(sdram_rdaddr < rd_max_addr - rd_length)
			begin
			sdram_rdaddr <= sdram_rdaddr + rd_length;
			frame_read_done <= 0;
			end
		else
			begin
			sdram_rdaddr <= sdram_rdaddr;		//��ֹ������������ַ
			frame_read_done <= 1;
			end
		end
	else
		begin
		sdram_rdaddr <= sdram_rdaddr;			//������ַ
		frame_read_done <= frame_read_done;
		end
end

//------------------------------------------------
//ͬ�� ��дsdram��Ч�ź�
reg	data_valid_r;
always@(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n) 
		data_valid_r <= 1'b0;
	else 
		data_valid_r <= data_valid;
end

//-------------------------------------
//sdram ��д�źŲ���ģ��
wire	[8:0] 	wrf_use;
wire	[8:0] 	rdf_use;
always@(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n)	
		begin
		sdram_wr_req <= 0;
		sdram_rd_req <= 0;
		end
	else if(sdram_init_done == 1'b1)
		begin						//д�����ȣ������ڷ�ֹ���ݶ�ʧ
		if(wrf_use >= wr_length)	// && wr_load_flag == 1'b0)	
			begin					//wrfifo��ͻ������
			sdram_wr_req <= 1;		//дsdarmʹ��
			sdram_rd_req <= 0;		//��sdram����
			end
		else if(rdf_use < rd_length && data_valid_r == 1'b1)// && rd_load_flag == 1'b0)
			begin					//rdfifo��ͻ������
			sdram_wr_req <= 0;		//дsdram����
			sdram_rd_req <= 1;		//��sdramʹ��
			end
		else
			begin
			sdram_wr_req <= 0;		//дsdram����
			sdram_rd_req <= 0;		//��sdram����
			end
		end
	else
		begin
		sdram_wr_req <= 0;			//дsdram����
		sdram_rd_req <= 0;			//��sdram����
		end
end
//assign sdram_wr_req = (sdram_init_done == 1'b1 && wrf_use >= wr_length) ? 1'b1 : 1'b0;						//fifoд��sdram����
//assign sdram_rd_req = (sdram_init_done == 1'b1 && rdf_use < rd_length && data_valid_r == 1'b1) ? 1'b1 : 1'b0;	//sdramд��fifo����

//------------------------------------------------
//����sdramд�����ݻ���fifoģ��
wrfifo	u_wrfifo
(
	//input 2 fifo
	.wrclk		(clk_write),		//wrfifoдʱ��50MHz
	.wrreq		(wrf_wrreq),		//wrfifoдʹ���ź�
	.data		(wrf_din),			//wrfifo������������
	//fifo 2sdram
	.rdclk		(clk_ref),			//wrfifo��ʱ��100MHz
	.rdreq		(sdram_wr_ack),		//wrfifo��ʹ���ź�
	.q			(sdram_din),		//wrfifo������������
	//user port
	.aclr		(~rst_n | wr_load_flag),			//wrfifo�첽�����źţ�����Ҫ��
	.rdusedw	(wrf_use)			//wrfifo�洢�������
);	

//------------------------------------------------
//����sdram������ݻ���fifoģ��
rdfifo	u_rdfifo
(
	//sdram 2 fifo
	.wrclk		(clk_ref),       	//rdfifoдʱ��100MHz
	.wrreq		(sdram_rd_ack),  	//rdfifoдʹ���ź�
	.data		(sdram_dout),  		//rdfifo������������
	//fifo 2 output 
	.rdclk		(clk_read),        	//rdfifo��ʱ��50MHz
	.rdreq		(rdf_rdreq),     	//rdfifo��ʹ���ź�
	.q			(rdf_dout),			//rdfifo������������
	//user port
	.aclr		(~rst_n | ~data_valid_r | rd_load_flag),		//rdfifo�첽�����ź�
	.wrusedw	(rdf_use)        	//rdfifo�洢�������
);

endmodule

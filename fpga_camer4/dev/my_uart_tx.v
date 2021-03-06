`timescale 1ns / 1ps

module my_uart_tx(
				clk,
				tx_int,
				rs232_tx,
				centre_pos_x,
				centre_pos_y,
				angle_x,
				angle_y,
				chieu_xoay
			);

input clk;	
input tx_int;		
output rs232_tx;	
input [11:0]	centre_pos_x;
input [11:0]	centre_pos_y;
input [9:0]	angle_x;
input [9:0]	angle_y;
input chieu_xoay;
//---------------------------------------------------------
reg rs232_tx_r ;
reg [7:0] num_tx;

//always @ (posedge clk)
//	begin
//		if(tx_int) 
//			begin
//				   if (num_tx < 8'd99) 
//						begin
//							num_tx <= num_tx + 1'b1;
//						end
//					case (num_tx)
//						
//						8'd0: rs232_tx_r <= 1'b0; 	
//						8'd1: rs232_tx_r <= centre_pos_x[2];
//						8'd2: rs232_tx_r <= centre_pos_x[3];
//						8'd3: rs232_tx_r <= centre_pos_x[4];
//						8'd4: rs232_tx_r <= centre_pos_x[5];
//						8'd5: rs232_tx_r <= centre_pos_x[6];	
//						8'd6: rs232_tx_r <= centre_pos_x[7];	
//						8'd7: rs232_tx_r <= centre_pos_x[8];	
//						8'd8: rs232_tx_r <= centre_pos_x[9];	
//						8'd9: rs232_tx_r <= 1'b1;	
//						8'd10: rs232_tx_r <= 1'b1;
//						
//						8'd11: rs232_tx_r <= 1'b0; 	
//						8'd12: rs232_tx_r <= centre_pos_x[10];	
//						8'd13: rs232_tx_r <= centre_pos_x[11];
//						8'd14: rs232_tx_r <= 1'b0; 	
//						8'd15: rs232_tx_r <= 1'b0; 	
//						8'd16: rs232_tx_r <= 1'b0; 	
//						8'd17: rs232_tx_r <= 1'b0; 
//						8'd18: rs232_tx_r <= 1'b0; 	
//						8'd19: rs232_tx_r <= 1'b0; 
//						8'd20: rs232_tx_r <= 1'b1;	
//						8'd21: rs232_tx_r <= 1'b1;
//						
//						8'd22: rs232_tx_r <= 1'b0; 	
//						8'd23: rs232_tx_r <= centre_pos_y[2];
//						8'd24: rs232_tx_r <= centre_pos_y[3];
//						8'd25: rs232_tx_r <= centre_pos_y[4];
//						8'd26: rs232_tx_r <= centre_pos_y[5];
//						8'd27: rs232_tx_r <= centre_pos_y[6];	
//						8'd28: rs232_tx_r <= centre_pos_y[7];	
//						8'd29: rs232_tx_r <= centre_pos_y[8];	
//						8'd30: rs232_tx_r <= centre_pos_y[9];	
//						8'd31: rs232_tx_r <= 1'b1;	
//						8'd32: rs232_tx_r <= 1'b1;
//						
//						8'd33: rs232_tx_r <= 1'b0; 	
//						8'd34: rs232_tx_r <= centre_pos_y[10];	
//						8'd35: rs232_tx_r <= centre_pos_y[11];
//						8'd36: rs232_tx_r <= 1'b0; 	
//						8'd37: rs232_tx_r <= 1'b0; 	
//						8'd38: rs232_tx_r <= 1'b0; 	
//						8'd39: rs232_tx_r <= 1'b0; 
//						8'd40: rs232_tx_r <= 1'b0; 
//						8'd41: rs232_tx_r <= 1'b0; 
//						8'd42: rs232_tx_r <= 1'b1;	
//						8'd43: rs232_tx_r <= 1'b1;
//						
//						8'd44: rs232_tx_r <= 1'b0; 	
//						8'd45: rs232_tx_r <= angle_x[0];	 
//						8'd46: rs232_tx_r <= angle_x[1];	
//						8'd47: rs232_tx_r <= angle_x[2];	
//						8'd48: rs232_tx_r <= angle_x[3];	
//						8'd49: rs232_tx_r <= angle_x[4];		
//						8'd50: rs232_tx_r <= angle_x[5];	
//						8'd51: rs232_tx_r <= angle_x[6];	
//						8'd52: rs232_tx_r <= angle_x[7];	
//						8'd53: rs232_tx_r <= 1'b1;	
//						8'd54: rs232_tx_r <= 1'b1;
//						
//						8'd55: rs232_tx_r <= 1'b0; 	
//						8'd56: rs232_tx_r <= angle_x[8];	
//						8'd57: rs232_tx_r <= angle_x[9];
//						8'd58: rs232_tx_r <= 1'b0; 	
//						8'd59: rs232_tx_r <= 1'b0; 	
//						8'd60: rs232_tx_r <= 1'b0; 
//						8'd61: rs232_tx_r <= 1'b0; 	
//						8'd62: rs232_tx_r <= 1'b0; 
//						8'd63: rs232_tx_r <= 1'b0; 	
//						8'd64: rs232_tx_r <= 1'b1;	
//						8'd65: rs232_tx_r <= 1'b1;
//						
//						8'd66: rs232_tx_r <= 1'b0; 	
//						8'd67: rs232_tx_r <= angle_y[0];	
//						8'd68: rs232_tx_r <= angle_y[1];	
//						8'd69: rs232_tx_r <= angle_y[2];		
//						8'd70: rs232_tx_r <= angle_y[3];	
//						8'd71: rs232_tx_r <= angle_y[4];	
//						8'd72: rs232_tx_r <= angle_y[5];	
//						8'd73: rs232_tx_r <= angle_y[6];	
//						8'd74: rs232_tx_r <= angle_y[7];	
//						8'd75: rs232_tx_r <= 1'b1;	
//						8'd76: rs232_tx_r <= 1'b1;
//						
//						8'd77: rs232_tx_r <= 1'b0; 	
//						8'd78: rs232_tx_r <= angle_y[8];	
//						8'd79: rs232_tx_r <= angle_y[9];
//						8'd80: rs232_tx_r <= 1'b0; 	
//						8'd81: rs232_tx_r <= 1'b0; 	
//						8'd82: rs232_tx_r <= 1'b0; 
//						8'd83: rs232_tx_r <= 1'b0; 
//						8'd84: rs232_tx_r <= 1'b0; 
//						8'd85: rs232_tx_r <= 1'b0; 
//						8'd86: rs232_tx_r <= 1'b1;	
//						8'd87: rs232_tx_r <= 1'b1;
//						
//						8'd88: rs232_tx_r <= 1'b0; 	
//						8'd89: rs232_tx_r <= chieu_xoay;	
//						8'd90: rs232_tx_r <= 1'b0;
//						8'd91: rs232_tx_r <= 1'b0;	
//						8'd92: rs232_tx_r <= 1'b0;	
//						8'd93: rs232_tx_r <= 1'b0;
//						8'd94: rs232_tx_r <= 1'b0;	
//						8'd95: rs232_tx_r <= 1'b0;	
//						8'd96: rs232_tx_r <= 1'b0;
//						8'd97: rs232_tx_r <= 1'b1;	
//						8'd98: rs232_tx_r <= 1'b1;
//						
//					 	default: rs232_tx_r <= 1'b1;
//					endcase
//			end
//		else 
//			begin
//				rs232_tx_r <= 1'b1;
//				num_tx <= 4'd0;
//			end
//	end

always @ (posedge clk)
	begin
		if(tx_int) 
			begin
				   if (num_tx < 8'd121) 
						begin
							num_tx <= num_tx + 1'b1;
						end
					case (num_tx)
					
						8'd0: rs232_tx_r <= 1'b0; 	
						8'd1: rs232_tx_r <= 1'b1;
						8'd2: rs232_tx_r <= 1'b1;
						8'd3: rs232_tx_r <= 1'b1;
						8'd4: rs232_tx_r <= 1'b1;
						8'd5: rs232_tx_r <= 1'b1;	
						8'd6: rs232_tx_r <= 1'b1;	
						8'd7: rs232_tx_r <= 1'b1;	
						8'd8: rs232_tx_r <= 1'b1;	
						8'd9: rs232_tx_r <= 1'b1;	
						8'd10: rs232_tx_r <= 1'b1;
						
						8'd11: rs232_tx_r <= 1'b0; 	
						8'd12: rs232_tx_r <= 1'b1;	
						8'd13: rs232_tx_r <= 1'b1;
						8'd14: rs232_tx_r <= 1'b1; 	
						8'd15: rs232_tx_r <= 1'b1; 	
						8'd16: rs232_tx_r <= 1'b1; 	
						8'd17: rs232_tx_r <= 1'b1; 
						8'd18: rs232_tx_r <= 1'b1; 	
						8'd19: rs232_tx_r <= 1'b1; 
						8'd20: rs232_tx_r <= 1'b1;	
						8'd21: rs232_tx_r <= 1'b1;
						
						8'd22: rs232_tx_r <= 1'b0; 	
						8'd23: rs232_tx_r <= centre_pos_x[2];
						8'd24: rs232_tx_r <= centre_pos_x[3];
						8'd25: rs232_tx_r <= centre_pos_x[4];
						8'd26: rs232_tx_r <= centre_pos_x[5];
						8'd27: rs232_tx_r <= centre_pos_x[6];	
						8'd28: rs232_tx_r <= centre_pos_x[7];	
						8'd29: rs232_tx_r <= centre_pos_x[8];	
						8'd30: rs232_tx_r <= centre_pos_x[9];	
						8'd31: rs232_tx_r <= 1'b1;	
						8'd32: rs232_tx_r <= 1'b1;
						
						8'd33: rs232_tx_r <= 1'b0; 	
						8'd34: rs232_tx_r <= centre_pos_x[10];	
						8'd35: rs232_tx_r <= centre_pos_x[11];
						8'd36: rs232_tx_r <= 1'b0; 	
						8'd37: rs232_tx_r <= 1'b0; 	
						8'd38: rs232_tx_r <= 1'b0; 	
						8'd39: rs232_tx_r <= 1'b0; 
						8'd40: rs232_tx_r <= 1'b0; 	
						8'd41: rs232_tx_r <= 1'b0; 
						8'd42: rs232_tx_r <= 1'b1;	
						8'd43: rs232_tx_r <= 1'b1;
						
						8'd44: rs232_tx_r <= 1'b0; 	
						8'd45: rs232_tx_r <= centre_pos_y[2];
						8'd46: rs232_tx_r <= centre_pos_y[3];
						8'd47: rs232_tx_r <= centre_pos_y[4];
						8'd48: rs232_tx_r <= centre_pos_y[5];
						8'd49: rs232_tx_r <= centre_pos_y[6];	
						8'd50: rs232_tx_r <= centre_pos_y[7];	
						8'd51: rs232_tx_r <= centre_pos_y[8];	
						8'd52: rs232_tx_r <= centre_pos_y[9];	
						8'd53: rs232_tx_r <= 1'b1;	
						8'd54: rs232_tx_r <= 1'b1;
						
						8'd55: rs232_tx_r <= 1'b0; 	
						8'd56: rs232_tx_r <= centre_pos_y[10];	
						8'd57: rs232_tx_r <= centre_pos_y[11];
						8'd58: rs232_tx_r <= 1'b0; 	
						8'd59: rs232_tx_r <= 1'b0; 	
						8'd60: rs232_tx_r <= 1'b0; 	
						8'd61: rs232_tx_r <= 1'b0; 
						8'd62: rs232_tx_r <= 1'b0; 
						8'd63: rs232_tx_r <= 1'b0; 
						8'd64: rs232_tx_r <= 1'b1;	
						8'd65: rs232_tx_r <= 1'b1;
						
						8'd66: rs232_tx_r <= 1'b0; 	
						8'd67: rs232_tx_r <= angle_x[0];	 
						8'd68: rs232_tx_r <= angle_x[1];	
						8'd69: rs232_tx_r <= angle_x[2];	
						8'd70: rs232_tx_r <= angle_x[3];	
						8'd71: rs232_tx_r <= angle_x[4];		
						8'd72: rs232_tx_r <= angle_x[5];	
						8'd73: rs232_tx_r <= angle_x[6];	
						8'd74: rs232_tx_r <= angle_x[7];	
						8'd75: rs232_tx_r <= 1'b1;	
						8'd76: rs232_tx_r <= 1'b1;
						
						8'd77: rs232_tx_r <= 1'b0; 	
						8'd78: rs232_tx_r <= angle_x[8];	
						8'd79: rs232_tx_r <= angle_x[9];
						8'd80: rs232_tx_r <= 1'b0; 	
						8'd81: rs232_tx_r <= 1'b0; 	
						8'd82: rs232_tx_r <= 1'b0; 
						8'd83: rs232_tx_r <= 1'b0; 	
						8'd84: rs232_tx_r <= 1'b0; 
						8'd85: rs232_tx_r <= 1'b0; 	
						8'd86: rs232_tx_r <= 1'b1;	
						8'd87: rs232_tx_r <= 1'b1;
						
						8'd88: rs232_tx_r <= 1'b0; 	
						8'd89: rs232_tx_r <= angle_y[0];	
						8'd90: rs232_tx_r <= angle_y[1];	
						8'd91: rs232_tx_r <= angle_y[2];		
						8'd92: rs232_tx_r <= angle_y[3];	
						8'd93: rs232_tx_r <= angle_y[4];	
						8'd94: rs232_tx_r <= angle_y[5];	
						8'd95: rs232_tx_r <= angle_y[6];	
						8'd96: rs232_tx_r <= angle_y[7];	
						8'd97: rs232_tx_r <= 1'b1;	
						8'd98: rs232_tx_r <= 1'b1;
						
						8'd99: rs232_tx_r <= 1'b0; 	
						8'd100: rs232_tx_r <= angle_y[8];	
						8'd101: rs232_tx_r <= angle_y[9];
						8'd102: rs232_tx_r <= 1'b0; 	
						8'd103: rs232_tx_r <= 1'b0; 	
						8'd104: rs232_tx_r <= 1'b0; 
						8'd105: rs232_tx_r <= 1'b0; 
						8'd106: rs232_tx_r <= 1'b0; 
						8'd107: rs232_tx_r <= 1'b0; 
						8'd108: rs232_tx_r <= 1'b1;	
						8'd109: rs232_tx_r <= 1'b1;
						
						8'd110: rs232_tx_r <= 1'b0; 	
						8'd111: rs232_tx_r <= chieu_xoay;	
						8'd112: rs232_tx_r <= 1'b0;
						8'd113: rs232_tx_r <= 1'b0;	
						8'd114: rs232_tx_r <= 1'b0;	
						8'd115: rs232_tx_r <= 1'b0;
						8'd116: rs232_tx_r <= 1'b0;	
						8'd117: rs232_tx_r <= 1'b0;	
						8'd118: rs232_tx_r <= 1'b0;
						8'd119: rs232_tx_r <= 1'b1;	
						8'd120: rs232_tx_r <= 1'b1;
						
					 	default: rs232_tx_r <= 1'b1;
					endcase
			end
		else 
			begin
				rs232_tx_r <= 1'b1;
				num_tx <= 4'd0;
			end
	end

assign rs232_tx = rs232_tx_r;

endmodule



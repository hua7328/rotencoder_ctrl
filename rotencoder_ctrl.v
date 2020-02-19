`timescale 1ns / 1ps
/*********************************************************************
* @Company:	WuHan SINOROCK Technology CO.,Ltd
			Copyright(c) 2008, 中岩科技, All right reserved
* @Author:	yinzhongnan
* @File Name:	
* @Module Name:	rotencoder_ctrl
* @Description:	
* @Development Tools:	Quartus II 13.0
* @Revision History:	22-January-2015
*********************************************************************/

module	rotencoder_ctrl(
				iCLK,			//时钟，频率要比旋转高一些
				clear,			//计数器清零
				iROTP,iROTN,	//旋转编码器的两个输入 

				rot_event,		//有旋转事件出现时变高 
				rot_left, 		//左转时变高 
				data_high,
				data_low
				);
input iCLK; 
input clear;
input iROTP; 
input iROTN; 

output rot_event; 
output rot_left;

reg	rot_q1,rot_q2; 
reg rot_q1_delay; 
reg rot_event; 
reg	rot_left; 
wire[1:0] rot_input; 


reg[31:0] counter; 	//32位计数器

output[15:0] data_high; 
reg[15:0] data_high; 


output[15:0] data_low; 
reg[15:0] data_low; 

assign rot_input = {iROTP,iROTN}; 

always@(posedge iCLK) 
begin 
	case(rot_input) 
	2'b00:
		begin 
			rot_q1 <= 1'b0; 
			rot_q2 <= rot_q2; 
		end 
	2'b01:
		begin 
			rot_q1 <= rot_q1; 
			rot_q2 <= 1'b0; 
		end 
	2'b10:
		begin 
			rot_q1 <= rot_q1; 
			rot_q2 <= 1'b1; 
		end 
	2'b11:
		begin 
			rot_q1 <= 1'b1; 
			rot_q2 <= rot_q2; 
		end 
	endcase 

end 

always@(posedge iCLK) 
	rot_q1_delay <= rot_q1; 

always@(posedge iCLK) 
if((rot_q1 == 1'b1)&&(rot_q1_delay == 1'b0)) 
	begin 
		rot_event <= 1'b1; 
		rot_left <= rot_q2; 
	end 
else 
	begin 
		rot_event <= 1'b0; 	
		rot_left <= rot_left; 
	end 


always @(negedge rot_event or posedge clear) 
begin 
	if(clear)
		counter[31:0]<=32'd0;
	else
	begin
		if(rot_left) 
			begin 
				counter<=counter+1; 
			end 
		else 
			begin 
				counter<=counter-1; 
			end 
	end
end 

always @(posedge iCLK) 
begin 
	begin 
		data_high <= counter[31:16]; 
		data_low  <= counter[15:0]; 		
	end 
end

endmodule 


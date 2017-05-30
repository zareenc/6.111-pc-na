`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:55:45 11/27/2016 
// Design Name: 
// Module Name:    cue_speed_calculator 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module accel_speed_calculator(clk,x_avg,y_avg,z_avg,cue_speed,max_cue_speed);
	input clk;
	input signed [15:0] x_avg,y_avg,z_avg;
	output signed [31:0] cue_speed;
	output reg [4:0] max_cue_speed;
	
	// thresholds
	parameter T1 = 50_000_000;
	parameter T2 = 40_000_000;
	parameter T3 = 30_000_000;
	parameter T4 = 20_000_000;
	parameter T5 = 10_000_000;
	parameter T6 = 8_000_000;
	parameter T7 = 6_000_000;
	parameter T8 = 4_000_000;
	parameter T9 = 2_000_000;
	parameter T10 = 1_000_000;
	
	// cue speed
	parameter signed GRAVITY_SQ = 32'd260_000_000;//32'd268_435_456;
	wire [15:0] x_avg_p = {x_avg[15:8],8'b0};
	wire [15:0] y_avg_p = {y_avg[15:8],8'b0};
	wire [15:0] z_avg_p = {z_avg[15:8],8'b0};
	assign cue_speed = (x_avg_p*x_avg_p)+(y_avg_p*y_avg_p)
		+(z_avg_p*z_avg_p)-GRAVITY_SQ;

	
	// registers
	parameter BUFFER_SIZE = 8;
	reg signed [4:0] buffer [BUFFER_SIZE-1:0]; // keep track of past n speeds
	reg [3:0] i = 0;
	reg [4:0] count = 5'b0;
	parameter N = 8;
	
	// maximum cue speed
//	wire [4:0] max_cue_speed_q;
//	max_arr ma(.arr(buffer),.max(max_cue_speed_q));
	
	always @(posedge clk) begin
		if (count==N) begin
			// update max cue speed
			if (buffer[0]>buffer[1] && buffer[0]>buffer[2] && buffer[0]>buffer[3]
				&& buffer[0]>buffer[4] && buffer[0]>buffer[5] && buffer[0]>buffer[6]
				&& buffer[0]>buffer[7])
				max_cue_speed <= buffer[0];
			else if (buffer[1]>buffer[2] && buffer[1]>buffer[3]
				&& buffer[1]>buffer[4] && buffer[1]>buffer[5] && buffer[1]>buffer[6]
				&& buffer[1]>buffer[7])
				max_cue_speed <= buffer[1];
			else if (buffer[2]>buffer[3]
				&& buffer[2]>buffer[4] && buffer[2]>buffer[5] && buffer[2]>buffer[6]
				&& buffer[2]>buffer[7])
				max_cue_speed <= buffer[2];
			else if (buffer[3]>buffer[4] && buffer[3]>buffer[5] && buffer[3]>buffer[6]
				&& buffer[3]>buffer[7])
				max_cue_speed <= buffer[3];
			else if (buffer[4]>buffer[5] && buffer[4]>buffer[6]
				&& buffer[4]>buffer[7])
				max_cue_speed <= buffer[4];
			else if (buffer[5]>buffer[6]
				&& buffer[5]>buffer[7])
				max_cue_speed <= buffer[5];
			else if (buffer[6]>buffer[7])
				max_cue_speed <= buffer[6];
			else
				max_cue_speed <= buffer[7];
		
			// update counters
			if (i==BUFFER_SIZE) i <= 0;
			else i <= i+1;
			count <= 0;
			
			// populate buffer
			if (cue_speed<=T10)
				buffer[i] <= 4'd1;
			else if (cue_speed<=T9)
				buffer[i] <= 4'd2;
			else if (cue_speed<=T8)
				buffer[i] <= 4'd3;
			else if (cue_speed<=T7)
				buffer[i] <= 4'd4;
			else if (cue_speed<=T6)
				buffer[i] <= 4'd5;
			else if (cue_speed<=T5)
				buffer[i] <= 4'd6;
			else if (cue_speed<=T4)
				buffer[i] <= 4'd7;
			else if (cue_speed<=T3)
				buffer[i] <= 4'd8;
			else if (cue_speed<=T2)
				buffer[i] <= 4'd9;
			else if (cue_speed<=T1)
				buffer[i] <= 4'd10;
			else
				buffer[i] <= 4'd11;
		end
		
		else count <= count+1;
	end

endmodule


//module max_arr(buffer,max);
//	input [31:0] buffer [7:0];
//	output reg [4:0] max;
//	
//	always @(arr) begin
//		if (buffer[0]>buffer[1] && buffer[0]>buffer[2] && buffer[0]>buffer[3]
//			&& buffer[0]>buffer[4] && buffer[0]>buffer[5] && buffer[0]>buffer[6]
//			&& buffer[0]>buffer[7])
//			max = buffer[0];
//		else if (buffer[1]>buffer[2] && buffer[1]>buffer[3]
//			&& buffer[1]>buffer[4] && buffer[1]>buffer[5] && buffer[1]>buffer[6]
//			&& buffer[1]>buffer[7])
//			max = buffer[1];
//		else if (buffer[2]>buffer[3]
//			&& buffer[2]>buffer[4] && buffer[2]>buffer[5] && buffer[2]>buffer[6]
//			&& buffer[2]>buffer[7])
//			max = buffer[2];
//		else if (buffer[3]>buffer[4] && buffer[3]>buffer[5] && buffer[3]>buffer[6]
//			&& buffer[3]>buffer[7])
//			max = buffer[3];
//		else if (buffer[4]>buffer[5] && buffer[4]>buffer[6]
//			&& buffer[4]>buffer[7])
//			max = buffer[4];
//		else if (buffer[5]>buffer[6]
//			&& buffer[5]>buffer[7])
//			max = buffer[5];
//		else if (buffer[6]>buffer[7])
//			max = buffer[6];
//		else
//			max = buffer[7];
//	end
//endmodule
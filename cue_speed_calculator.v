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
module cue_speed_calculator(pause,clk,cue_front_x,cue_front_y,cue_hit,
									cue_speed,y_diff_pos,y_diff_neg,
									y_old,y_curr,y_diff_out,x_diff_out,pixel_speed);
	input clk;
	input pause;
	input cue_hit;
	input signed [10:0] cue_front_x;
	input signed [10:0] cue_front_y;
	output signed [21:0] cue_speed;
	output signed [10:0] y_diff_pos,y_diff_neg;
	output signed [10:0] y_diff_out;
	output signed [10:0] x_diff_out;
	output signed [10:0] y_old,y_curr;
	output signed [9:0] pixel_speed;
	
	// parameters
	parameter N = 8; // number of cue positions to store
	parameter SHIFT = 3;
	parameter MAX_COUNT = 10_000_00;
	parameter NOT_HIT = 0;
	parameter HIT = 1;
	reg state = NOT_HIT;
	
	// registers
//	reg [4:0] index = 5'b0;
	reg signed [87:0] x_arr = 88'b0; // stores N previous cue x-pos
	reg signed [87:0] y_arr = 88'b0; // stores N previous cue y-pos
	reg signed [10:0] x_diff = 11'b0;
	reg signed [10:0] y_diff = 11'b0;
	reg signed [21:0] cue_speed_sq = 22'b0;
	reg [25:0] count;
//	reg signed [10:0] x_accum = 11'b0; // current sum of cue x-pos
//	reg signed [9:0] y_accum = 10'b0; // current sum of cue y-pos
	
	// pixel speed converter
	cue_to_pixel_speed cue_to_pix(.clk(clk),.cue_speed(cue_speed_sq),
		.pixel_speed(pixel_speed));
	
	// assign outputs
	assign cue_speed = cue_speed_sq;
	assign y_diff_out = y_diff;
	assign x_diff_out = x_diff;
	
	// debugging
	assign y_old = y_arr[79:70];
	assign y_curr = y_arr[9:0];
	assign y_diff_pos = y_arr[9:0]-y_arr[79:70];
	assign y_diff_neg = -y_arr[9:0]+y_arr[79:70];
		
	always @(posedge clk) begin
		case (state)
			NOT_HIT: begin
				// update state
				if (pause || cue_hit) state <= HIT;
				
				if (count==MAX_COUNT) begin
					// update circular arrays
					x_arr[87:0] = {x_arr[76:0],cue_front_x};
					y_arr[87:0] = {y_arr[76:0],cue_front_y};
					
					// update outputted speed
//					x_diff = (x_arr[10:0]>x_arr[87:77]) ? x_arr[10:0]-x_arr[87:77]
//						: x_arr[87:77]-x_arr[10:0];
//					y_diff = (y_arr[9:0]>y_arr[79:70]) ? y_arr[9:0]-y_arr[79:70]
//						: y_arr[79:70]-y_arr[9:0];
					x_diff = x_arr[10:0]-x_arr[87:77];
					y_diff = y_arr[10:0]-y_arr[87:77];
					cue_speed_sq = (x_diff*x_diff) + (y_diff*y_diff);
					
					// reset count
					count <= 0;
				end
				else count <= count+1;
			end
			
			HIT: begin
				if (!pause) state <= NOT_HIT;
				else state <= HIT;
			end
		endcase
	end	
endmodule

module cue_to_pixel_speed(clk,cue_speed,pixel_speed);
	input clk;
	input signed [21:0] cue_speed;
	output reg signed [9:0] pixel_speed;
	
	always @(posedge clk) begin
		if (cue_speed>=21'h8000)
			pixel_speed <= 10'd30;
		else if (cue_speed>=21'h6000)
			pixel_speed <= 10'd20;
		else if (cue_speed>=21'h4000)
			pixel_speed <= 10'd15;
		else if (cue_speed>=21'h2000)
			pixel_speed <= 10'd10;
		else if (cue_speed>=21'h1000)
			pixel_speed <= 10'd8;
		else if (cue_speed>=21'h800)
			pixel_speed <= 10'd6;
		else if (cue_speed>=21'h400)
			pixel_speed <= 10'd5;
		else if (cue_speed>=21'h200)
			pixel_speed <= 10'd4;
		else if (cue_speed>=21'h100)
			pixel_speed <= 10'd3;
		else if (cue_speed>=21'h50)
			pixel_speed <= 10'd2;
		else pixel_speed <= 10'd0;
	end
endmodule
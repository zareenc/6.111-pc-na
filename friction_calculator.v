`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:57:59 12/07/2016 
// Design Name: 
// Module Name:    friction_calculator 
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
module friction (reset,done_fric_all,clk,xspeed,yspeed,any_hit,cue_hit,
						xspeed_fric,yspeed_fric,done_fric,fric_count_out,
						fric_abs_out_x,fric_abs_out_y,fric_state);
	input clk,reset,done_fric_all;
	input signed [10:0] xspeed;
	input signed [10:0] yspeed;
	input cue_hit, any_hit;
	output signed [10:0] xspeed_fric;
	output signed [10:0] yspeed_fric;
	output done_fric;
	output [7:0] fric_count_out;
	output signed [10:0] fric_abs_out_x, fric_abs_out_y;
	output [2:0] fric_state;
	
	// parameters and registers
	parameter MAX_FRIC_COUNT = 200;
	parameter signed MAX_FRICTION = 20;
	reg [7:0] fric_count_x = 0;
	reg [7:0] fric_count_y = 0;
	assign fric_count_out = fric_count_x;
	reg signed [10:0] delta_x = 0;
	reg signed [10:0] delta_y = 0;
	
	reg signed [10:0] fric_abs_x = 11'd0;
	reg signed [10:0] fric_abs_y = 11'd0;
	assign fric_abs_out_x = fric_abs_x;
	assign fric_abs_out_y = fric_abs_y;
	
	reg [7:0] done_count = 0;
	parameter MAX_DONE_COUNT = 50;
	
	// states
	parameter NO_CUE_HIT = 0;
	parameter CUE_HIT = 1;
	parameter DONE_MOVING = 2;
	reg [2:0] state = NO_CUE_HIT;
	
	// magnitude of speeds
	wire signed [10:0] abs_xspeed = (xspeed < 0) ? -xspeed : xspeed;
	wire signed [10:0] abs_yspeed = (yspeed < 0) ? -yspeed : yspeed;
//	wire hit = (wall_hit > 0) || (ball_hit1) || (ball_hit2);
	
	always @(posedge clk) begin
		case(state)
			NO_CUE_HIT: begin
				fric_abs_x <= 11'd0;
				fric_abs_y <= 11'd0;
				fric_count_x <= 8'd0;
				fric_count_y <= 8'd0;
				delta_x <= 0;
				delta_y <= 0;
				done_count <= 0;
				// update state
				if (cue_hit) begin
					state <= CUE_HIT;
					delta_x <= abs_xspeed;
					delta_y <= abs_yspeed;
				end
			end
			
			CUE_HIT: begin
				// change states 
				if (fric_abs_x >= abs_xspeed && fric_abs_y >= abs_yspeed)
					state <= DONE_MOVING;
				if (reset) state <= NO_CUE_HIT;
				
				// reset counter and step size when hit
				if (any_hit) begin
					fric_count_x <= 0;
					fric_count_y <= 0;
					delta_x <= abs_xspeed;
					delta_y <= abs_yspeed;
				end
				
				// increment friction geometrically
				else begin
					if (fric_count_x >= MAX_FRIC_COUNT) begin
						fric_count_x <= 0;
						fric_abs_x <= fric_abs_x + 1;
						// (fric_abs_x + 1 >= MAX_FRICTION) ? MAX_FRICTION : fric_abs_x + 1;
					end
					else fric_count_x <= fric_count_x + delta_x;
					
					if (fric_count_y >= MAX_FRIC_COUNT) begin
						fric_count_y <= 0;
						fric_abs_y <=  fric_abs_y + 1;
						// (fric_abs_y + 1 >= MAX_FRICTION) ? MAX_FRICTION	: fric_abs_y + 1;
					end
					else fric_count_y <= fric_count_y + delta_y;
				end
			end
			
			DONE_MOVING: begin
				if (reset) state <= NO_CUE_HIT;
				else if (done_fric_all) begin
					if (done_count == MAX_DONE_COUNT) state <= NO_CUE_HIT;
					else done_count <= done_count + 1;
				end
			end
		endcase
	end
	
	// sign of x, y frictions
	wire signed [10:0] fric_x_signed = (xspeed < 0) ? 
		fric_abs_x : -fric_abs_x;
	wire signed [10:0] fric_y_signed = (yspeed < 0) ? 
		fric_abs_y : -fric_abs_y;
	
	// output speeds
	assign xspeed_fric = (done_fric || fric_abs_x >= abs_xspeed) ? 11'b0 
		: xspeed + fric_x_signed;
	assign yspeed_fric = (done_fric || fric_abs_y >= abs_yspeed) ? 11'b0 
		: yspeed + fric_y_signed;
		
	assign done_fric = (state == DONE_MOVING);
	assign fric_state = state;

endmodule
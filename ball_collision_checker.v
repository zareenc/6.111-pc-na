`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:54:46 12/05/2016 
// Design Name: 
// Module Name:    puck_collision_checker 
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
module ball_collision_checker 
	#(parameter DISTANCE_SQUARED = 13'd1023, CUE_BALL = 1'b0, MAX_BALL_SPEED = 5'd20) // 2045
	(input vsync, 
	input signed [10:0] x1, x2, xspeed1, xspeed2, 
	input signed [10:0] y1, y2, yspeed1, yspeed2,
	input cue_hit, reset, done_fric_all,
	output collided,
	output signed [10:0] new_xspeed1, new_xspeed2,
	output signed [10:0] new_yspeed1, new_yspeed2);
	
	wire signed [10:0] x_dist, y_dist;
	assign x_dist = (x2 + (xspeed2 <<< 1)) - (x1 + (xspeed1 <<< 1));
	assign y_dist = (y2 + (yspeed2 <<< 1)) - (y1 + (yspeed1 <<< 1));
	reg collision_occur;
	
	reg cue_active;
	reg [2:0] collide_counter = 3'b0;
	parameter MAX_BALL_COLLIDE_COUNTER = 5;
	
	//For calculating impact vectors
//	reg signed [10:0] unitNormX1, unitNormX2, unitTangX1, unitTangX2, normX1, normX2, tangX1, tangX2;
//	reg signed [9:0] unitNormY1, unitNormY2, unitTangY1, unitTangY2, normY1, normY2, tangY1, tangY2;

	reg signed [10:0] newxspeed1, newxspeed2;
	reg signed [10:0] newyspeed1, newyspeed2;

	wire signed [10:0] abs_xspeed1 = (xspeed1 < 0) ? -xspeed1 : xspeed1;
	wire signed [10:0] abs_xspeed2 = (xspeed2 < 0) ? -xspeed2 : xspeed2;
	wire signed [10:0] abs_yspeed1 = (yspeed1 < 0) ? -yspeed1 : yspeed1;
	wire signed [10:0] abs_yspeed2 = (yspeed2 < 0) ? -yspeed2 : yspeed2;
//	wire signed [10:0] abs_xspeed_cue = (xspeed_cue < 0) ? -xspeed_cue : xspeed_cue;
//	wire signed [10:0] abs_yspeed_cue = (yspeed_cue < 0) ? -yspeed_cue : yspeed_cue;
	parameter RAD_SHIFT = 6;
	
	always @(posedge vsync) begin
		if (collide_counter == 0) begin
			if ((x_dist*x_dist) + (y_dist*y_dist) <= DISTANCE_SQUARED) begin
				collision_occur <= 1'b1;
				newxspeed1 <= (((x1 - x2) * abs_xspeed2) >>> RAD_SHIFT) + (((y1 - y2) * abs_xspeed1) >>> RAD_SHIFT);
				newyspeed1 <= (((y1 - y2) * abs_yspeed2) >>> RAD_SHIFT) + (((x2 - x1) * abs_yspeed1) >>> RAD_SHIFT);
				newxspeed2 <= (((x2 - y1) * abs_xspeed1) >>> RAD_SHIFT) + (((y2 - y1) * abs_xspeed2) >>> RAD_SHIFT);
				newyspeed2 <= (((y2 - y1) * abs_yspeed1) >>> RAD_SHIFT) + (((x1 - x2) * abs_yspeed2) >>> RAD_SHIFT);
				collide_counter <= collide_counter + 1;
			end
		end
		else begin
			if (collide_counter == MAX_BALL_COLLIDE_COUNTER) collide_counter <= 0;
			else collide_counter <= collide_counter + 1; 
			collision_occur <= 1'b0;
		end
	end
	
	// Friction module 1
	wire signed [10:0] new_xspeed1_fric;
	wire signed [10:0] new_yspeed1_fric;
	wire done_fric1;
	friction friction1(.clk(vsync),
		.xspeed(newxspeed1),.yspeed(newyspeed1),
		.cue_hit(cue_hit),
		.xspeed_fric(new_xspeed1_fric),.yspeed_fric(new_yspeed1_fric));
		
	// Friction module 2
	wire signed [10:0] new_xspeed2_fric;
	wire signed [10:0] new_yspeed2_fric;
	wire done_fric2;
	friction friction2(.clk(vsync),
		.xspeed(newxspeed2),.yspeed(newyspeed2),
		.cue_hit(cue_hit),.reset(reset),
		.xspeed_fric(new_xspeed2_fric),.yspeed_fric(new_yspeed2_fric));
	
	assign collided = collision_occur;
	assign new_xspeed1 = newxspeed1;
	assign new_yspeed1 = newyspeed1;
	assign new_xspeed2 = newxspeed2;
	assign new_yspeed2 = newyspeed2;
//		assign new_xspeed1 = (xspeed1>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
//			: (xspeed1<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : xspeed1;
//		assign new_yspeed1 = (yspeed1>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
//			: (yspeed1<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : yspeed1;
//		assign new_xspeed2 = (xspeed2>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
//			: (xspeed2<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : xspeed2;
//		assign new_yspeed2 = (yspeed2>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
//			: (yspeed2<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : yspeed2;
endmodule
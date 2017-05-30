`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:08:09 12/06/2016 
// Design Name: 
// Module Name:    cue_collision_checker 
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
module cue_collision_checker 
	#(parameter DISTANCE_SQUARED = 13'd320, CUE_BALL = 1'b0) //1088
	(input vsync, reset,done_fric_all,
	input signed [10:0] x1, x2, xspeed1, xspeed2, 
	input signed [10:0] y1, y2, yspeed1, yspeed2,
	output collided, cue_active,
	output signed [10:0] new_xspeed1, new_xspeed2,
	output signed [10:0] new_yspeed1, new_yspeed2);
	
	wire signed [10:0] x_dist, y_dist;
	assign x_dist = (x2 + xspeed2) - (x1 + xspeed1);
	assign y_dist = (y2 + yspeed2) - (y1 + yspeed1);
	reg collision_occur = 0;
	
	reg [2:0] collide_counter = 3'b0;
	parameter MAX_BALL_COLLIDE_COUNTER = 5;
	
	//For calculating impact vectors
//	reg signed [10:0] unitNormX1, unitNormX2, unitTangX1, unitTangX2, normX1, normX2, tangX1, tangX2;
//	reg signed [10:0] unitNormY1, unitNormY2, unitTangY1, unitTangY2, normY1, normY2, tangY1, tangY2;

	reg signed [10:0] newxspeed1, newxspeed2;
	reg signed [10:0] newyspeed1, newyspeed2;

	wire signed [10:0] abs_xspeed1 = (xspeed1 < 0) ? -xspeed1 : xspeed1;
	wire signed [10:0] abs_xspeed2 = (xspeed2 < 0) ? -xspeed2 : xspeed2;
	wire signed [10:0] abs_yspeed1 = (yspeed1 < 0) ? -yspeed1 : yspeed1;
	wire signed [10:0] abs_yspeed2 = (yspeed2 < 0) ? -yspeed2 : yspeed2;
//	wire signed [10:0] abs_xspeed_cue = (xspeed_cue < 0) ? -xspeed_cue : xspeed_cue;
//	wire signed [10:0] abs_yspeed_cue = (yspeed_cue < 0) ? -yspeed_cue : yspeed_cue;

	parameter NO_HIT = 0;
	parameter HIT = 1;
	parameter RAD_SHIFT = 5;//5
	reg [2:0] state = NO_HIT;
	
	always @(posedge vsync) begin
		case (state)
			NO_HIT: begin
				if ((x_dist*x_dist) + (y_dist*y_dist) <= DISTANCE_SQUARED) begin
					collision_occur <= 1'b1;
					newxspeed1 <= (((x1 - x2) * abs_xspeed2) >>> RAD_SHIFT) + (((y1 - y2) * abs_xspeed1) >>> RAD_SHIFT);
					newyspeed1 <= (((y1 - y2) * abs_yspeed2) >>> RAD_SHIFT) + (((x2 - x1) * abs_yspeed1) >>> RAD_SHIFT);
					newxspeed2 <= (((x2 - y1) * abs_xspeed1) >>> RAD_SHIFT) + (((y2 - y1) * abs_xspeed2) >>> RAD_SHIFT);
					newyspeed2 <= (((y2 - y1) * abs_yspeed1) >>> RAD_SHIFT) + (((x1 - x2) * abs_yspeed2) >>> RAD_SHIFT);
					collide_counter <= collide_counter + 1;
					state <= HIT;
				end
				else begin
					collision_occur <= 1'b0;
				end
			end
			
			HIT: begin
				if (reset || done_fric_all) begin
					state <= NO_HIT;
					collision_occur <= 1'b0;
				end
			end
		endcase
	end
	
	assign collided = collision_occur;
	assign cue_active = (state == NO_HIT);
	assign new_xspeed1 = newxspeed1;
	assign new_yspeed1 = newyspeed1;
	assign new_xspeed2 = newxspeed2;
	assign new_yspeed2 = newyspeed2;
endmodule

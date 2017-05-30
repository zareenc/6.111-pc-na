`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:53:44 12/05/2016 
// Design Name: 
// Module Name:    wall_collision_checker 
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
module wall_collision_checker
	#(parameter RADIUS = 11'd16,//32
					 TABLE_WIDTH = 800,
					 TABLE_HEIGHT = 600)
	(input vsync, 
	 input cue_hit, reset, done_fric_all,
	 input signed [10:0] x, 
	 input signed [10:0] y, 
	 input signed [10:0] xspeed, 
	 input signed [10:0] yspeed, 
	 output [1:0] collision,
	 output signed [10:0] new_xspeed,
	 output signed [10:0] new_yspeed);
	 
	reg x_coll, y_coll;
	reg signed [10:0] newxspeed;
	reg signed [10:0] newyspeed;
	
	//Collision Buffer
	reg [2:0] x_collide_counter = 3'b0;
	reg [2:0] y_collide_counter = 3'b0;
	parameter MAX_WALL_COLLIDE_COUNTER = 5;
	
	always @(posedge vsync) begin
		if (x_collide_counter == 3'b0) begin
			if ((x + xspeed < RADIUS) && (xspeed <= 0)) begin
				x_coll <= 1'b1;
				newxspeed <= -xspeed;
				x_collide_counter <= x_collide_counter + 1; 
			end
			else if ((x + xspeed > TABLE_WIDTH - RADIUS) && (xspeed >= 0)) begin
				x_coll <= 1'b1;
				newxspeed <= -xspeed;
				x_collide_counter <= x_collide_counter + 1;
			end
		end
		else begin
			if (x_collide_counter == MAX_WALL_COLLIDE_COUNTER) x_collide_counter <= 0;
			else x_collide_counter <= x_collide_counter + 1; 
			x_coll <= 1'b0;
		end
		
		if (y_collide_counter == 3'b0) begin
			if ((y + yspeed < RADIUS) && (yspeed <= 0)) begin
				y_coll <= 1'b1;
				newyspeed <= -yspeed;
				y_collide_counter <= y_collide_counter + 1; 
			end
			else if ((y + yspeed > TABLE_HEIGHT - RADIUS) && (yspeed >= 0)) begin
				y_coll <= 1'b1;
				newyspeed <= -yspeed;
				y_collide_counter <= y_collide_counter + 1; 
			end
		end
		else begin
			if (y_collide_counter == MAX_WALL_COLLIDE_COUNTER) y_collide_counter <= 0;
			else y_collide_counter <= y_collide_counter + 1; 
			y_coll <= 1'b0;
		end
	end
	
	// Friction module 
	wire signed [10:0] new_xspeed_fric;
	wire signed [10:0] new_yspeed_fric;
	friction friction1(.clk(vsync),
		.xspeed(newxspeed),.yspeed(newyspeed),
		.cue_hit(cue_hit),.reset(reset),
		.xspeed_fric(new_xspeed_fric),.yspeed_fric(new_yspeed_fric));
		
	assign new_xspeed = newxspeed;
	assign new_yspeed = newyspeed;
	assign collision = {x_coll, y_coll};
endmodule
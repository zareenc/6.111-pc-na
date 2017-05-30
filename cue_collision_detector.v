`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:05:46 11/28/2016 
// Design Name: 
// Module Name:    cue_collision_detector 
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
module cue_collision_detector(clk,front_x,front_y,back_x,back_y,
	hit_ball,hit_x,hit_y,ball1_x,ball1_y);
	input clk;
	input [10:0] front_x,back_x;
	input [9:0] front_y,back_y;
	input [11:0] ball1_x;
	input [10:0] ball1_y;
	output reg [2:0] hit_ball = 3'b0; // 0 if no hits; collided ball number otherwise
	output reg [10:0] hit_x = 11'b0; // x position of collision
	output reg [9:0] hit_y = 10'b0; // y position of collision
	
	// radius: 32 pixels
	parameter RADIUS = 32;
	parameter MARGIN = 5;
	parameter X_MIN = 0;
	parameter X_MAX = 1023;
	parameter Y_MIN = 0;
	parameter Y_MAX = 767;
	
	// collision detectors
	wire ball1_collision;
	wire [10:0] ball1_left = (ball1_x[10:0]-RADIUS-MARGIN<=X_MIN) ? X_MIN : ball1_x[10:0]-RADIUS-MARGIN;
	wire [10:0] ball1_right = (ball1_x[10:0]+RADIUS+MARGIN>=X_MAX) ? X_MAX : ball1_x[10:0]+RADIUS+MARGIN;
	wire [9:0] ball1_top = (ball1_y[9:0]-RADIUS-MARGIN<=Y_MIN) ? Y_MIN : ball1_y[9:0]-RADIUS-MARGIN;
	wire [9:0] ball1_bottom = (ball1_y[9:0]+RADIUS+MARGIN>=Y_MAX) ? Y_MAX : ball1_y[9:0]+RADIUS+MARGIN;
	//TODO: maybe hold collision wire high for longer?
	check_bounds check_ball1(.left(ball1_left),.right(ball1_right),.top(ball1_top),
		.bottom(ball1_bottom),.check_x(front_x),.check_y(front_y),.in_bounds(ball1_collision));
	
	always @(posedge clk) begin
		if (ball1_collision) begin
			hit_ball <= 3'b1;
			hit_x <= front_x;
			hit_y <= front_y;
		end
		else hit_ball <= 3'b0;
	end

endmodule

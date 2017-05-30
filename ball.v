`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:23:22 11/20/2016 
// Design Name: 
// Module Name:    ball 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Creates the sprite for a pool ball.  
//
//////////////////////////////////////////////////////////////////////////////////
module ball
	#(parameter RADIUS = 6'd16, // 32
					 RADIUS_SQUARED = 11'd256) //1024)
	
	 (input [23:0] color,
	 input [10:0] x, hcount,
    input [10:0] y, vcount, 
    output reg [23:0] pixel,
	 input striped
    );
	 
//	 parameter [10:0] RADIUS_SQUARED = RADIUS*RADIUS
	 wire signed [10:0] xspeed = 10'b10;
	 wire signed [10:0] yspeed = 9'b100;
	 wire signed [10:0] x_dist, y_dist;
	 
	 assign x_dist = (hcount >= x) ? hcount - x : x - hcount;  //Don't want to worry abouty signed numbers - they get squared
	 assign y_dist = (vcount >= y) ? vcount - y : y - vcount; 
	 always @ * begin
		if ( (x_dist*x_dist) + (y_dist*y_dist) <= RADIUS_SQUARED) begin
			if (striped) begin
				if (x_dist < 5'd6) pixel = 24'hFF_FF_FF;
				else pixel = color;
			end
			else pixel = color;
		end
		else pixel = 0;

	end
endmodule

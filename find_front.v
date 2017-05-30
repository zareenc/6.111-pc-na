`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:15:24 11/28/2016 
// Design Name: 
// Module Name:    track_cue 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: distinguishes front & back of cue and outputs their coordinates
//
//////////////////////////////////////////////////////////////////////////////////

module find_front(clk,hor1,vert1,hor2,vert2,hor3,vert3,
						front_hor,front_vert,back_hor,back_vert);
	// inputs & outputs
	input clk;
	input [21:0] hor1,hor2,hor3;
	input [21:0] vert1,vert2,vert3;
	output reg [21:0] front_hor,back_hor;
	output reg [21:0] front_vert,back_vert;
	
	// bounding boxes	
	wire [21:0] area12, area13, area23;
	bounding_box box12(clk,hor1,vert1,hor2,vert2,area12);
	bounding_box box13(clk,hor1,vert1,hor3,vert3,area13);
	bounding_box box23(clk,hor3,vert3,hor2,vert2,area23);
	
	always @(*) begin
		// identify back
		if (area12>area23 && area13>area23) begin // 1 is back
			back_hor = hor1;
			back_vert = vert1;
			// identify front
			if (area12>area13) begin // 2 is front
				front_hor = hor2;
				front_vert = vert2;
			end
			else begin // 3 is front
				front_hor = hor3;
				front_vert = vert3;
			end
		end
		
		else if (area23>area13 && area12>area13) begin // 2 is back
			back_hor = hor2;
			back_vert = vert2;
			if (area23 > area12) begin // 3 is front
				front_hor = hor3;
				front_vert = vert3;
			end
			// identify front
			else begin // 1 is front
				front_hor = hor1;
				front_vert = vert1;
			end
		end
		
		else begin // 3 is back
			back_hor = hor3;
			back_vert = vert3;
			// identify front
			if (area13>area23) begin // 1 is front
				front_hor = hor1;
				front_vert = vert1;
			end
			else begin // 2 is front
				front_hor = hor2;
				front_vert = vert2;
			end
		end
	end
endmodule
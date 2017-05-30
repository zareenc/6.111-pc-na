`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:17:22 11/28/2016 
// Design Name: 
// Module Name:    bounding_box 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: size of bounds created by two tracked points
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module bounding_box(clk,hor1,vert1,hor2,vert2,area);
	input clk;
	input [21:0] hor1,hor2;
	input [21:0] vert1,vert2;
	output [21:0] area;
	
	// Determine bounds
	wire [10:0] left = (hor1[21:11]<hor2[21:11]) ? hor1[21:11] : hor2[21:11];
	wire [10:0] right = (hor1[10:0]>hor2[10:0]) ? hor1[10:0] : hor2[10:0];
	wire [10:0] top = (vert1[21:11]<vert2[21:11]) ? vert1[21:11] : vert2[21:11];
	wire [10:0] bottom = (vert1[10:0]>vert2[10:0]) ? vert1[10:0] : vert2[10:0];
	
	// Calculate area
	assign area = (right-left)*(bottom-top);

endmodule

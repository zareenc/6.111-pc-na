`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:27:19 11/28/2016 
// Design Name: 
// Module Name:    check_bounds 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: checks membership within rectangular bounds
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module check_bounds(left, right, top, bottom, check_x, check_y, in_bounds);
	input [10:0] left, right, check_x;
	input [9:0] top, bottom, check_y;
	output in_bounds;
	
	wire in_bounds = (check_x>=left && check_x<=right && 
					 check_y>=top && check_y<=bottom);
endmodule

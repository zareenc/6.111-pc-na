`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:28:35 11/17/2016 
// Design Name: 
// Module Name:    zone 
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
module zone #(parameter MAX_X = 800, MAX_Y = 600)
				(hcount,vcount,left,right,top,bottom,
				reset,cascade_in,cascade_out,clk,state);
	input [10:0] hcount, vcount;
	input clk;
	input reset, cascade_in;
	output reg [10:0] left, right;
	output reg [10:0] top, bottom;
	output reg cascade_out;
	output reg [2:0] state;
	
	// Parameters
	parameter MARGIN = 7;
	parameter INIT_SIZE = 10;
	parameter INACTIVE = 0;
	parameter ACTIVE = 1;

	// State
//	reg [2:0] state = INACTIVE;
	
	always @(posedge clk) begin
		// Reset zone to inactive at new frame
		if (reset) state <= INACTIVE;
		
		// If not checking current zone, don't check next zone
		else if (!cascade_in) cascade_out <= 0;
	
		else begin
			cascade_out <= 1; // Default cascading to true
			
			// Initialize zone bounds around pixel
			if (state==INACTIVE) begin
				left <= (hcount-INIT_SIZE>=0) ? hcount-INIT_SIZE : 0;
				right <= (hcount+INIT_SIZE<=MAX_X) ? hcount+INIT_SIZE : MAX_X;
				top <= (vcount-INIT_SIZE>=0) ? vcount-INIT_SIZE : 0;
				bottom <= (vcount+INIT_SIZE<=MAX_Y) ? vcount+INIT_SIZE : MAX_Y;
				state <= ACTIVE; // update state
				cascade_out <= 0; // Don't cascade to next zone
			end
		
			// Update bounds if within pixel is within margins
			else if (hcount>=(left-MARGIN) && hcount<=(right+MARGIN)
				&& vcount>=(top-MARGIN) && vcount<=(bottom+MARGIN)) begin
				
				// Update zone's horizontal bounds
				if (hcount<left) left <= hcount;
				else if (hcount>right) right <= hcount;
				
				// Update zone's vertical bounds
				if (vcount<top) top <= vcount;
				else if (vcount>bottom) bottom <= vcount;
				
				cascade_out <= 0; // Don't cascade to next zone
			end
		end
	end
endmodule

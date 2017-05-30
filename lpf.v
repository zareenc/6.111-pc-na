`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:04:01 11/27/2016 
// Design Name: 
// Module Name:    lpf 
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
module lpf(clk,data,x_avg,y_avg,z_avg);
	input clk;
	input signed [47:0] data;
	output reg signed [15:0] x_avg = 16'b0;
	output reg signed [15:0] y_avg = 16'b0;
	output reg signed [15:0] z_avg = 16'b0;
	
	// registers
	parameter N = 8;
	parameter SHIFT = 3;
	reg [4:0] index = 5'b0;
	reg signed [19:0] x_accum = 20'b0;
	reg signed [19:0] y_accum = 20'b0;
	reg signed [19:0] z_accum = 20'b0;
		
	always @(posedge clk) begin
		if (index==N) begin			
			// avg
			x_avg <= x_accum>>>SHIFT;
			y_avg <= y_accum>>>SHIFT;
			z_avg <= z_accum>>>SHIFT;
			
			// reset
			x_accum <= 20'b0;
			y_accum <= 20'b0;
			z_accum <= 20'b0;
			index <= 0;
		end
		else begin
			x_accum <= x_accum + data[47:32];
			y_accum <= y_accum + data[31:16];
			z_accum <= z_accum + data[15:0];
			index <= index+1;
		end
	end
endmodule

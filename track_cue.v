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

module track_cue(clk,hcount,vcount,is_bright,
						hor1,hor2,hor3,
						vert1,vert2,vert3);
	input clk;
	input [10:0] hcount;
	input [10:0] vcount;
	input is_bright;
	output [21:0] hor1,hor2,hor3;
	output [21:0] vert1,vert2,vert3;

	// parameters
	parameter MINH = 50; //100
	parameter MAXH = 740; //650 
	parameter MINV = 75; //75
	parameter MAXV = 550; //525

	// zone modules
	reg reset; //= (hcount==0 && vcount==0); // Set reset
	wire c1 = (is_bright && hcount > MINH && hcount < MAXH // Set first cascade
		&& vcount < MAXV && vcount > MINV);
	wire [10:0] l1,r1,l2,r2,l3,r3; // horizontal bounds of zones
	wire [10:0] t1,b1,t2,b2,t3,b3; // vertical bounds of zones
	wire c2,c3,c4; // cascades
	zone z1(.hcount(hcount),.vcount(vcount),.clk(clk),.cascade_out(c2),.state(state1),
		.left(l1),.right(r1),.top(t1),.bottom(b1),.reset(reset),.cascade_in(c1));
	zone z2(.hcount(hcount),.vcount(vcount),.clk(clk),.cascade_out(c3),.state(state2),
		.left(l2),.right(r2),.top(t2),.bottom(b2),.reset(reset),.cascade_in(c2));
	zone z3(.hcount(hcount),.vcount(vcount),.clk(clk),.cascade_out(c4),.state(state3),
		.left(l3),.right(r3),.top(t3),.bottom(b3),.reset(reset),.cascade_in(c3));

	// registers
	reg [3:0] count = 0;

	always @(posedge clk) begin
		if (count==10) begin
			count <= 0;
			reset <= 0;
		end
		else if ((hcount==0 && vcount==0) || count>0) begin
			reset <= 1;
			count <= count+1;
		end
		else reset <= 0;
	end
	
	// Set outputs
	wire hor1 = {l1,r1};
	wire vert1 = {t1,b1};
	wire hor2 = {l2,r2};
	wire vert2 = {t2,b2};
	wire hor3 = {l3,r3};
	wire vert3 = {t3,b3};

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:12:33 11/17/2016 
// Design Name: 
// Module Name:    calibration 
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
module calibration(clk,is_bright,hcount,vcount,done,calibrated,
						hor1,vert1,hor2,vert2,
						hor3,vert3,hor4,vert4,
						xo_r, xf_r, yo_r, yf_r,
						state1,state2,state3,state4);
	input clk;
	input is_bright;
	input calibrated;
	input [10:0] hcount;
	input [10:0] vcount;
	output [21:0] hor1,hor2,hor3,hor4;
	output [21:0] vert1,vert2,vert3,vert4;
	output reg [10:0] xo_r = 11'b0;
	output reg [10:0] xf_r = 11'b0;
	output reg [10:0] yo_r = 11'b0;
	output reg [10:0] yf_r = 11'b0;
	output done;
	output [2:0] state1,state2,state3,state4;
	
	// parameters
	parameter MINH = 50; //100
	parameter MAXH = 740; //650 
	parameter MINV = 75; //75
	parameter MAXV = 550; //525
	
	// zones
	reg reset; //= (hcount==0 && vcount==0); // Set reset
	wire c1 = (is_bright && hcount > MINH && hcount < MAXH // Set first cascade
		&& vcount < MAXV && vcount > MINV);
	wire [10:0] l1,r1,l2,r2,l3,r3,l4,r4; // horizontal bounds of zones
	wire [10:0] t1,b1,t2,b2,t3,b3,t4,b4; // vertical bounds of zones
	wire c2,c3,c4,c5; // cascades	
	
	zone z1(.hcount(hcount),.vcount(vcount),.clk(clk),.cascade_out(c2),.state(state1),
		.left(l1),.right(r1),.top(t1),.bottom(b1),.reset(reset),.cascade_in(c1));
	zone z2(.hcount(hcount),.vcount(vcount),.clk(clk),.cascade_out(c3),.state(state2),
		.left(l2),.right(r2),.top(t2),.bottom(b2),.reset(reset),.cascade_in(c2));
	zone z3(.hcount(hcount),.vcount(vcount),.clk(clk),.cascade_out(c4),.state(state3),
		.left(l3),.right(r3),.top(t3),.bottom(b3),.reset(reset),.cascade_in(c3));
	zone z4(.hcount(hcount),.vcount(vcount),.clk(clk),.cascade_out(c5),.state(state4),
		.left(l4),.right(r4),.top(t4),.bottom(b4),.reset(reset),.cascade_in(c4));
		
	// registers
	reg done_r = 0;
	assign done = done_r;
	reg [3:0] count = 0;
	reg [10:0] ctr_x1, ctr_x2, ctr_x3, ctr_x4;
	reg [10:0] ctr_y1, ctr_y2, ctr_y3, ctr_y4;
	
		// fsm
	always @(posedge clk) begin
		// refresh at every (hsync,vsync) = (0,0)
		if (count==10) begin
			count <= 0;
			reset <= 0;
		end
		else if ((hcount==0 && vcount==0) || count>0) begin
			reset <= 1;
			count <= count+1;
		end
		else reset <= 0;
		
		// done with calibration
		if (calibrated) begin
			done_r <= 1;
			
			// Horizontal centers
			ctr_x1 = (r1+l1)/2;
			ctr_x2 = (r2+l2)/2;
			ctr_x3 = (r3+l3)/2;
			ctr_x4 = (r4+l4)/2;
			
			// Vertical centers
			ctr_y1 = (b1+t1)/2;
			ctr_y2 = (b2+t2)/2;
			ctr_y3 = (b3+t3)/2;
			ctr_y4 = (b4+t4)/2;
			
			// Determine xo
			if (ctr_x1<=ctr_x2 && ctr_x1<=ctr_x3 && ctr_x1<=ctr_x4)
				xo_r = ctr_x1;
			else if (ctr_x2<=ctr_x1 && ctr_x2<=ctr_x3 && ctr_x2<=ctr_x4)
				xo_r = ctr_x2;
			else if (ctr_x3<=ctr_x1 && ctr_x3<=ctr_x2 && ctr_x3<=ctr_x4)	
				xo_r = ctr_x3;
			else
				xo_r = ctr_x4;
				
			// Determine xf
			if (ctr_x4>=ctr_x3 && ctr_x4>=ctr_x2 && ctr_x4>=ctr_x1)
				xf_r = ctr_x4;
			else if (ctr_x3>=ctr_x4 && ctr_x3>=ctr_x2 && ctr_x3>=ctr_x1)
				xf_r = ctr_x3;
			else if (ctr_x2>=ctr_x4 && ctr_x2>=ctr_x3 && ctr_x2>=ctr_x1)
				xf_r = ctr_x2;
			else
				xf_r = ctr_x1;
			
			// Determine yo
			if (ctr_y1<=ctr_y2 && ctr_y1<=ctr_y3 && ctr_y1<=ctr_y4)
				yo_r = ctr_y1;
			else if (ctr_y2<=ctr_y1 && ctr_y2<=ctr_y3 && ctr_y2<=ctr_y4)
				yo_r = ctr_y2;
			else if (ctr_y3<=ctr_y1 && ctr_y3<=ctr_y2 && ctr_y3<=ctr_y4)	
				yo_r = ctr_y3;
			else
				yo_r = ctr_y4;
				
			// Determine yf
			if (ctr_y4>=ctr_y3 && ctr_y4>=ctr_y2 && ctr_y4>=ctr_y1)
				yf_r = ctr_y4;
			else if (ctr_y3>=ctr_y4 && ctr_y3>=ctr_y2 && ctr_y3>=ctr_y1)
				yf_r = ctr_y3;
			else if (ctr_y2>=ctr_y4 && ctr_y2>=ctr_y3 && ctr_y2>=ctr_y1)
				yf_r = ctr_y2;
			else
				yf_r = ctr_y1;
		end
	end
	
	wire hor1 = {l1,r1};
	wire vert1 = {t1,b1};
	wire hor2 = {l2,r2};
	wire vert2 = {t2,b2};
	wire hor3 = {l3,r3};
	wire vert3 = {t3,b3};
	wire hor4 = {l4,r4};
	wire vert4 = {t4,b4};
	
endmodule

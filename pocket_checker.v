`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:46:36 12/09/2016 
// Design Name: 
// Module Name:    pocket_checker 
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
module pocket_checker
	#(parameter POCKET_SIZE = 6'd32, parameter DISTANCE_SQUARED = 13'd1023)
	(input vsync, reset,
	input signed [10:0] x_pocket0,x_pocket1,x_pocket2,x_pocket3,x_pocket4,x_pocket5,
	input signed [10:0] y_pocket0,y_pocket1,y_pocket2,y_pocket3,y_pocket4,y_pocket5,
	input signed [10:0] x1, x2, x3, x4, x5,
	input signed [10:0] y1, y2, y3, y4, y5,
	output ball1_in, ball2_in, ball3_in, ball4_in, ball5_in);
		
	// Ball 1
	wire signed [10:0] x_dist1_pocket0 = (x_pocket0 - x1);
	wire signed [10:0] y_dist1_pocket0 = (y_pocket0 - y1);
	wire signed [10:0] x_dist1_pocket1 = (x_pocket1 - x1);
	wire signed [10:0] y_dist1_pocket1 = (y_pocket1 - y1);
	wire signed [10:0] x_dist1_pocket2 = (x_pocket2 - x1);
	wire signed [10:0] y_dist1_pocket2 = (y_pocket2 - y1);
	wire signed [10:0] x_dist1_pocket3 = (x_pocket3 - x1);
	wire signed [10:0] y_dist1_pocket3 = (y_pocket3 - y1);
	wire signed [10:0] x_dist1_pocket4 = (x_pocket4 - x1);
	wire signed [10:0] y_dist1_pocket4 = (y_pocket4 - y1);
	wire signed [10:0] x_dist1_pocket5 = (x_pocket5 - x1);
	wire signed [10:0] y_dist1_pocket5 = (y_pocket5 - y1);
	
	// Ball 2
	wire signed [10:0] x_dist2_pocket0 = (x_pocket0 - x2);
	wire signed [10:0] y_dist2_pocket0 = (y_pocket0 - y2);
	wire signed [10:0] x_dist2_pocket1 = (x_pocket1 - x2);
	wire signed [10:0] y_dist2_pocket1 = (y_pocket1 - y2);
	wire signed [10:0] x_dist2_pocket2 = (x_pocket2 - x2);
	wire signed [10:0] y_dist2_pocket2 = (y_pocket2 - y2);
	wire signed [10:0] x_dist2_pocket3 = (x_pocket3 - x2);
	wire signed [10:0] y_dist2_pocket3 = (y_pocket3 - y2);
	wire signed [10:0] x_dist2_pocket4 = (x_pocket4 - x2);
	wire signed [10:0] y_dist2_pocket4 = (y_pocket4 - y2);
	wire signed [10:0] x_dist2_pocket5 = (x_pocket5 - x2);
	wire signed [10:0] y_dist2_pocket5 = (y_pocket5 - y2);
	
	// Ball 3
	wire signed [10:0] x_dist3_pocket0 = (x_pocket0 - x3);
	wire signed [10:0] y_dist3_pocket0 = (y_pocket0 - y3);
	wire signed [10:0] x_dist3_pocket1 = (x_pocket1 - x3);
	wire signed [10:0] y_dist3_pocket1 = (y_pocket1 - y3);
	wire signed [10:0] x_dist3_pocket2 = (x_pocket2 - x3);
	wire signed [10:0] y_dist3_pocket2 = (y_pocket2 - y3);
	wire signed [10:0] x_dist3_pocket3 = (x_pocket3 - x3);
	wire signed [10:0] y_dist3_pocket3 = (y_pocket3 - y3);
	wire signed [10:0] x_dist3_pocket4 = (x_pocket4 - x3);
	wire signed [10:0] y_dist3_pocket4 = (y_pocket4 - y3);
	wire signed [10:0] x_dist3_pocket5 = (x_pocket5 - x3);
	wire signed [10:0] y_dist3_pocket5 = (y_pocket5 - y3);
	
	// Ball 4
	wire signed [10:0] x_dist4_pocket0 = (x_pocket0 - x4);
	wire signed [10:0] y_dist4_pocket0 = (y_pocket0 - y4);
	wire signed [10:0] x_dist4_pocket1 = (x_pocket1 - x4);
	wire signed [10:0] y_dist4_pocket1 = (y_pocket1 - y4);
	wire signed [10:0] x_dist4_pocket2 = (x_pocket2 - x4);
	wire signed [10:0] y_dist4_pocket2 = (y_pocket2 - y4);
	wire signed [10:0] x_dist4_pocket3 = (x_pocket3 - x4);
	wire signed [10:0] y_dist4_pocket3 = (y_pocket3 - y4);
	wire signed [10:0] x_dist4_pocket4 = (x_pocket4 - x4);
	wire signed [10:0] y_dist4_pocket4 = (y_pocket4 - y4);
	wire signed [10:0] x_dist4_pocket5 = (x_pocket5 - x4);
	wire signed [10:0] y_dist4_pocket5 = (y_pocket5 - y4);
	
	// Ball 5
	wire signed [10:0] x_dist5_pocket0 = (x_pocket0 - x5);
	wire signed [10:0] y_dist5_pocket0 = (y_pocket0 - y5);
	wire signed [10:0] x_dist5_pocket1 = (x_pocket1 - x5);
	wire signed [10:0] y_dist5_pocket1 = (y_pocket1 - y5);
	wire signed [10:0] x_dist5_pocket2 = (x_pocket2 - x5);
	wire signed [10:0] y_dist5_pocket2 = (y_pocket2 - y5);
	wire signed [10:0] x_dist5_pocket3 = (x_pocket3 - x5);
	wire signed [10:0] y_dist5_pocket3 = (y_pocket3 - y5);
	wire signed [10:0] x_dist5_pocket4 = (x_pocket4 - x5);
	wire signed [10:0] y_dist5_pocket4 = (y_pocket4 - y5);
	wire signed [10:0] x_dist5_pocket5 = (x_pocket5 - x5);
	wire signed [10:0] y_dist5_pocket5 = (y_pocket5 - y5);

	reg ball1_reg = 0;
	reg ball2_reg = 0;
	reg ball3_reg = 0;
	reg ball4_reg = 0;
	reg ball5_reg = 0;
	reg collision_occur;
	
	always @(posedge vsync) begin
		if (reset) begin
			ball1_reg <= 1'b0;
			ball2_reg <= 1'b0;
			ball3_reg <= 1'b0;
			ball4_reg <= 1'b0;
			ball5_reg <= 1'b0;
		end
		
		else if (ball1_reg) begin
			ball1_reg <= 1'b0;
		end
		
		else begin
			if ((x_dist1_pocket0*x_dist1_pocket0)+(y_dist1_pocket0*y_dist1_pocket0)<=DISTANCE_SQUARED
				 || (x_dist1_pocket1*x_dist1_pocket1)+(y_dist1_pocket1*y_dist1_pocket1)<=DISTANCE_SQUARED
				 || (x_dist1_pocket2*x_dist1_pocket2)+(y_dist1_pocket2*y_dist1_pocket2)<=DISTANCE_SQUARED
				 || (x_dist1_pocket3*x_dist1_pocket3)+(y_dist1_pocket3*y_dist1_pocket3)<=DISTANCE_SQUARED
				 || (x_dist1_pocket4*x_dist1_pocket4)+(y_dist1_pocket4*y_dist1_pocket4)<=DISTANCE_SQUARED
				 || (x_dist1_pocket5*x_dist1_pocket5)+(y_dist1_pocket5*y_dist1_pocket5)<=DISTANCE_SQUARED) begin
				ball1_reg <= 1'b1;
			end
			
			if ((x_dist2_pocket0*x_dist2_pocket0)+(y_dist2_pocket0*y_dist2_pocket0)<=DISTANCE_SQUARED
				 || (x_dist2_pocket1*x_dist2_pocket1)+(y_dist2_pocket1*y_dist2_pocket1)<=DISTANCE_SQUARED
				 || (x_dist2_pocket2*x_dist2_pocket2)+(y_dist2_pocket2*y_dist2_pocket2)<=DISTANCE_SQUARED
				 || (x_dist2_pocket3*x_dist2_pocket3)+(y_dist2_pocket3*y_dist2_pocket3)<=DISTANCE_SQUARED
				 || (x_dist2_pocket4*x_dist2_pocket4)+(y_dist2_pocket4*y_dist2_pocket4)<=DISTANCE_SQUARED
				 || (x_dist2_pocket5*x_dist2_pocket5)+(y_dist2_pocket5*y_dist2_pocket5)<=DISTANCE_SQUARED) begin
				ball2_reg <= 1'b1;
			end
			
			if ((x_dist3_pocket0*x_dist3_pocket0)+(y_dist3_pocket0*y_dist3_pocket0)<=DISTANCE_SQUARED
				 || (x_dist3_pocket1*x_dist3_pocket1)+(y_dist3_pocket1*y_dist3_pocket1)<=DISTANCE_SQUARED
				 || (x_dist3_pocket2*x_dist3_pocket2)+(y_dist3_pocket2*y_dist3_pocket2)<=DISTANCE_SQUARED
				 || (x_dist3_pocket3*x_dist3_pocket3)+(y_dist3_pocket3*y_dist3_pocket3)<=DISTANCE_SQUARED
				 || (x_dist3_pocket4*x_dist3_pocket4)+(y_dist3_pocket4*y_dist3_pocket4)<=DISTANCE_SQUARED
				 || (x_dist3_pocket5*x_dist3_pocket5)+(y_dist3_pocket5*y_dist3_pocket5)<=DISTANCE_SQUARED) begin
				ball3_reg <= 1'b1;
			end

			if ((x_dist4_pocket0*x_dist4_pocket0)+(y_dist4_pocket0*y_dist4_pocket0)<=DISTANCE_SQUARED
				 || (x_dist4_pocket1*x_dist4_pocket1)+(y_dist4_pocket1*y_dist4_pocket1)<=DISTANCE_SQUARED
				 || (x_dist4_pocket2*x_dist4_pocket2)+(y_dist4_pocket2*y_dist4_pocket2)<=DISTANCE_SQUARED
				 || (x_dist4_pocket3*x_dist4_pocket3)+(y_dist4_pocket3*y_dist4_pocket3)<=DISTANCE_SQUARED
				 || (x_dist4_pocket4*x_dist4_pocket4)+(y_dist4_pocket4*y_dist4_pocket4)<=DISTANCE_SQUARED
				 || (x_dist4_pocket5*x_dist4_pocket5)+(y_dist4_pocket5*y_dist4_pocket5)<=DISTANCE_SQUARED) begin
				ball4_reg <= 1'b1;
			end

			if ((x_dist5_pocket0*x_dist5_pocket0)+(y_dist5_pocket0*y_dist5_pocket0)<=DISTANCE_SQUARED
				 || (x_dist5_pocket1*x_dist5_pocket1)+(y_dist5_pocket1*y_dist5_pocket1)<=DISTANCE_SQUARED
				 || (x_dist5_pocket2*x_dist5_pocket2)+(y_dist5_pocket2*y_dist5_pocket2)<=DISTANCE_SQUARED
				 || (x_dist5_pocket3*x_dist5_pocket3)+(y_dist5_pocket3*y_dist5_pocket3)<=DISTANCE_SQUARED
				 || (x_dist5_pocket4*x_dist5_pocket4)+(y_dist5_pocket4*y_dist5_pocket4)<=DISTANCE_SQUARED
				 || (x_dist5_pocket5*x_dist5_pocket5)+(y_dist5_pocket5*y_dist5_pocket5)<=DISTANCE_SQUARED) begin
				ball5_reg <= 1'b1;
			end
		end
	end
	
	assign ball1_in = ball1_reg;
	assign ball2_in = ball2_reg;
	assign ball3_in = ball3_reg;
	assign ball4_in = ball4_reg;
	assign ball5_in = ball5_reg;

endmodule
 `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:32:07 11/20/2016 
// Design Name: 
// Module Name:    position_handler 
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
module position_handler
    #(parameter
		BALL_RADIUS = 5'd15,
		// Ball 1
		BALL1_X_START = 11'd350,
		BALL1_Y_START = 11'd300,
		BALL1_X_SPEED = 11'd0,
		BALL1_Y_SPEED = 11'd0,
		// Ball 2
		BALL2_X_START = 11'd215,
		BALL2_Y_START = 11'd230,
		BALL2_X_SPEED = 11'd0,
		BALL2_Y_SPEED = 11'd0,
		// Ball 3
		BALL3_X_START = 11'd415,
		BALL3_Y_START = 11'd470,
		BALL3_X_SPEED = 11'd0,
		BALL3_Y_SPEED = 11'd0,
		// Ball 4
		BALL4_X_START = 11'd500,
		BALL4_Y_START = 11'd305,
		BALL4_X_SPEED = 11'd0,
		BALL4_Y_SPEED = 11'd0,
		// Ball 5
		BALL5_X_START = 11'd475,
		BALL5_Y_START = 11'd350,
		BALL5_X_SPEED = 11'd0,
		BALL5_Y_SPEED = 11'd0)
	(input vsync, 
	 input reset,done_fric_all, 
	 // Cue
	 input cue_hit, cue_active,
	 input signed [10:0] xspeed_cue, 
	 input signed [10:0] yspeed_cue,
	 // Ball 1
	 input signed [10:0] xspeed1_cue, yspeed1_cue,
	 input signed [10:0] xspeed1_wall, 
	 input signed [10:0] yspeed1_wall, 
	 input signed [10:0] xspeed1_prev,
	 input signed [10:0] yspeed1_prev,
	 input ball1_pocketed, 
	 input [1:0] wall_hit1, 	 
	 input signed [10:0] xspeed1_coll_1_2, xspeed1_coll_1_3, xspeed1_coll_1_4, xspeed1_coll_1_5,
	 input signed [10:0] yspeed1_coll_1_2, yspeed1_coll_1_3, yspeed1_coll_1_4, yspeed1_coll_1_5,
	 // Ball 2
	 input signed [10:0] xspeed2_wall, 
	 input signed [10:0] yspeed2_wall, 
	 input signed [10:0] xspeed2_prev,
	 input signed [10:0] yspeed2_prev,
	 input ball2_pocketed, 
	 input [1:0] wall_hit2, 	 
	 input signed [10:0] xspeed2_coll_1_2, xspeed2_coll_2_3, xspeed2_coll_2_4, xspeed2_coll_2_5,  
	 input signed [10:0] yspeed2_coll_1_2, yspeed2_coll_2_3, yspeed2_coll_2_4, yspeed2_coll_2_5,
	 // Ball 3
	 input signed [10:0] xspeed3_wall, 
	 input signed [10:0] yspeed3_wall, 
	 input signed [10:0] xspeed3_prev,
	 input signed [10:0] yspeed3_prev,
	 input ball3_pocketed, 
	 input [1:0] wall_hit3, 	 
	 input signed [10:0] xspeed3_coll_1_3, xspeed3_coll_2_3, xspeed3_coll_3_4, xspeed3_coll_3_5,
	 input signed [10:0] yspeed3_coll_1_3, yspeed3_coll_2_3, yspeed3_coll_3_4, yspeed3_coll_3_5,
	 // Ball 4
	 input signed [10:0] xspeed4_wall, 
	 input signed [10:0] yspeed4_wall, 
	 input signed [10:0] xspeed4_prev,
	 input signed [10:0] yspeed4_prev,
	 input ball4_pocketed, 
	 input [1:0] wall_hit4, 	 
	 input signed [10:0] xspeed4_coll_1_4, xspeed4_coll_2_4, xspeed4_coll_3_4, xspeed4_coll_4_5,
	 input signed [10:0] yspeed4_coll_1_4, yspeed4_coll_2_4, yspeed4_coll_3_4, yspeed4_coll_4_5,
	 // Ball 5
	 input signed [10:0] xspeed5_wall, 
	 input signed [10:0] yspeed5_wall, 
	 input signed [10:0] xspeed5_prev,
	 input signed [10:0] yspeed5_prev,
	 input ball5_pocketed, 
	 input [1:0] wall_hit5, 	 
	 input signed [10:0] xspeed5_coll_1_5, xspeed5_coll_2_5, xspeed5_coll_3_5, xspeed5_coll_4_5,
	 input signed [10:0] yspeed5_coll_1_5, yspeed5_coll_2_5, yspeed5_coll_3_5, yspeed5_coll_4_5,
	 // Collisions
	 input coll_1_2, coll_1_3, coll_1_4, coll_2_3, coll_2_4, coll_3_4,
	 coll_1_5, coll_2_5, coll_3_5, coll_4_5,
	 
	 output signed [10:0] fric_abs_out_x, fric_abs_out_y,
	 // Ball 1
	 output signed [10:0] xspeed1_fric, new_x1, new_xspeed1, 
	 output signed [10:0] yspeed1_fric, new_y1, new_yspeed1,
	 output [2:0] fric_state1, 
	 // Ball 2
	 output signed [10:0] xspeed2_fric, new_x2, new_xspeed2, 
	 output signed [10:0] yspeed2_fric, new_y2, new_yspeed2,
	 output [2:0] fric_state2, 
	 // Ball 3
	 output signed [10:0] xspeed3_fric, new_x3, new_xspeed3, 
	 output signed [10:0] yspeed3_fric, new_y3, new_yspeed3,
	 output [2:0] fric_state3, 
	 // Ball 4
	 output signed [10:0] xspeed4_fric, new_x4, new_xspeed4, 
	 output signed [10:0] yspeed4_fric, new_y4, new_yspeed4,
	 output [2:0] fric_state4,
	 // Ball 5
	 output signed [10:0] xspeed5_fric, new_x5, new_xspeed5, 
	 output signed [10:0] yspeed5_fric, new_y5, new_yspeed5,
	 output [2:0] fric_state5,
	 // Debugging
	 output cue_active_r_out,
	 input debug);
	 
	 
	 //Initialize values
	 // Ball 1
	 reg signed [10:0] x1 = BALL1_X_START;
	 reg signed [10:0] y1 = BALL1_Y_START;
	 reg signed [10:0] xspeed1 = BALL1_X_SPEED;
	 reg signed [10:0] yspeed1 = BALL1_Y_SPEED; 
	 
	 // Ball 2
	 reg signed [10:0] x2 = BALL2_X_START;
	 reg signed [10:0] y2 = BALL2_Y_START;
	 reg signed [10:0] xspeed2 = BALL2_X_SPEED;
	 reg signed [10:0] yspeed2 = BALL2_Y_SPEED;

	 // Ball 3
	 reg signed [10:0] x3 = BALL3_X_START;
	 reg signed [10:0] y3 = BALL3_Y_START;
	 reg signed [10:0] xspeed3 = BALL3_X_SPEED;
	 reg signed [10:0] yspeed3 = BALL3_Y_SPEED;

	 // Ball 4
	 reg signed [10:0] x4 = BALL4_X_START;
	 reg signed [10:0] y4 = BALL4_Y_START;
	 reg signed [10:0] xspeed4 = BALL4_X_SPEED;
	 reg signed [10:0] yspeed4 = BALL4_Y_SPEED;

	 // Ball 4
	 reg signed [10:0] x5 = BALL5_X_START;
	 reg signed [10:0] y5 = BALL5_Y_START;
	 reg signed [10:0] xspeed5 = BALL5_X_SPEED;
	 reg signed [10:0] yspeed5 = BALL5_Y_SPEED;

	 // Parameters
	 parameter signed MAX_BALL_SPEED = 11'd15;
	 parameter VERT_HIT = 2'b01;
	 parameter HORIZ_HIT = 2'b10;
	 parameter signed SCALE_CUE_NUM = 10;
	 reg cue_active_r = 1;
	 assign cue_active_r_out = cue_active_r;
	 
	 // States
	 parameter START_GAME = 0;
	 parameter DONE_ROUND = 1;
	 parameter MOVING = 2;
	 parameter SCRATCH = 3;
	 parameter WIN = 4;
	 reg [2:0] state = START_GAME;
	 
	 always @(posedge vsync) begin
		case(state)
			START_GAME: begin // reset or scratch
				if (debug) begin
					// Ball 1
					x1 <= 11'd350;
					y1 <= 11'd300;
					xspeed1 <= 11'd0;
					yspeed1 <= 11'd0;
					
					// Ball 2
					x2 <= 11'd600;
					y2 <= 11'd300;
					xspeed2<= BALL2_X_SPEED;
					yspeed2<= BALL2_Y_SPEED;
				end
				
				else begin
					// Ball 1
					x1 <= BALL1_X_START;
					y1 <= BALL1_Y_START;
					xspeed1<= BALL1_X_SPEED;
					yspeed1<= BALL1_Y_SPEED;
					
					// Ball 2
					x2 <= BALL2_X_START;
					y2 <= BALL2_Y_START;
					xspeed2<= BALL2_X_SPEED;
					yspeed2<= BALL2_Y_SPEED;
				end

				// Ball 3
				x3 <= BALL3_X_START;
				y3 <= BALL3_Y_START;			
				xspeed3<= BALL3_X_SPEED;
				yspeed3<= BALL3_Y_SPEED;
				
				// Ball 4
				x4 <= BALL4_X_START;
				y4 <= BALL4_Y_START;			
				xspeed4<= BALL4_X_SPEED;
				yspeed4<= BALL4_Y_SPEED;
				
				// Ball 5
				x5 <= BALL5_X_START;
				y5 <= BALL5_Y_START;			
				xspeed5<= BALL5_X_SPEED;
				yspeed5<= BALL5_Y_SPEED;
				
				cue_active_r<= 1;
				state <= MOVING;
			end
			
			DONE_ROUND: begin // when all balls stop moving
				xspeed1 <= 0;
				yspeed1 <= 0;
				
				xspeed2<= BALL2_X_SPEED;
				yspeed2<= BALL2_Y_SPEED;
				
				xspeed3<= BALL3_X_SPEED;
				yspeed3<= BALL3_Y_SPEED;
				
				xspeed4<= BALL4_X_SPEED;
				yspeed4<= BALL4_Y_SPEED;
				
				xspeed5<= BALL5_X_SPEED;
				yspeed5<= BALL5_Y_SPEED;
				
				cue_active_r <= 1;
				state <= MOVING;
			end
			
			SCRATCH: begin // when ball 1 is pocketed
				x1 <= BALL1_X_START;
				y1 <= BALL1_Y_START;
				xspeed1<= BALL1_X_SPEED;
				yspeed1<= BALL1_Y_SPEED;
				
				cue_active_r <= 1;
				state <= MOVING;
			end
			
			WIN: begin // when player wins
				if (reset) state <= START_GAME;
			
				xspeed1<= 0;
				yspeed1<= 0;
				
				xspeed2<= 0;
				yspeed2<= 0;
				
				xspeed3<= 0;
				yspeed3<= 0;
				
				xspeed4<= 0;
				yspeed4<= 0;
				
				xspeed5<= 0;
				yspeed5<= 0;
			end
			
			MOVING: begin
				// Update state
				if (reset) state <= START_GAME;
				else if (ball1_pocketed) state <= SCRATCH;
				else if (done_fric_all) state <= DONE_ROUND;
			
				// Update ball positions
				if (!ball1_pocketed) begin
					x1 <= x1 + xspeed1_prev;
					y1 <= y1 + yspeed1_prev;
				end
				if (!ball2_pocketed) begin
					x2 <= x2 + xspeed2_prev;
					y2 <= y2 + yspeed2_prev;
				end
				if (!ball3_pocketed) begin
					x3 <= x3 + xspeed3_prev;
					y3 <= y3 + yspeed3_prev;
				end
				if (!ball4_pocketed) begin
					x4 <= x4 + xspeed4_prev;
					y4 <= y4 + yspeed4_prev;
				end
				if (!ball5_pocketed) begin
					x5 <= x5 + xspeed5_prev;
					y5 <= y5 + yspeed5_prev;
				end
				
				// Wall Collisions
				// Wall - ball 1
				if (!ball1_pocketed) begin
					if (wall_hit1 == HORIZ_HIT) begin
						xspeed1<= xspeed1_wall;
						yspeed1<= yspeed1_prev;
					end
					else if (wall_hit1 == VERT_HIT) begin
						xspeed1<= xspeed1_prev;
						yspeed1<= yspeed1_wall;
					end
				end
					
				// Wall - ball 2
				if (!ball2_pocketed) begin
					if (wall_hit2 == HORIZ_HIT) begin
						xspeed2<= xspeed2_wall;
						yspeed2<= yspeed2_prev;
					end
					else if (wall_hit2 == VERT_HIT) begin
						xspeed2<= xspeed2_prev;
						yspeed2<= yspeed2_wall;
					end
				end
					
				// Wall - ball 3
				if (!ball3_pocketed) begin
					if (wall_hit3 == HORIZ_HIT) begin
						xspeed3<= xspeed3_wall;
						yspeed3<= yspeed3_prev;
					end
					else if (wall_hit3 == VERT_HIT) begin
						xspeed3<= xspeed3_prev;
						yspeed3<= yspeed3_wall;
					end
				end

				// Wall - ball 4
				if (!ball4_pocketed) begin
					if (wall_hit4 == HORIZ_HIT) begin
						xspeed4<= xspeed4_wall;
						yspeed4<= yspeed4_prev;
					end
					else if (wall_hit4 == VERT_HIT) begin
						xspeed4<= xspeed4_prev;
						yspeed4<= yspeed4_wall;
					end
				end

				// Wall - ball 5
				if (!ball5_pocketed) begin
					if (wall_hit5 == HORIZ_HIT) begin
						xspeed5<= xspeed5_wall;
						yspeed5<= yspeed5_prev;
					end
					else if (wall_hit5 == VERT_HIT) begin
						xspeed5<= xspeed5_prev;
						yspeed5<= yspeed5_wall;
					end
				end

					
				// Ball collisions
				// Ball 1 and 2
				if (!(ball1_pocketed || ball2_pocketed || wall_hit1 || wall_hit2)) begin
					if (coll_1_2) begin
						xspeed1<= xspeed1_coll_1_2;
						yspeed1<= yspeed1_coll_1_2;
						xspeed2<= xspeed2_coll_1_2;
						yspeed2<= yspeed2_coll_1_2;
					end
				end
				
				// Ball 1 and 3
				if (!(ball1_pocketed || ball3_pocketed || wall_hit1 || wall_hit3)) begin
					if (coll_1_3) begin
						xspeed1<= xspeed1_coll_1_3;
						yspeed1<= yspeed1_coll_1_3;
						xspeed3<= xspeed3_coll_1_3;
						yspeed3<= yspeed3_coll_1_3;
					end
				end
				
				// Ball 1 and 4
				if (!(ball1_pocketed || ball4_pocketed || wall_hit1 || wall_hit4)) begin
					if (coll_1_4) begin
						xspeed1<= xspeed1_coll_1_4;
						yspeed1<= yspeed1_coll_1_4;
						xspeed4<= xspeed4_coll_1_4;
						yspeed4<= yspeed4_coll_1_4;
					end
				end
				
				// Ball 1 and 5
				if (!(ball1_pocketed || ball5_pocketed || wall_hit1 || wall_hit5)) begin
					if (coll_1_5) begin
						xspeed1<= xspeed1_coll_1_5;
						yspeed1<= yspeed1_coll_1_5;
						xspeed5<= xspeed5_coll_1_5;
						yspeed5<= yspeed5_coll_1_5;
					end
				end
				
				// Ball 2 and 3
				if (!(ball2_pocketed || ball3_pocketed || wall_hit2 || wall_hit3)) begin	
					if (coll_2_3) begin
						xspeed2<= xspeed2_coll_2_3;
						yspeed2<= yspeed2_coll_2_3;
						xspeed3<= xspeed3_coll_2_3;
						yspeed3<= yspeed3_coll_2_3;
					end
				end
				
				// Ball 2 and 4
				if (!(ball2_pocketed || ball4_pocketed || wall_hit2 || wall_hit4)) begin	
					if (coll_2_4) begin
						xspeed2<= xspeed2_coll_2_4;
						yspeed2<= yspeed2_coll_2_4;
						xspeed4<= xspeed4_coll_2_4;
						yspeed4<= yspeed4_coll_2_4;
					end
				end

				// Ball 2 and 5
				if (!(ball2_pocketed || ball5_pocketed || wall_hit2 || wall_hit5)) begin	
					if (coll_2_5) begin
						xspeed2<= xspeed2_coll_2_5;
						yspeed2<= yspeed2_coll_2_5;
						xspeed5<= xspeed5_coll_2_5;
						yspeed5<= yspeed5_coll_2_5;
					end
				end

				// Ball 3 and 4
				if (!(ball3_pocketed || ball4_pocketed || wall_hit3 || wall_hit4)) begin	
					if (coll_3_4) begin
						xspeed3<= xspeed3_coll_3_4;
						yspeed3<= yspeed3_coll_3_4;
						xspeed4<= xspeed4_coll_3_4;
						yspeed4<= yspeed4_coll_3_4;
					end
				end

				// Ball 3 and 5
				if (!(ball3_pocketed || ball5_pocketed || wall_hit3 || wall_hit5)) begin	
					if (coll_3_5) begin
						xspeed3<= xspeed3_coll_3_5;
						yspeed3<= yspeed3_coll_3_5;
						xspeed5<= xspeed5_coll_3_5;
						yspeed5<= yspeed5_coll_3_5;
					end
				end

				// Ball 4 and 5
				if (!(ball4_pocketed || ball5_pocketed || wall_hit4 || wall_hit5)) begin	
					if (coll_4_5) begin
						xspeed4<= xspeed4_coll_4_5;
						yspeed4<= yspeed4_coll_4_5;
						xspeed5<= xspeed5_coll_4_5;
						yspeed5<= yspeed5_coll_4_5;
					end
				end

				// Cue and white ball collision
				if (!ball1_pocketed && cue_active_r && cue_hit) begin   //Currently ball 1 is the white ball
					xspeed1<= xspeed1_cue;
					yspeed1<= yspeed1_cue;
					cue_active_r <= 0;
				end
				
				//Pockets
				// Ball 2
				if (ball2_pocketed) begin
					xspeed2 <= 0;
					yspeed2 <= 0;
					x2 <= 11'd2000;
					y2 <= 11'd1000;
				end
				
				// Ball 3
				if (ball3_pocketed) begin
					xspeed3 <= 0;
					yspeed3 <= 0;
					x3 <= 11'd2000;
					y3 <= 11'd1500;
				end
				
				// Ball 4
				if (ball4_pocketed) begin
					xspeed4 <= 0;
					yspeed4 <= 0;
					x4 <= 11'd2000;
					y4 <= 11'd1500;
				end
				
				// Ball 5
				if (ball5_pocketed) begin
					xspeed5 <= 0;
					yspeed5 <= 0;
					x5 <= 11'd1300;
					y5 <= 11'd1300;
				end
				
				// Reduce the speeds for friction
				// Ball 1
				if (!cue_hit && !coll_1_2 && !coll_1_3 && !coll_1_4 && !coll_1_5 &&
					wall_hit1==0 && !ball1_pocketed) begin
					xspeed1<= xspeed1_prev;
					yspeed1<= yspeed1_prev;
				end
				
				// Ball 2
				if (!coll_1_2 && !coll_2_3 && !coll_2_4 && !coll_2_5 && wall_hit2==0 && !ball2_pocketed) begin
					xspeed2<= xspeed2_prev;
					yspeed2<= yspeed2_prev;
				end
				
				// Ball 3
				if (!coll_1_3 && !coll_2_3 && !coll_3_4 && !coll_3_5 && wall_hit3==0 && !ball3_pocketed) begin
					xspeed3<= xspeed3_prev;
					yspeed3<= yspeed3_prev;
				end
				
				// Ball 4
				if (!coll_1_4 && !coll_2_4 && !coll_3_4 && !coll_4_5 && wall_hit4==0 && !ball4_pocketed) begin
					xspeed4<= xspeed4_prev;
					yspeed4<= yspeed4_prev;
				end
				
				// Ball 5
				if (!coll_1_5 && !coll_2_5 && !coll_3_5 && !coll_4_5 && wall_hit5==0 && !ball5_pocketed) begin
					xspeed5<= xspeed5_prev;
					yspeed5<= yspeed5_prev;					
				end
			end
		endcase
	end
		
	// Update position and speed
	// Ball 1
	assign new_x1 = x1;
	assign new_y1 = y1;
	assign new_xspeed1 = (xspeed1>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
		: (xspeed1<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : xspeed1;
	assign new_yspeed1 = (yspeed1>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
		: (yspeed1<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : yspeed1;

	// Ball 2
	assign new_x2 = x2;
	assign new_y2 = y2;
	assign new_xspeed2 = (xspeed2>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
		: (xspeed2<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : xspeed2;
	assign new_yspeed2 = (yspeed2>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
		: (yspeed2<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : yspeed2;

	// Ball 3
	assign new_x3 = x3;
	assign new_y3 = y3;
	assign new_xspeed3 = (xspeed3>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
		: (xspeed3<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : xspeed3;
	assign new_yspeed3 = (yspeed3>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
		: (yspeed3<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : yspeed3;

	// Ball 4
	assign new_x4 = x4;
	assign new_y4 = y4;
	assign new_xspeed4 = (xspeed4>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
		: (xspeed4<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : xspeed4;
	assign new_yspeed4 = (yspeed4>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
		: (yspeed4<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : yspeed4;

	// Ball 5
	assign new_x5 = x5;
	assign new_y5 = y5;
	assign new_xspeed5 = (xspeed5>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
		: (xspeed5<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : xspeed5;
	assign new_yspeed5 = (yspeed5>MAX_BALL_SPEED) ? MAX_BALL_SPEED 
		: (yspeed5<-MAX_BALL_SPEED) ? -MAX_BALL_SPEED : yspeed5;
 
endmodule 
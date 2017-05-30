`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:37:11 11/28/2016 
// Design Name: 
// Module Name:    game_fsm 
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
module game_fsm(clk,game_state,is_bright,hcount,vcount,calib_done,
					done_fric_all,cue_hit,reset,pocket,
					player_turn,stripes_pts,solid_pts,winner);
	input clk,is_bright,reset,pocket;
	input [10:0] hcount;
	input [10:0] vcount;
	input done_fric_all,cue_hit;
	input [3:0] stripes_pts, solid_pts;
	input calib_done;
	output [3:0] game_state;
	output [1:0] player_turn, winner;

	// states
	parameter CALIBRATION = 0;
	parameter TRACK_CUE_STRIPES = 1;
	parameter MOVE_BALLS_STRIPES = 2;
	parameter TRACK_CUE_SOLID = 3;
	parameter MOVE_BALLS_SOLID = 4;
	parameter WIN = 5;
	parameter START_GAME = 6;
	reg [3:0] state = CALIBRATION;
	assign game_state = state;
	
	// turns
	parameter STRIPES = 1;
	parameter SOLID = 2;
	assign player_turn = (game_state==TRACK_CUE_STRIPES || game_state==MOVE_BALLS_STRIPES)
		? STRIPES : (game_state==TRACK_CUE_SOLID || game_state==MOVE_BALLS_SOLID)
		? SOLID : 0;
		
	// points
	parameter MAX_PTS = 2;
	reg [3:0] stripes_pts_reg, solid_pts_reg;
	reg winner_reg = 0;
	assign winner = winner_reg;
		
	
	always @(posedge clk) begin	
		case (state)
			CALIBRATION: begin
				if (calib_done) state <= TRACK_CUE_STRIPES;
			end
			
			START_GAME: begin
				winner_reg <= 0;
				stripes_pts_reg <= 0;
				solid_pts_reg <= 0;
				state <= TRACK_CUE_STRIPES;
			end
			
			TRACK_CUE_STRIPES: begin
				stripes_pts_reg <= stripes_pts;
				solid_pts_reg <= solid_pts;
				if (reset) state <= START_GAME;
				else if (cue_hit) state <= MOVE_BALLS_STRIPES;
			end
			
			MOVE_BALLS_STRIPES: begin
				if (reset) state <= START_GAME;
				else if (done_fric_all && stripes_pts == MAX_PTS) state <= WIN;
				else if (done_fric_all && stripes_pts>stripes_pts_reg) state <= TRACK_CUE_STRIPES;
				else if (done_fric_all) state <= TRACK_CUE_SOLID;
			end
			
			TRACK_CUE_SOLID: begin
				stripes_pts_reg <= stripes_pts;
				solid_pts_reg <= solid_pts;
				if (reset) state <= START_GAME;
				else if (cue_hit) state <= MOVE_BALLS_SOLID;
			end
			
			MOVE_BALLS_SOLID: begin
				if (reset) state <= START_GAME;
				else if (done_fric_all && solid_pts == MAX_PTS) state <= WIN;
				else if (done_fric_all && solid_pts>solid_pts_reg) state <= TRACK_CUE_SOLID;
				else if (done_fric_all) state <= TRACK_CUE_STRIPES;
			end
			
			WIN: begin
				if (reset) state <= START_GAME;
				else if (solid_pts == MAX_PTS)
					winner_reg <= SOLID;
				else if (stripes_pts == MAX_PTS)
					winner_reg <= STRIPES;
			end
		endcase
	end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:47:46 11/28/2016 
// Design Name: 
// Module Name:    pool_screen 
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

module pool_game (
	// Inputs
	input debug,
   input vclock,	// 65MHz clock
   input reset,		// 1 to initialize module
   input up,		// 1 when paddle should move up
   input down,  	// 1 when paddle should move down
	input left,		//1 when right paddle should move up
	input right,	//1 when right paddle should move up
	input signed [10:0] x_cue_front, x_cue_back, x_cue_speed,
	input signed [10:0] y_cue_front, y_cue_back, y_cue_speed,
   input [3:0] pspeed,  // ball speed in pixels/tick 
   input [10:0] hcount,	// horizontal index of current pixel (0..1023)
   input [10:0] 	vcount, // vertical index of current pixel (0..767)
   input hsync,		// XVGA horizontal sync signal (active low)
   input vsync,		// XVGA vertical sync signal (active low)
   input blank,		// XVGA blanking (1 means output black pixel)
	input signed [10:0] pixel_speed, // speed of cue movement
	input [3:0] game_state,
 	
	// Outputs
   output phsync,	// pong game's horizontal sync
   output pvsync,	// pong game's vertical sync
   output pblank,	// pong game's blanking
   output [23:0] pixel,	// pong game's pixel  // r=23:16, g=15:8, b=7:0 
	output coll_cue_out, // 1 when ball1 and cue collide
	output pocket, // 1 when ball is pocketed
	output done_fric_all, // 1 when all balls stop moving
	
	// Debugging
	output signed [10:0] pixel_speed_out,
	output [7:0] fric_count,
	output signed [10:0] fric_abs_out_x, fric_abs_out_y,
	output [2:0] fric_state1_out, fric_state2_out, fric_state3_out,
	output signed [10:0] abs_xspeed1,
	output signed [10:0] abs_yspeed1,
	output [3:0] stripes_pts, solid_pts,
	output cue_active_r_out,
	output ball1_pocket_out,ball2_pocket_out,ball3_pocket_out,ball4_pocket_out,
	output coll_1_2_out,coll_1_3_out,coll_1_4_out);
	
   
	// Parameters
	parameter BACKGROUND = 24'h00_64_00;
	parameter HOR_BITS = 11;
	parameter VERT_BITS = 10;
	parameter TABLE_WIDTH = 800;
	parameter TABLE_HEIGHT = 600;
	parameter POCKET_MARGIN = 10;
	parameter POCKET_RADIUS = 32;
	parameter POCKET_RADIUS_SQ = 1024;

   assign phsync = hsync;
   assign pvsync = vsync;
   assign pblank = blank;
	
	// Ball 1
	wire [23:0] ball_pixel1;
	wire signed [10:0] x_ball1;
	wire signed [10:0] y_ball1;
	wire signed [10:0] xspeed1, new_xspeed1, new_xspeed1_coll_cue,new_xspeed1_wall, 
		new_xspeed1_coll_1_2, new_xspeed1_coll_1_3, new_xspeed1_coll_1_4, new_xspeed1_coll_1_5;
	wire signed [10:0] yspeed1, new_yspeed1, new_yspeed1_coll_cue, new_yspeed1_wall, 
		new_yspeed1_coll_1_2, new_yspeed1_coll_1_3, new_yspeed1_coll_1_4, new_yspeed1_coll_1_5;
	wire signed [10:0] xspeed1_fric;
	wire signed [10:0] yspeed1_fric;
	wire [2:0] fric_state1;
	assign fric_state1_out = fric_state1;
	wire [1:0] wall_coll1;
	wire ball1_pocket;
	assign ball1_pocket_out = ball1_pocket;
	
	// Ball 2
	wire [23:0] ball_pixel2;
	wire signed [10:0] x_ball2;
	wire signed [10:0] y_ball2;
	wire signed [10:0] xspeed2, new_xspeed2, new_xspeed2_wall, new_xspeed2_coll_1_2, 
		new_xspeed2_coll_2_3, new_xspeed2_coll_2_4, new_xspeed2_coll_2_5;
	wire signed [10:0] yspeed2, new_yspeed2, new_yspeed2_wall, new_yspeed2_coll_1_2, 
		new_yspeed2_coll_2_3, new_yspeed2_coll_2_4, new_yspeed2_coll_2_5;
	wire signed [10:0] xspeed2_fric;
	wire signed [10:0] yspeed2_fric;
	wire [2:0] fric_state2;
	assign fric_state2_out = fric_state2;
	wire [1:0] wall_coll2;
	wire ball2_pocket;
	assign ball2_pocket_out = ball2_pocket;
	
	// Ball 3
	wire [23:0] ball_pixel3;
	wire signed [10:0] x_ball3;
	wire signed [10:0] y_ball3;
	wire signed [10:0] xspeed3, new_xspeed3, new_xspeed3_wall, new_xspeed3_coll_1_3, 
		new_xspeed3_coll_2_3, new_xspeed3_coll_3_4, new_xspeed3_coll_3_5;
	wire signed [10:0] yspeed3, new_yspeed3, new_yspeed3_wall, new_yspeed3_coll_1_3, 
		new_yspeed3_coll_2_3, new_yspeed3_coll_3_4, new_yspeed3_coll_3_5;
	wire signed [10:0] xspeed3_fric;
	wire signed [10:0] yspeed3_fric;
	wire [2:0] fric_state3;
	assign fric_state3_out = fric_state3;	
	wire [1:0] wall_coll3;
	wire ball3_pocket;
	assign ball3_pocket_out = ball3_pocket;
	
	// Ball 4
	wire [23:0] ball_pixel4;
	wire signed [10:0] x_ball4;
	wire signed [10:0] y_ball4;
	wire signed [10:0] xspeed4, new_xspeed4, new_xspeed4_wall, new_xspeed4_coll_1_4, 
		new_xspeed4_coll_2_4, new_xspeed4_coll_3_4, new_xspeed4_coll_4_5;
	wire signed [10:0] yspeed4, new_yspeed4, new_yspeed4_wall, new_yspeed4_coll_1_4, 
		new_yspeed4_coll_2_4, new_yspeed4_coll_3_4, new_yspeed4_coll_4_5;
	wire signed [10:0] xspeed4_fric;
	wire signed [10:0] yspeed4_fric;
	wire [2:0] fric_state4;
	assign fric_state4_out = fric_state4;
	wire [1:0] wall_coll4;
	wire ball4_pocket;
	assign ball4_pocket_out = ball4_pocket;
	
	// Ball 5
	wire [23:0] ball_pixel5;
	wire signed [10:0] x_ball5;
	wire signed [10:0] y_ball5;
	wire signed [10:0] xspeed5, new_xspeed5, new_xspeed5_wall, new_xspeed5_coll_1_5, 
		new_xspeed5_coll_2_5, new_xspeed5_coll_3_5, new_xspeed5_coll_4_5;
	wire signed [10:0] yspeed5, new_yspeed5, new_yspeed5_wall, new_yspeed5_coll_1_5, 
		new_yspeed5_coll_2_5, new_yspeed5_coll_3_5, new_yspeed5_coll_4_5;
	wire signed [10:0] xspeed5_fric;
	wire signed [10:0] yspeed5_fric;
	wire [2:0] fric_state5;
	wire [1:0] wall_coll5;
	wire ball5_pocket;

	// Friction
	parameter NO_CUE_HIT = 0;
	parameter CUE_HIT = 1;
	parameter DONE_MOVING = 2;
	assign done_fric_all = (fric_state1 == DONE_MOVING) &&
		(fric_state2 == NO_CUE_HIT || fric_state2 == DONE_MOVING) &&
		(fric_state3 == NO_CUE_HIT || fric_state3 == DONE_MOVING) &&
		(fric_state4 == NO_CUE_HIT || fric_state4 == DONE_MOVING) &&
		(fric_state5 == NO_CUE_HIT || fric_state5 == DONE_MOVING);
		
	// Collisions		
	wire coll_1_2, coll_1_3, coll_1_4, coll_2_3, coll_2_4,
		coll_1_5, coll_2_5, coll_3_5, coll_4_5;
	assign coll_1_2_out = coll_1_2;
	assign coll_1_3_out = coll_1_3;
	assign coll_1_4_out = coll_1_4;

	// Pocket and points
	assign pocket = 1'b0;	
	assign stripes_pts = ball2_pocket + ball4_pocket;
	assign solid_pts = ball3_pocket + ball5_pocket;
	
	// Cue
	wire coll_cue, cue_active;
	assign coll_cue_out = coll_cue;
	wire signed [10:0] x_cue, xspeed_cue;
	wire signed [10:0] y_cue, yspeed_cue;

	assign abs_xspeed1 = (new_xspeed1 < 0) ? -new_xspeed1 : new_xspeed1;
	assign abs_yspeed1 = (new_yspeed1 < 0) ? -new_yspeed1 : new_yspeed1;

	
	// Position handler	
	position_handler pos_hand(
		.vsync(vsync),
		.reset(reset),.done_fric_all(done_fric_all),
		// Previous speeds
		.xspeed1_prev(xspeed1_fric),.yspeed1_prev(yspeed1_fric), 
		.xspeed2_prev(xspeed2_fric),.yspeed2_prev(yspeed2_fric),
		.xspeed3_prev(xspeed3_fric),.yspeed3_prev(yspeed3_fric),
		.xspeed4_prev(xspeed4_fric),.yspeed4_prev(yspeed4_fric),
		.xspeed5_prev(xspeed5_fric),.yspeed5_prev(yspeed5_fric),
		//Ball 1 Speeds
		.xspeed1_wall(new_xspeed1_wall), .xspeed1_coll_1_2(new_xspeed1_coll_1_2), .xspeed1_coll_1_3(new_xspeed1_coll_1_3), .xspeed1_coll_1_4(new_xspeed1_coll_1_4),
		.xspeed1_coll_1_5(new_xspeed1_coll_1_5),
		.yspeed1_wall(new_yspeed1_wall), .yspeed1_coll_1_2(new_yspeed1_coll_1_2), .yspeed1_coll_1_3(new_yspeed1_coll_1_3), .yspeed1_coll_1_4(new_yspeed1_coll_1_4),
		.yspeed1_coll_1_5(new_yspeed1_coll_1_5),
		//Ball 2 Speeds
		.xspeed2_wall(new_xspeed2_wall), .xspeed2_coll_1_2(new_xspeed2_coll_1_2), .xspeed2_coll_2_3(new_xspeed2_coll_2_3), .xspeed2_coll_2_4(new_xspeed2_coll_2_4),
		.xspeed2_coll_2_5(new_xspeed2_coll_2_5),
		.yspeed2_wall(new_yspeed2_wall), .yspeed2_coll_1_2(new_yspeed2_coll_1_2), .yspeed2_coll_2_3(new_yspeed2_coll_2_3), .yspeed2_coll_2_4(new_yspeed2_coll_2_4),
		.yspeed2_coll_2_5(new_yspeed2_coll_2_5),
		//Ball 3 Speeds
		.xspeed3_wall(new_xspeed3_wall), .xspeed3_coll_1_3(new_xspeed3_coll_1_3), .xspeed3_coll_2_3(new_xspeed3_coll_2_3), .xspeed3_coll_3_4(new_xspeed3_coll_3_4),
		.xspeed3_coll_3_5(new_xspeed3_coll_3_5),
		.yspeed3_wall(new_yspeed3_wall), .yspeed3_coll_1_3(new_yspeed3_coll_1_3), .yspeed3_coll_2_3(new_yspeed3_coll_2_3), .yspeed3_coll_3_4(new_yspeed3_coll_3_4),
		.yspeed3_coll_3_5(new_yspeed3_coll_3_5),
		//Ball 4 Speeds
		.xspeed4_wall(new_xspeed4_wall), .xspeed4_coll_1_4(new_xspeed4_coll_1_4), .xspeed4_coll_2_4(new_xspeed4_coll_2_4), .xspeed4_coll_3_4(new_xspeed4_coll_3_4),
		.xspeed4_coll_4_5(new_xspeed4_coll_4_5),
		.yspeed4_wall(new_yspeed4_wall), .yspeed4_coll_1_4(new_yspeed4_coll_1_4), .yspeed4_coll_2_4(new_yspeed4_coll_2_4), .yspeed4_coll_3_4(new_yspeed4_coll_3_4),
		.yspeed4_coll_4_5(new_yspeed4_coll_4_5),
		//Ball 5 Speeds
		.xspeed5_wall(new_xspeed5_wall), .xspeed5_coll_1_5(new_xspeed5_coll_1_5), .xspeed5_coll_2_5(new_xspeed5_coll_2_5), .xspeed5_coll_3_5(new_xspeed5_coll_3_5),
		.xspeed5_coll_4_5(new_xspeed5_coll_4_5),
		.yspeed5_wall(new_yspeed5_wall), .yspeed5_coll_1_5(new_yspeed5_coll_1_5), .yspeed5_coll_2_5(new_yspeed5_coll_2_5), .yspeed5_coll_3_5(new_yspeed5_coll_3_5),
		.yspeed5_coll_4_5(new_yspeed5_coll_4_5),
		//Cue Speeds
		.cue_hit(coll_cue),.cue_active(cue_active),
		.xspeed1_cue(new_xspeed1_coll_cue), .yspeed1_cue(new_yspeed1_coll_cue),
		//Collisions
		.coll_1_2(coll_1_2),.coll_1_3(coll_1_3), .coll_1_4(coll_1_4), .coll_2_3(coll_2_3), .coll_2_4(coll_2_4), .coll_3_4(coll_3_4),
		.coll_1_5(coll_1_5),.coll_2_5(coll_2_5),.coll_3_5(coll_3_5),.coll_4_5(coll_4_5),
		.wall_hit1(wall_coll1),.wall_hit2(wall_coll2),.wall_hit3(wall_coll3), .wall_hit4(wall_coll4),.wall_hit5(wall_coll5),
		//Outputs
		.new_x1(x_ball1), .new_x2(x_ball2), .new_x3(x_ball3), .new_x4(x_ball4), .new_x5(x_ball5),
		.new_y1(y_ball1), .new_y2(y_ball2), .new_y3(y_ball3), .new_y4(y_ball4), .new_y5(y_ball5),
		.ball1_pocketed(ball1_pocket), .ball2_pocketed(ball2_pocket), .ball3_pocketed(ball3_pocket), 
		.ball4_pocketed(ball4_pocket),.ball5_pocketed(ball5_pocket),
		.new_xspeed1(new_xspeed1), .new_xspeed2(new_xspeed2), .new_xspeed3(new_xspeed3), .new_xspeed4(new_xspeed4), .new_xspeed5(new_xspeed5),
		.new_yspeed1(new_yspeed1), .new_yspeed2(new_yspeed2), .new_yspeed3(new_yspeed3), .new_yspeed4(new_yspeed4), .new_yspeed5(new_yspeed5),
		//Debugging
		.cue_active_r_out(cue_active_r_out),
		.debug(debug));
		
	////////////////////////
	// Ball Visualization //
	////////////////////////
	parameter BLUE = 24'h4C_4C_ff;
	parameter SKY_BLUE = 24'h00_bf_ff;
	parameter WHITE = 24'hff_ff_ff;
	parameter BLACK = 24'h01_01_01;
	parameter RED = 24'hff_00_00;
	parameter DARK_RED = 24'hb0_30_60;
	parameter CUE_RADIUS = 6'd8;
	parameter CUE_RADIUS_SQ = 11'd63;
	parameter TRACK_CUE_STRIPES = 1;
	parameter TRACK_CUE_SOLID = 3;
	parameter WIN = 5;

	// Cue blob
	wire [23:0] cue_pixel;
	wire [23:0] cue_color = (game_state == TRACK_CUE_STRIPES) ? BLUE : 
		(game_state == TRACK_CUE_SOLID) ? RED : BLACK;
	ball #(.RADIUS(CUE_RADIUS),.RADIUS_SQUARED(CUE_RADIUS_SQ)) cue(
		.x(x_cue),
		.y(y_cue),
		.hcount(hcount),
		.vcount(vcount),
		.pixel(cue_pixel),
		.color(cue_color),
		.striped(1'b0));
		
	// White ball
	ball ball1(
		.x(x_ball1), 
		.y(y_ball1), 
		.hcount(hcount), 
		.vcount(vcount), 
		.pixel(ball_pixel1),
		.color(WHITE),
		.striped(1'b0));
		
	// Striped dark blue ball
	ball ball2(
		.x(x_ball2), 
		.y(y_ball2), 
		.hcount(hcount), 
		.vcount(vcount), 
		.pixel(ball_pixel2),
		.color(BLUE),
		.striped(1'b1));
		
	// Solid red ball
	ball ball3(
		.x(x_ball3), 
		.y(y_ball3), 
		.hcount(hcount), 
		.vcount(vcount), 
		.pixel(ball_pixel3),
		.color(RED),
		.striped(1'b0));
		
	//Striped sky blue Ball
	ball ball4(
		.x(x_ball4),
		.y(y_ball4), 
		.hcount(hcount),
		.vcount(vcount), 
		.pixel(ball_pixel4),
		.color(SKY_BLUE),
		.striped(1'b1));

	//Solid dark red Ball
	ball ball5(
		.x(x_ball5),
		.y(y_ball5), 
		.hcount(hcount),
		.vcount(vcount), 
		.pixel(ball_pixel5),
		.color(DARK_RED),
		.striped(1'b0));

  // Win Screen Ball
	wire [23:0] ball_pixelWin;
	ball ballWin(
		.x(11'd584),
		.y(11'd240), 
		.hcount(hcount),
		.vcount(vcount), 
		.pixel(ball_pixelWin),
		.color(BLUE),
		.striped(1'b1));

	//////////////////////////
	// Pocket Visualization //
	//////////////////////////

	// Middle top pocket
	parameter X_POCKET0 = TABLE_WIDTH/2;
	parameter Y_POCKET0 = POCKET_MARGIN;
	wire [23:0] pocket0_pixel;
	ball #(.RADIUS(POCKET_RADIUS),.RADIUS_SQUARED(POCKET_RADIUS_SQ)) pocket0( 
		.x(X_POCKET0), .y(Y_POCKET0),
		.hcount(hcount), .vcount(vcount), 
		.pixel(pocket0_pixel),
		.color(BLACK), .striped (1'b0));
		
	// Top left pocket
	parameter X_POCKET1 = POCKET_MARGIN;
	parameter Y_POCKET1 = POCKET_MARGIN;
	wire [23:0] pocket1_pixel;
	ball #(.RADIUS(POCKET_RADIUS),.RADIUS_SQUARED(POCKET_RADIUS_SQ)) pocket1( 
		.x(X_POCKET1), .y(Y_POCKET1),
		.hcount(hcount), .vcount(vcount), 
		.pixel(pocket1_pixel),
		.color(BLACK), .striped (1'b0));	
		
	// Top right pocket
	parameter X_POCKET2 = TABLE_WIDTH - POCKET_MARGIN;
	parameter Y_POCKET2 = POCKET_MARGIN;
	wire [23:0] pocket2_pixel;
	ball #(.RADIUS(POCKET_RADIUS),.RADIUS_SQUARED(POCKET_RADIUS_SQ)) pocket2( 
		.x(X_POCKET2), .y(Y_POCKET2),
		.hcount(hcount), .vcount(vcount), 
		.pixel(pocket2_pixel),
		.color(BLACK), .striped (1'b0));	
		
	// Bottom left pocket
	parameter X_POCKET3 = POCKET_MARGIN;
	parameter Y_POCKET3 = TABLE_HEIGHT - POCKET_MARGIN;
	wire [23:0] pocket3_pixel;
	ball #(.RADIUS(POCKET_RADIUS),.RADIUS_SQUARED(POCKET_RADIUS_SQ)) pocket3( 
		.x(X_POCKET3), .y(Y_POCKET3),
		.hcount(hcount), .vcount(vcount), 
		.pixel(pocket3_pixel),
		.color(BLACK), .striped (1'b0));	
		
	// Bottom right pocket
	parameter X_POCKET4 = TABLE_WIDTH - POCKET_MARGIN;
	parameter Y_POCKET4 = TABLE_HEIGHT - POCKET_MARGIN;
	wire [23:0] pocket4_pixel;
	ball #(.RADIUS(POCKET_RADIUS),.RADIUS_SQUARED(POCKET_RADIUS_SQ)) pocket4( 
		.x(X_POCKET4), .y(Y_POCKET4),
		.hcount(hcount), .vcount(vcount), 
		.pixel(pocket4_pixel),
		.color(BLACK), .striped (1'b0));	

	// Middle bottom pocket
	wire [10:0] x_pocket5 = (debug) ? 600 : TABLE_WIDTH/2;
	wire [10:0] y_pocket5 = (debug) ? TABLE_HEIGHT/2 : TABLE_HEIGHT - POCKET_MARGIN;
	wire [23:0] pocket5_pixel;
	ball #(.RADIUS(POCKET_RADIUS),.RADIUS_SQUARED(POCKET_RADIUS_SQ)) pocket5( 
		.x(x_pocket5), .y(y_pocket5),
		.hcount(hcount), .vcount(vcount), 
		.pixel(pocket5_pixel),
		.color(BLACK), .striped (1'b0));	

	///////////////////////////
	// Cue Collision Checker //
	///////////////////////////
		
	cue_collision_checker cue_check(
		.vsync(vsync), .reset(reset), .done_fric_all(done_fric_all),
		.x1(x_ball1), .y1(y_ball1),
		.xspeed1(xspeed1_fric), .yspeed1(yspeed1_fric),
		.x2(x_cue), .y2(y_cue),
		.xspeed2(xspeed_cue), .yspeed2(yspeed_cue),
		.collided(coll_cue), .cue_active(cue_active),
		.new_xspeed1(new_xspeed1_coll_cue), .new_yspeed1(new_yspeed1_coll_cue));
		
	
	/////////////////////////////
	// Wall Collision Checkers //
	/////////////////////////////
	
	// Wall and Ball 1
	wall_collision_checker #(.TABLE_WIDTH(TABLE_WIDTH),.TABLE_HEIGHT(TABLE_HEIGHT))
	wall_check_1(
		.vsync(vsync),
		.x(x_ball1), 
		.y(y_ball1), 
		.xspeed(xspeed1_fric), 
		.yspeed(yspeed1_fric), 
		.collision(wall_coll1),
		.new_xspeed(new_xspeed1_wall),
		.new_yspeed(new_yspeed1_wall),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	// Wall and Ball 2
	wall_collision_checker #(.TABLE_WIDTH(TABLE_WIDTH),.TABLE_HEIGHT(TABLE_HEIGHT))
	wall_check_2(
		.vsync(vsync), 
		.x(x_ball2), 
		.y(y_ball2), 
		.xspeed(xspeed2_fric), 
		.yspeed(yspeed2_fric), 
		.collision(wall_coll2),
		.new_xspeed(new_xspeed2_wall),
		.new_yspeed(new_yspeed2_wall),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	// Wall and Ball 3
	wall_collision_checker #(.TABLE_WIDTH(TABLE_WIDTH),.TABLE_HEIGHT(TABLE_HEIGHT))
	wall_check_3(
		.vsync(vsync), 
		.x(x_ball3), 
		.y(y_ball3), 
		.xspeed(xspeed3_fric), 
		.yspeed(yspeed3_fric), 
		.collision(wall_coll3),
		.new_xspeed(new_xspeed3_wall),
		.new_yspeed(new_yspeed3_wall),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
	
	// Wall and Ball 4
	wall_collision_checker #(.TABLE_WIDTH(TABLE_WIDTH),.TABLE_HEIGHT(TABLE_HEIGHT))
	wall_check_4(
		.vsync(vsync), 
		.x(x_ball4), 
		.y(y_ball4), 
		.xspeed(xspeed4_fric), 
		.yspeed(yspeed4_fric), 
		.collision(wall_coll4),
		.new_xspeed(new_xspeed4_wall),
		.new_yspeed(new_yspeed4_wall),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
	
	// Wall and Ball 5
	wall_collision_checker #(.TABLE_WIDTH(TABLE_WIDTH),.TABLE_HEIGHT(TABLE_HEIGHT))
	wall_check_5(
		.vsync(vsync), 
		.x(x_ball5), 
		.y(y_ball5), 
		.xspeed(xspeed5_fric), 
		.yspeed(yspeed5_fric), 
		.collision(wall_coll5),
		.new_xspeed(new_xspeed5_wall),
		.new_yspeed(new_yspeed5_wall),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
	
	
	/////////////////////////////
	// Ball Collision Checkers //
	/////////////////////////////

	// Ball 1 and 2
	ball_collision_checker coll_check_1_2(
		.vsync(vsync),
		.x1(x_ball1), .y1(y_ball1), 
		.xspeed1(xspeed1_fric), .yspeed1(yspeed1_fric),
		.x2(x_ball2), .y2(y_ball2), 
		.xspeed2(xspeed2_fric), .yspeed2(yspeed2_fric),
		.collided(coll_1_2),
		.new_xspeed1(new_xspeed1_coll_1_2), .new_yspeed1(new_yspeed1_coll_1_2),
		.new_xspeed2(new_xspeed2_coll_1_2), .new_yspeed2(new_yspeed2_coll_1_2),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	// Ball 1 and 3
	ball_collision_checker coll_check_1_3(
		.vsync(vsync),
		.x1(x_ball1), .y1(y_ball1), 
		.xspeed1(xspeed1_fric), .yspeed1(yspeed1_fric),
		.x2(x_ball3), .y2(y_ball3), 
		.xspeed2(xspeed3_fric), .yspeed2(yspeed3_fric),
		.collided(coll_1_3),
		.new_xspeed1(new_xspeed1_coll_1_3), .new_yspeed1(new_yspeed1_coll_1_3),
		.new_xspeed2(new_xspeed3_coll_1_3), .new_yspeed2(new_yspeed3_coll_1_3),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	// Ball 1 and 4
	ball_collision_checker coll_check_1_4(
		.vsync(vsync),
		.x1(x_ball1), .y1(y_ball1), 
		.xspeed1(xspeed1_fric), .yspeed1(yspeed1_fric),
		.x2(x_ball4), .y2(y_ball4), 
		.xspeed2(xspeed4_fric), .yspeed2(yspeed4_fric),
		.collided(coll_1_4),
		.new_xspeed1(new_xspeed1_coll_1_4), .new_yspeed1(new_yspeed1_coll_1_4),
		.new_xspeed2(new_xspeed4_coll_1_4), .new_yspeed2(new_yspeed4_coll_1_4),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	// Ball 1 and 5
	ball_collision_checker coll_check_1_5(
		.vsync(vsync),
		.x1(x_ball1), .y1(y_ball1), 
		.xspeed1(xspeed1_fric), .yspeed1(yspeed1_fric),
		.x2(x_ball5), .y2(y_ball5), 
		.xspeed2(xspeed5_fric), .yspeed2(yspeed5_fric),
		.collided(coll_1_5),
		.new_xspeed1(new_xspeed1_coll_1_5), .new_yspeed1(new_yspeed1_coll_1_5),
		.new_xspeed2(new_xspeed5_coll_1_5), .new_yspeed2(new_yspeed5_coll_1_5),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	// Ball 2 and 3
	ball_collision_checker coll_check_2_3(
		.vsync(vsync),
		.x1(x_ball3), .y1(y_ball3), 
		.xspeed1(xspeed3_fric), .yspeed1(yspeed3_fric),
		.x2(x_ball2), .y2(y_ball2), 
		.xspeed2(xspeed2_fric), .yspeed2(yspeed2_fric),
		.collided(coll_2_3),
		.new_xspeed1(new_xspeed3_coll_2_3), .new_yspeed1(new_yspeed3_coll_2_3),
		.new_xspeed2(new_xspeed2_coll_2_3), .new_yspeed2(new_yspeed2_coll_2_3),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	// Ball 2 and 4
	ball_collision_checker coll_check_2_4(
		.vsync(vsync),
		.x1(x_ball2), .y1(y_ball2), 
		.xspeed1(xspeed2_fric), .yspeed1(yspeed2_fric),
		.x2(x_ball4), .y2(y_ball4), 
		.xspeed2(xspeed4_fric), .yspeed2(yspeed4_fric),
		.collided(coll_2_4),
		.new_xspeed1(new_xspeed2_coll_2_4), .new_yspeed1(new_yspeed2_coll_2_4),
		.new_xspeed2(new_xspeed4_coll_2_4), .new_yspeed2(new_yspeed4_coll_2_4),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	// Ball 2 and 5
	ball_collision_checker coll_check_2_5(
		.vsync(vsync),
		.x1(x_ball2), .y1(y_ball2), 
		.xspeed1(xspeed2_fric), .yspeed1(yspeed2_fric),
		.x2(x_ball5), .y2(y_ball5), 
		.xspeed2(xspeed5_fric), .yspeed2(yspeed5_fric),
		.collided(coll_2_5),
		.new_xspeed1(new_xspeed2_coll_2_5), .new_yspeed1(new_yspeed2_coll_2_5),
		.new_xspeed2(new_xspeed5_coll_2_5), .new_yspeed2(new_yspeed5_coll_2_5),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	// Ball 3 and 4
	ball_collision_checker coll_check_3_4(
		.vsync(vsync),
		.x1(x_ball3), .y1(y_ball3), 
		.xspeed1(xspeed3_fric), .yspeed1(yspeed3_fric),
		.x2(x_ball4), .y2(y_ball4), 
		.xspeed2(xspeed4_fric), .yspeed2(yspeed4_fric),
		.collided(coll_3_4),
		.new_xspeed1(new_xspeed3_coll_3_4), .new_yspeed1(new_yspeed3_coll_3_4),
		.new_xspeed2(new_xspeed4_coll_3_4), .new_yspeed2(new_yspeed4_coll_3_4),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	// Ball 3 and 5
	ball_collision_checker coll_check_3_5(
		.vsync(vsync),
		.x1(x_ball3), .y1(y_ball3), 
		.xspeed1(xspeed3_fric), .yspeed1(yspeed3_fric),
		.x2(x_ball5), .y2(y_ball5), 
		.xspeed2(xspeed5_fric), .yspeed2(yspeed5_fric),
		.collided(coll_3_5),
		.new_xspeed1(new_xspeed3_coll_3_5), .new_yspeed1(new_yspeed3_coll_3_5),
		.new_xspeed2(new_xspeed5_coll_3_5), .new_yspeed2(new_yspeed5_coll_3_5),
		.cue_hit(coll_cue),.reset(reset),.done_fric_all(done_fric_all));
		
	/////////////////////
	// Pocket Checkers //
	/////////////////////

	pocket_checker pock_check(
		.vsync(vsync), .reset(reset),
		// Pocket positions
		.x_pocket0(X_POCKET0), .x_pocket1(X_POCKET1),.x_pocket2(X_POCKET2),
		.x_pocket3(X_POCKET3),.x_pocket4(X_POCKET4),.x_pocket5(x_pocket5),
		.y_pocket0(Y_POCKET0), .y_pocket1(Y_POCKET1),.y_pocket2(Y_POCKET2),
		.y_pocket3(Y_POCKET3),.y_pocket4(Y_POCKET4),.y_pocket5(y_pocket5),
		// Ball 1
		.x1(x_ball1), .y1(y_ball1), .ball1_in(ball1_pocket), 
		// Ball 2
		.x2(x_ball2), .y2(y_ball2), .ball2_in(ball2_pocket), 
		// Ball 3
		.x3(x_ball3), .y3(y_ball3), .ball3_in(ball3_pocket), 
		// Ball 4
		.x4(x_ball4), .y4(y_ball4), .ball4_in(ball4_pocket),
		// Ball 5
		.x5(x_ball5), .y5(y_ball5), .ball5_in(ball5_pocket));
		
		
	//////////////
	// Friction //
	//////////////
	
	// Friction for Ball 1
	wire first_hit_ball1 = coll_cue;
	wire any_hit_ball1 = (coll_1_2 || coll_1_3 || coll_1_4 || coll_1_5 || wall_coll1 > 0);
	friction friction1(.clk(vsync),.xspeed(new_xspeed1),.yspeed(new_yspeed1),
		.cue_hit(first_hit_ball1),.fric_state(fric_state1),
		.xspeed_fric(xspeed1_fric),.yspeed_fric(yspeed1_fric),
		.fric_count_out(fric_count),
		.fric_abs_out_x(fric_abs_out_x),.fric_abs_out_y(fric_abs_out_y),
		.reset(reset),.done_fric_all(done_fric_all),
		.any_hit(any_hit_ball1));
		
	// Friction for Ball 2
	wire first_hit_ball2 = (coll_1_2 || coll_2_3 || coll_2_4 || coll_2_5);
	wire any_hit_ball2 = (first_hit_ball2 || wall_coll2 > 0);
	friction friction2(.clk(vsync),.xspeed(new_xspeed2),.yspeed(new_yspeed2),
		.cue_hit(first_hit_ball2),.fric_state(fric_state2),
		.xspeed_fric(xspeed2_fric),.yspeed_fric(yspeed2_fric),
		.reset(reset),.done_fric_all(done_fric_all),
		.any_hit(any_hit_ball2));
		
	// Friction for Ball 3
	wire first_hit_ball3 = (coll_1_3 || coll_2_3 || coll_3_4 || coll_3_5);
	wire any_hit_ball3 = (first_hit_ball3 || wall_coll3 > 0);
	friction friction3(.clk(vsync),.xspeed(new_xspeed3),.yspeed(new_yspeed3),
		.cue_hit(first_hit_ball3),.fric_state(fric_state3),
		.xspeed_fric(xspeed3_fric),.yspeed_fric(yspeed3_fric),
		.reset(reset),.done_fric_all(done_fric_all),
		.any_hit(any_hit_ball3));
	
	// Friction for Ball 4
	wire first_hit_ball4 = (coll_1_4 || coll_2_4 || coll_3_4 || coll_4_5);
	wire any_hit_ball4 = (first_hit_ball4 || wall_coll4 > 0);
	friction friction4(.clk(vsync),.xspeed(new_xspeed4),.yspeed(new_yspeed4),
		.cue_hit(first_hit_ball4),.fric_state(fric_state4),
		.xspeed_fric(xspeed4_fric),.yspeed_fric(yspeed4_fric),
		.reset(reset),.done_fric_all(done_fric_all),
		.any_hit(any_hit_ball4));
	
	// Friction for Ball 5
	wire first_hit_ball5 = (coll_1_5 || coll_2_5 || coll_3_5 || coll_4_5);
	wire any_hit_ball5 = (first_hit_ball5 || wall_coll5 > 0);
	friction friction5(.clk(vsync),.xspeed(new_xspeed5),.yspeed(new_yspeed5),
		.cue_hit(first_hit_ball5),.fric_state(fric_state5),
		.xspeed_fric(xspeed5_fric),.yspeed_fric(yspeed5_fric),
		.reset(reset),.done_fric_all(done_fric_all),
		.any_hit(any_hit_ball5));

	/////////////////
	// Cue updates //
	/////////////////
	
	// Cue speed and position assignment
	reg signed [10:0] x_cue_reg = 11'd200;
	reg signed [10:0] y_cue_reg = 11'd500;
	always @(posedge vsync) begin
		if (down)
			y_cue_reg <= y_cue_reg + 4;
		else if (up)
			y_cue_reg <= y_cue_reg - 4;
		else if (left)
			x_cue_reg <= x_cue_reg - 4;
		else if (right)
			x_cue_reg <= x_cue_reg + 4;
	end
	
	// NOTE: use below for tracked cue
	assign xspeed_cue = (x_cue_speed*13) >>> 5;
	assign yspeed_cue = (y_cue_speed*13) >>> 5;
	assign y_cue = y_cue_front;
	assign x_cue = x_cue_front;

	
	// NOTE: use below for debug mode (button controlled cue)
/*	assign xspeed_cue = ((x_ball1 - x_cue) >>> 2);
	assign yspeed_cue = ((y_ball1 - y_cue) >>> 2);
	assign y_cue = y_cue_reg;
	assign x_cue = x_cue_reg; */
	

	//////////////////
	// Pixel output //
	//////////////////
	
	// Win screen
	wire [23:0] win_pixel;
	wire player_won = (stripes_pts > solid_pts) ? 1'b1 : 1'b0;
	winscreen winner(
		.hcount(hcount), .vcount(vcount),
		.winner(player_won), 
		.pixel(win_pixel));
	
	// Pool table
	wire [23:0] all_ball_pixel = ball_pixel1 + ball_pixel2 + 
		ball_pixel3 + ball_pixel4 + ball_pixel5 + cue_pixel + 
		pocket0_pixel+ pocket1_pixel+ pocket2_pixel+ pocket3_pixel+ pocket4_pixel + pocket5_pixel;
	assign pixel = (game_state == WIN) ? win_pixel + ball_pixelWin : (all_ball_pixel == 23'b0) ?  BACKGROUND : all_ball_pixel;

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:30:51 12/11/2016 
// Design Name: 
// Module Name:    winscreen 
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
module winscreen(
	input [10:0] hcount, vcount,
	input winner, //0 for player 1, 1 for player 2
	output reg [23:0] pixel
    );
	 
	 parameter TEXT_COLOR = 24'hFF_FF_FF;
	 parameter BACKGROUND = 24'h00_64_00;
	 parameter LETTER_WIDTH = 11'd64;
	 parameter LETTER_HEIGHT = 11'd128;
	 parameter LETTER_SPACE = 11'd32;
	 parameter LINE_WIDTH = 11'd16;
	 parameter WORD_SPACE = 11'd64;
	 parameter START_Y = 11'd128;
	 parameter START_X = 11'd64;
	 parameter NUM_X = START_X + LETTER_WIDTH + LETTER_SPACE;
	 parameter W_X = NUM_X + LETTER_WIDTH + WORD_SPACE;
	 parameter O_X = W_X + LETTER_WIDTH + LETTER_SPACE;
	 parameter N_X = O_X + LETTER_WIDTH + LETTER_SPACE;
	 parameter EX_X = N_X + LETTER_WIDTH + LETTER_SPACE;
	 
	 wire [23:0] all_pixels, all_pixelsP1, all_pixelsP2, p1_pixel, p2_pixel, p3_pixel, p4_pixel;
	 wire [23:0] num1_pixel, num2_pixel;
	 wire [23:0] w1_pixel, w2_pixel, w3_pixel, w4_pixel;
	 wire [23:0] o1_pixel, o2_pixel, o3_pixel, o4_pixel;
	 wire [23:0] n1_pixel, n2_pixel, n3_pixel; 
	 wire [23:0] ex1_pixel;

	 assign all_pixelsP1 = p1_pixel + p2_pixel + p3_pixel + p4_pixel + num1_pixel + 
	 w1_pixel + w2_pixel + w3_pixel + w4_pixel + 
	 o1_pixel + o2_pixel + o3_pixel + o4_pixel + 
	 n1_pixel + n2_pixel + n3_pixel + ex1_pixel;
	 
	 assign all_pixelsP2 = p1_pixel + p2_pixel + p3_pixel + p4_pixel + num1_pixel + num2_pixel + 
	 w1_pixel + w2_pixel + w3_pixel + w4_pixel + 
	 o1_pixel + o2_pixel + o3_pixel + o4_pixel + 
	 n1_pixel + n2_pixel + n3_pixel + ex1_pixel;

	 assign all_pixels = (winner) ? all_pixelsP1 : all_pixelsP2;
	 //P
	 rect p1(.hcount(hcount), .vcount(vcount), .start_x(START_X), .start_y(START_Y), .width(LINE_WIDTH), .height(LETTER_HEIGHT), .pixel(p1_pixel));
	 rect p2(.hcount(hcount), .vcount(vcount), .start_x(START_X + LINE_WIDTH), .start_y(START_Y), .width(11'd32), .height(LINE_WIDTH), .pixel(p2_pixel));
	 rect p3(.hcount(hcount), .vcount(vcount), .start_x(START_X + LINE_WIDTH), .start_y(START_Y+11'd48), .width(11'd32), .height(LINE_WIDTH), .pixel(p3_pixel));
	 rect p4(.hcount(hcount), .vcount(vcount), .start_x(START_X+11'd48), .start_y(START_Y), .width(LINE_WIDTH), .height(11'd64), .pixel(p4_pixel));

	 //Num
	 rect num1(.hcount(hcount), .vcount(vcount), .start_x(NUM_X), .start_y(START_Y), .width(LINE_WIDTH), .height(LETTER_HEIGHT), .pixel(num1_pixel));
	 rect num2(.hcount(hcount), .vcount(vcount), .start_x(NUM_X + LETTER_SPACE), .start_y(START_Y), .width(LINE_WIDTH), .height(LETTER_HEIGHT), .pixel(num2_pixel));

	 //W
	 rect w1(.hcount(hcount), .vcount(vcount), .start_x(W_X), .start_y(START_Y), .width(LINE_WIDTH), .height(LETTER_HEIGHT), .pixel(w1_pixel));
	 rect w2(.hcount(hcount), .vcount(vcount), .start_x(W_X + 11'd32), .start_y(START_Y), .width(LINE_WIDTH), .height(LETTER_HEIGHT), .pixel(w2_pixel));
	 rect w3(.hcount(hcount), .vcount(vcount), .start_x(W_X + 11'd64), .start_y(START_Y), .width(LINE_WIDTH), .height(LETTER_HEIGHT), .pixel(w3_pixel));
	 rect w4(.hcount(hcount), .vcount(vcount), .start_x(W_X), .start_y(START_Y + 11'd112), .width(LETTER_WIDTH), .height(LINE_WIDTH), .pixel(w4_pixel));

	 //O
	 rect o1(.hcount(hcount), .vcount(vcount), .start_x(O_X), .start_y(START_Y), .width(LINE_WIDTH), .height(LETTER_HEIGHT), .pixel(o1_pixel));
	 rect o2(.hcount(hcount), .vcount(vcount), .start_x(O_X + 11'd48), .start_y(START_Y), .width(LINE_WIDTH), .height(LETTER_HEIGHT), .pixel(o2_pixel));
	 rect o3(.hcount(hcount), .vcount(vcount), .start_x(O_X), .start_y(START_Y), .width(LETTER_WIDTH), .height(LINE_WIDTH), .pixel(o3_pixel));
	 rect o4(.hcount(hcount), .vcount(vcount), .start_x(O_X), .start_y(START_Y + 11'd112), .width(LETTER_WIDTH), .height(LINE_WIDTH), .pixel(o4_pixel));

	 //N
	 rect n1(.hcount(hcount), .vcount(vcount), .start_x(N_X), .start_y(START_Y), .width(LINE_WIDTH), .height(LETTER_HEIGHT), .pixel(n1_pixel));
	 rect n2(.hcount(hcount), .vcount(vcount), .start_x(N_X + 11'd48), .start_y(START_Y), .width(LINE_WIDTH), .height(LETTER_HEIGHT), .pixel(n2_pixel));
	 rect n3(.hcount(hcount), .vcount(vcount), .start_x(N_X), .start_y(START_Y), .width(LETTER_WIDTH), .height(LINE_WIDTH), .pixel(n3_pixel));

	 //!
	 rect ex1(.hcount(hcount), .vcount(vcount), .start_x(EX_X), .start_y(START_Y), .width(LINE_WIDTH), .height(11'd80), .pixel(ex1_pixel));
	 
	 always @ * begin
		if (all_pixels == 0) 
			pixel = BACKGROUND;
		else 
			pixel = all_pixels;
	end
endmodule

module rect #(parameter COLOR = 24'hFF_FF_FF) 
	(input [10:0] hcount, vcount, start_x, start_y, width, height,
	 output reg [23:0] pixel);
	 
	 always @ * begin
		if (hcount >= start_x && hcount <= start_x + width && vcount >= start_y && vcount <= start_y + height) pixel <= COLOR;
		else pixel <= 0;
	end
endmodule 
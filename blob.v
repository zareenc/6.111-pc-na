`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:14:33 11/28/2016 
// Design Name: 
// Module Name:    blob 
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
module blob 
   (input [10:0] x,hcount,width,
    input [10:0] y,vcount,height,
	 input [7:0] color,
    output reg [7:0] pixel);

   always @ * begin
      if ((hcount >= x && hcount < (x+width)) &&
		(vcount >= y && vcount < (y+height)))
			pixel = color;
      else pixel = 0;
   end
endmodule
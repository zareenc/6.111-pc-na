`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:22:20 11/28/2016 
// Design Name: 
// Module Name:    vram_display 
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


/////////////////////////////////////////////////////////////////////////////
// generate display pixels from reading the ZBT ram
// note that the ZBT ram has 2 cycles of read (and write) latency
//
// We take care of that by latching the data at an appropriate time.
//
// Note that the ZBT stores 36 bits per word; we use only 32 bits here,
// decoded into four bytes of pixel data.
//
// Bug due to memory management will be fixed. The bug happens because
// memory is called based on current hcount & vcount, which will actually
// shows up 2 cycle in the future. Not to mention that these incoming data
// are latched for 2 cycles before they are used. Also remember that the
// ntsc2zbt's addressing protocol has been fixed. 

// The original bug:
// -. At (hcount, vcount) = (100, 201) data at memory address(0,100,49) 
//    arrives at vram_read_data, latch it to vr_data_latched.
// -. At (hcount, vcount) = (100, 203) data at memory address(0,100,49) 
//    is latched to last_vr_data to be used for display.
// -. Remember that memory address(0,100,49) contains camera data
//    pixel(100,192) - pixel(100,195).
// -. At (hcount, vcount) = (100, 204) camera pixel data(100,192) is shown.
// -. At (hcount, vcount) = (100, 205) camera pixel data(100,193) is shown. 
// -. At (hcount, vcount) = (100, 206) camera pixel data(100,194) is shown.
// -. At (hcount, vcount) = (100, 207) camera pixel data(100,195) is shown.
//
// Unfortunately this means that at (hcount == 0) to (hcount == 11) data from
// the right side of the camera is shown instead (including possible sync signals). 

// To fix this, two corrections has been made:
// -. Fix addressing protocol in ntsc_to_zbt module.
// -. Forecast hcount & vcount 8 clock cycles ahead and use that
//    instead to call data from ZBT.


module vram_display(reset,clk,hcount,vcount,vr_pixel,
		    vram_addr,vram_read_data);

   input reset, clk;
   input [10:0] hcount;
   input [10:0] 	vcount;
   input [35:0]  vram_read_data;
   output [7:0] vr_pixel;
   output [18:0] vram_addr;
//	output reg is_bright;
	
	parameter THRESHOLD = 8'd128;
	parameter MAX_X = 1048;
	parameter MAX_Y = 805;

   //forecast hcount & vcount 8 clock cycles ahead to get data from ZBT
	// MY CODE
//	parameter NEW_RES = 800;
//	wire [10:0] hcount_new = NEW_RES-hcount;
//   wire [10:0] hcount_f = (hcount_new <= 0) ? (MAX_X + hcount_new) : (hcount_new - 8);
//	// ORIGINAL CODE
   wire [10:0] hcount_f = (hcount >= MAX_X) ? (hcount - MAX_X) : (hcount + 8);
   wire [10:0] vcount_f = (hcount >= MAX_X) ? ((vcount == MAX_Y) ? 0 : vcount + 1) : vcount;
      
   wire [18:0] 	 vram_addr = {1'b0, vcount_f, hcount_f[9:2]};

//	// ORIGINAL CODE
   wire [1:0] 	 hc4 = hcount[1:0];
	// MY CODE 
//	wire [1:0] 	 hc4 = hcount_new[1:0];
   reg [7:0] 	 	 vr_pixel;
   reg [35:0] 	 vr_data_latched;
   reg [35:0] 	 last_vr_data;

   always @(posedge clk)
     last_vr_data <= (hc4==2'd3) ? vr_data_latched : last_vr_data;

   always @(posedge clk)
     vr_data_latched <= (hc4==2'd1) ? vram_read_data : vr_data_latched;

   always @(*) begin	// each 36-bit word from RAM is decoded to 4 bytes
     case (hc4)
	    // MY CODE
//		 2'd0: vr_pixel = last_vr_data[7:0];
//       2'd1: vr_pixel = last_vr_data[7+8:0+8];
//       2'd2: vr_pixel = last_vr_data[7+16:0+16];
//       2'd3: vr_pixel = last_vr_data[7+24:0+24];	  
//		 // ORIGINAL CODE
       2'd3: vr_pixel = last_vr_data[7:0];
       2'd2: vr_pixel = last_vr_data[7+8:0+8];
       2'd1: vr_pixel = last_vr_data[7+16:0+16];
       2'd0: vr_pixel = last_vr_data[7+24:0+24];
     endcase
//	  if (last_vr_data[7:0]>THRESHOLD || 
//			last_vr_data[7+8:0+8]>THRESHOLD || 
//			last_vr_data[7+16:0+16]>THRESHOLD || 
//			last_vr_data[7+24:0+24]>THRESHOLD)
//			is_bright <= 1;
//		else
//			is_bright <= 0;
	end

endmodule // vram_display
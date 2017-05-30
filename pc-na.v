//
// File:   zbt_6111_sample.v
// Date:   26-Nov-05
// Author: I. Chuang <ichuang@mit.edu>
//
// Sample code for the MIT 6.111 labkit demonstrating use of the ZBT
// memories for video display.  Video input from the NTSC digitizer is
// displayed within an XGA 1024x768 window.  One ZBT memory (ram0) is used
// as the video frame buffer, with 8 bits used per pixel (black & white).
//
// Since the ZBT is read once for every four pixels, this frees up time for 
// data to be stored to the ZBT during other pixel times.  The NTSC decoder
// runs at 27 MHz, whereas the XGA runs at 65 MHz, so we synchronize
// signals between the two (see ntsc2zbt.v) and let the NTSC data be
// stored to ZBT memory whenever it is available, during cycles when
// pixel reads are not being performed.
//
// We use a very simple ZBT interface, which does not involve any clock
// generation or hiding of the pipelining.  See zbt_6111.v for more info.
//
// switch[7] selects between display of NTSC video and test bars
// switch[6] is used for testing the NTSC decoder
// switch[1] selects between test bar periods; these are stored to ZBT
//           during blanking periods
// switch[0] selects vertical test bars (hardwired; not stored in ZBT)
//
//
// Bug fix: Jonathan P. Mailoa <jpmailoa@mit.edu>
// Date   : 11-May-09
//
// Use ramclock module to deskew clocks;  GPH
// To change display from 1024*787 to 800*600, use clock_40mhz and change
// accordingly. Verilog ntsc2zbt.v will also need changes to change resolution.
//
// Date   : 10-Nov-11

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
//    "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
//    output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into 
//    the data bus, and the byte write enables have been combined into the
//    4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
//    hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2011-Nov-10: Changed resolution to 1024 * 768.
//					 Added back ramclok to deskew RAM clock
//
// 2009-May-11: Fixed memory management bug by 8 clock cycle forecast. 
//              Changed resolution to  800 * 600.
//              Reduced clock speed to 40MHz.
//              Disconnected zbt_6111's ram_clk signal. 
//              Added ramclock to control RAM.
//              Added notes about ram1 default values.
//              Commented out clock_feedback_out assignment.
//              Removed delayN modules because ZBT's latency has no more effect.
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
//              "disp_data_out", "analyzer[2-3]_clock" and
//              "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
//              actually populated on the boards. (The boards support up to
//              256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
//              value. (Previous versions of this file declared this port to
//              be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
//              actually populated on the boards. (The boards support up to
//              72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////

module pc_na(beep, audio_reset_b, 
		    ac97_sdata_out, ac97_sdata_in, ac97_synch,
	       ac97_bit_clock,
	       
	       vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
	       vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
	       vga_out_vsync,

	       tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
	       tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
	       tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

	       tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
	       tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
	       tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
	       tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

	       ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
	       ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b, 

	       ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
	       ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

	       clock_feedback_out, clock_feedback_in,

	       flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
	       flash_reset_b, flash_sts, flash_byte_b,

	       rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

	       mouse_clock, mouse_data, keyboard_clock, keyboard_data,

	       clock_27mhz, clock1, clock2,

	       disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
	       disp_reset_b, disp_data_in,

	       button0, button1, button2, button3, button_enter, button_right,
	       button_left, button_down, button_up,

	       switch,

	       led,
	       
	       user1, user2, user3, user4,
	       
	       daughtercard,

	       systemace_data, systemace_address, systemace_ce_b,
	       systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
	       
	       analyzer1_data, analyzer1_clock,
 	       analyzer2_data, analyzer2_clock,
 	       analyzer3_data, analyzer3_clock,
 	       analyzer4_data, analyzer4_clock);

   ////////////////////////////////////////////////////////////////////////////
   //
   // Input and Output specifications
   //
   ////////////////////////////////////////////////////////////////////////////

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
   input  ac97_bit_clock, ac97_sdata_in;
   
   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
	  vga_out_hsync, vga_out_vsync;

   output [9:0] tv_out_ycrcb;
   output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
	  tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
	  tv_out_subcar_reset;
   
   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
	  tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
	  tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;
        
   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   output [3:0] ram0_bwe_b;
   
   inout  [35:0] ram1_data;
   output [18:0] ram1_address;
   output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;
   
   inout  [15:0] flash_data;
   output [23:0] flash_address;
   output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   input  flash_sts;
   
   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz, clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;  
   input  disp_data_in;
   output  disp_data_out;
   
   input  button0, button1, button2, button3, button_enter, button_right,
	  button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   inout [31:0] user1, user2, user3, user4;
   
   inout [43:0] daughtercard;

   inout  [15:0] systemace_data;
   output [6:0]  systemace_address;
   output systemace_ce_b, systemace_we_b, systemace_oe_b;
   input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data, 
		 analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////
   
   // Audio Input and Output
   assign beep= 1'b0;
   assign audio_reset_b = 1'b0;
   assign ac97_synch = 1'b0;
   assign ac97_sdata_out = 1'b0;

   // ac97_sdata_in is an input

   // Video Output
   assign tv_out_ycrcb = 10'h0;
   assign tv_out_reset_b = 1'b0;
   assign tv_out_clock = 1'b0;
   assign tv_out_i2c_clock = 1'b0;
   assign tv_out_i2c_data = 1'b0;
   assign tv_out_pal_ntsc = 1'b0;
   assign tv_out_hsync_b = 1'b1;
   assign tv_out_vsync_b = 1'b1;
   assign tv_out_blank_b = 1'b1;
   assign tv_out_subcar_reset = 1'b0;
   
   // Video Input
   //assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b1;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b1;
   //assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = clock_27mhz;//1'b0;
   //assign tv_in_i2c_data = 1'bZ;
   // tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, 
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs
   
   // SRAMs

/* change lines below to enable ZBT RAM bank0 */

/*
   assign ram0_data = 36'hZ;
   assign ram0_address = 19'h0;
   assign ram0_clk = 1'b0;
   assign ram0_we_b = 1'b1;
   assign ram0_cen_b = 1'b0;	// clock enable
*/

/* enable RAM pins */

   assign ram0_ce_b = 1'b0;
   assign ram0_oe_b = 1'b0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_bwe_b = 4'h0; 

/**********/

   assign ram1_data = 36'hZ; 
   assign ram1_address = 19'h0;
   assign ram1_adv_ld = 1'b0;
   assign ram1_clk = 1'b0;
   
   //These values has to be set to 0 like ram0 if ram1 is used.
   assign ram1_cen_b = 1'b1;
   assign ram1_ce_b = 1'b1;
   assign ram1_oe_b = 1'b1;
   assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'hF;

   // clock_feedback_out will be assigned by ramclock
   // assign clock_feedback_out = 1'b0;  //2011-Nov-10
   // clock_feedback_in is an input
   
   // Flash ROM
   assign flash_data = 16'hZ;
   assign flash_address = 24'h0;
   assign flash_ce_b = 1'b1;
   assign flash_oe_b = 1'b1;
   assign flash_we_b = 1'b1;
   assign flash_reset_b = 1'b0;
   assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
/*
   assign disp_blank = 1'b1;
   assign disp_clock = 1'b0;
   assign disp_rs = 1'b0;
   assign disp_ce_b = 1'b1;
   assign disp_reset_b = 1'b0;
   assign disp_data_out = 1'b0;
*/
   // disp_data_in is an input

   // Buttons, Switches, and Individual LEDs
   //lab3 assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
//   assign user1 = 32'hZ;
   assign user2 = 32'hZ;
   assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   assign systemace_data = 16'hZ;
   assign systemace_address = 7'h0;
   assign systemace_ce_b = 1'b1;
   assign systemace_we_b = 1'b1;
   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
	wire clk;
	
   assign analyzer1_data = 16'h0;
   assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;
   assign analyzer3_data = 16'h0;//{6'b0,vert1[19:10]};
   assign analyzer3_clock = clk;
   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;
			    
   ////////////////////////////////////////////////////////////////////////////
   //
	// ZBT RAM as video memory
	// 
   ////////////////////////////////////////////////////////////////////////////
/*
   // use FPGA's digital clock manager to produce a
   // 65MHz clock (actually 64.8MHz)
   wire clock_65mhz_unbuf,clock_65mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_65mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 10
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 24
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_65mhz),.I(clock_65mhz_unbuf));

//   wire clk = clock_65mhz;  // gph 2011-Nov-10
*/


   // use FPGA's digital clock manager to produce a
   // 40MHz clock (actually 40.5MHz)
   wire clock_40mhz_unbuf,clock_40mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_40mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 2
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 3
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_40mhz),.I(clock_40mhz_unbuf));

   //wire clk = clock_40mhz;

	
	
	// use FPGA's digital clock manager to produce a
   // 25MHz clock (actually 25.2MHz)
/*   wire clock_25mhz_unbuf,clock_25mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_25mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 30
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 28
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_25mhz),.I(clock_25mhz_unbuf));
*/

	wire locked;
	//assign clock_feedback_out = 0; // gph 2011-Nov-10
   
   ramclock rc(.ref_clock(clock_40mhz), .fpga_clock(clk),
					.ram0_clock(ram0_clk), 
					//.ram1_clock(ram1_clk),   //uncomment if ram1 is used
					.clock_feedback_in(clock_feedback_in),
					.clock_feedback_out(clock_feedback_out), .locked(locked));

   
   // power-on reset generation
   wire power_on_reset;    // remain high for first 16 clocks
   SRL16 reset_sr (.D(1'b0), .CLK(clk), .Q(power_on_reset),
		   .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   defparam reset_sr.INIT = 16'hFFFF;

   // ENTER button is user reset
   wire reset,user_reset;
   debounce db1(power_on_reset, clk, ~button_enter, user_reset);
   assign reset = user_reset | power_on_reset;

   // display module for debugging
   wire [63:0] dispdata; //NOTE: changed from reg->wire
   display_16hex hexdisp1(reset, clk, dispdata,
			  disp_blank, disp_clock, disp_rs, disp_ce_b,
			  disp_reset_b, disp_data_out);

   // generate basic XVGA video signals
	parameter HOR_MAX = 11'd800;
   wire [10:0] hcount_orig;
   wire [10:0] vcount;
   wire hsync,vsync,blank;
   xvga xvga1(clk,hcount_orig,vcount,hsync,vsync,blank);
	wire [10:0] hcount = hcount_orig;

   // wire up to ZBT ram

   wire [35:0] vram_write_data;
   wire [35:0] vram_read_data;
   wire [18:0] vram_addr;
   wire        vram_we;

   wire ram0_clk_not_used;
   zbt_6111 zbt1(clk, 1'b1, vram_we, vram_addr,
		   vram_write_data, vram_read_data,
		   ram0_clk_not_used,   //to get good timing, don't connect ram_clk to zbt_6111
		   ram0_we_b, ram0_address, ram0_data, ram0_cen_b);

   // generate pixel value from reading ZBT memory
   wire [7:0] 	vr_pixel1;
   wire [18:0] 	vram_addr1;

   vram_display vd1(reset,clk,hcount,vcount,vr_pixel1,
		    vram_addr1,vram_read_data);
	parameter THRESHOLD = 8'd128;
	wire is_bright = (vr_pixel1 > THRESHOLD); // Determines if pixel has object we are tracking
	
			 
	////////////////////////////////////////////////////////////////////////////////
	//
	// Cue tracking and speed calculation
	//
	////////////////////////////////////////////////////////////////////////////////
	
	// Calibration
	wire [2:0] state1,state2,state3,state4;
	wire [21:0] hor1_cal,hor2_cal,hor3_cal,hor4_cal;
	wire [21:0] vert1_cal,vert2_cal,vert3_cal,vert4_cal;
	wire calib_done;
	wire [10:0] xo,xf;
	wire [10:0] yo,yf;
	wire button1_cln;
	debounce bt1(.reset(reset),.clk(clock_27mhz),.noisy(~button1),.clean(button1_cln));
	calibration calib(.clk(clk),.is_bright(is_bright),.hcount(hcount),
		.vcount(vcount),.calibrated(button1_cln),.done(calib_done),
		.xo_r(xo),.xf_r(xf),.yo_r(yo),.yf_r(yf),
		.hor1(hor1_cal),.hor2(hor2_cal),.hor3(hor3_cal),.hor4(hor4_cal),
		.vert1(vert1_cal),.vert2(vert2_cal),.vert3(vert3_cal),.vert4(vert4_cal),
		.state1(state1),.state2(state2),.state3(state3),.state4(state4));
		
	// Cue tracking
	wire [21:0] hor1_cue,hor2_cue,hor3_cue;
	wire [21:0] vert1_cue,vert2_cue,vert3_cue;
	track_cue cue(.clk(clk),.hcount(hcount),.vcount(vcount),.is_bright(is_bright),
		.hor1(hor1_cue),.hor2(hor2_cue),.hor3(hor3_cue),
		.vert1(vert1_cue),.vert2(vert2_cue),.vert3(vert3_cue));
		
	// Assigns center coordinates of tracked LED's
	wire [3:0] game_state;
	parameter CALIBRATION = 0;
	wire [21:0] hor1 = (game_state==CALIBRATION) ? hor1_cal : hor1_cue;
	wire [21:0] hor2 = (game_state==CALIBRATION) ? hor2_cal : hor2_cue;
	wire [21:0] hor3 = (game_state==CALIBRATION) ? hor3_cal : hor3_cue;
	wire [21:0] hor4 = (game_state==CALIBRATION) ? hor4_cal : 0;
	
	wire [21:0] vert1 = (game_state==CALIBRATION) ? vert1_cal : vert1_cue;
	wire [21:0] vert2 = (game_state==CALIBRATION) ? vert2_cal : vert2_cue;
	wire [21:0] vert3 = (game_state==CALIBRATION) ? vert3_cal : vert3_cue;
	wire [21:0] vert4 = (game_state==CALIBRATION) ? vert4_cal : 0;
	
	// Distinguishes front from back of cue
	wire [21:0] front_hor,back_hor;
	wire [21:0] front_vert,back_vert;
	find_front ff(.clk(clk),.hor1(hor1),.hor2(hor2),.hor3(hor3),
		.vert1(vert1),.vert2(vert2),.vert3(vert3),.front_hor(front_hor),
		.front_vert(front_vert),.back_hor(back_hor),.back_vert(back_vert));
		
	// Converts cue position to signed board coordinates
	// NOTE: Set calib_on to 0 for debugging mode (button controlled cue)
	wire calib_on = 1'b0;
	wire signed [10:0] track_front_x = (calib_on) ? (($signed(front_hor[21:11])+$signed(front_hor[10:0]))/2) - $signed(xo)
		: (($signed(front_hor[21:11])+$signed(front_hor[10:0]))/2);
	wire signed [10:0] track_front_y = (calib_on) ? (($signed(front_vert[21:11])+$signed(front_vert[10:0]))/2) - $signed(yo)
		: (($signed(front_vert[21:11])+$signed(front_vert[10:0]))/2);
	wire signed [10:0] track_back_x = (calib_on) ? (($signed(back_hor[21:11])+$signed(back_hor[10:0]))/2) - $signed(xo)
		: (($signed(back_hor[21:11])+$signed(back_hor[10:0]))/2);
	wire signed [10:0] track_back_y = (calib_on) ? (($signed(back_vert[21:11])+$signed(back_vert[10:0]))/2) - $signed(yo)
		: (($signed(back_vert[21:11])+$signed(back_vert[10:0]))/2);
			
	// Calculates cue speed
	wire signed [21:0] speed_tracked;
	wire signed [10:0] y_diff_pos,y_diff_neg;
	wire signed [10:0] y_diff_out;
	wire signed [10:0] x_diff_out;
	wire signed [10:0] y_old,y_curr;
	wire signed [9:0] pixel_speed;
	cue_speed_calculator cue_speed(.clk(clk),.cue_front_x(track_front_x),
		.cue_front_y(track_front_y),.cue_hit(cue_hit),.cue_speed(speed_tracked),
		.pause(switch[4]),.y_old(y_old),.y_curr(y_curr),.y_diff_pos(y_diff_pos),
		.y_diff_neg(y_diff_neg),.y_diff_out(y_diff_out),.x_diff_out(x_diff_out),
		.pixel_speed(pixel_speed));
			
	////////////////////////////////////////////////////////////////////////////////
	//
	// Visualization of tracking
	//
	////////////////////////////////////////////////////////////////////////////////
	
	// Blobs to visualize tracked IR sources
	parameter WHITE = 200;
			
	// Tracking blob 1
	wire [7:0] vr_pixel_track1;
	wire [10:0] left1 = hor1[21:11];
	wire [10:0] right1 = hor1[10:0];
	wire [10:0] top1 = vert1[21:11];
	wire [10:0] bottom1 = vert1[10:0];
	wire [10:0] width1 = right1-left1;
	wire [10:0] height1 = bottom1-top1;
	blob track1(.x(left1),.y(top1),.hcount(hcount),.vcount(vcount),
					.pixel(vr_pixel_track1),.color(WHITE),.width(width1),.height(height1));
	
	// Tracking blob 2
	wire [7:0] vr_pixel_track2;
	wire [10:0] left2 = hor2[21:11];
	wire [10:0] right2 = hor2[10:0];
	wire [10:0] top2 = vert2[21:11];
	wire [10:0] bottom2 = vert2[10:0];
	wire [10:0] width2 = right2-left2;
	wire [10:0] height2 = bottom2-top2;
	blob track2(.x(left2),.y(top2),.hcount(hcount),.vcount(vcount),
					.pixel(vr_pixel_track2),.color(WHITE),.width(width2),.height(height2));

	// Tracking blob 3
	wire [7:0] vr_pixel_track3;
	wire [10:0] left3 = hor3[21:11];
	wire [10:0] right3 = hor3[10:0];
	wire [10:0] top3 = vert3[21:11];
	wire [10:0] bottom3 = vert3[10:0];
	wire [10:0] width3 = right3-left3;
	wire [10:0] height3 = bottom3-top3;
	blob track3(.x(left3),.y(top3),.hcount(hcount),.vcount(vcount),
					.pixel(vr_pixel_track3),.color(WHITE),.width(width3),.height(height3));

	// Tracking blob 4
	wire [7:0] vr_pixel_track4;
	wire [10:0] left4 = hor4[21:11];
	wire [10:0] right4 = hor4[10:0];
	wire [10:0] top4 = vert4[21:11];
	wire [10:0] bottom4 = vert4[10:0];
	wire [10:0] width4 = right4-left4;
	wire [10:0] height4 = bottom4-top4;
	blob track4(.x(left4),.y(top4),.hcount(hcount),.vcount(vcount),
					.pixel(vr_pixel_track4),.color(WHITE),.width(width4),.height(height4));

	// Combined tracking pixel
	wire [7:0] vr_pixel = vr_pixel1|vr_pixel_track1|vr_pixel_track2
		|vr_pixel_track3|vr_pixel_track4;
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// Pool game
	//
	////////////////////////////////////////////////////////////////////////////////

   // Debounce up, down, left, right buttons for debug mode
	wire up,down, left, right;
   debounce db_up(.reset(reset),.clk(clk),.noisy(~button_up),.clean(up));
   debounce db_down(.reset(reset),.clk(clk),.noisy(~button_down),.clean(down));
	debounce db_left(.reset(reset),.clk(clk),.noisy(~button_left),.clean(left));
	debounce db_right(.reset(reset),.clk(clk),.noisy(~button_right),.clean(right));
	
	// Ball position handling
   wire [23:0] pixel_p; // pool game pixel
   wire phsync,pvsync,pblank;
	wire done_fric_all,cue_hit,pocket;
	wire [3:0] stripes_pts, solid_pts;
   pool_game pg(//Inputs
					 .debug(switch[2]),.vclock(clock_65mhz),.reset(reset),
					 .hcount(hcount),.vcount(vcount),
                .hsync(hsync),.vsync(vsync),.blank(blank),
                .up(up),.down(down),.left(left),.right(right),
					 .x_cue_front(track_front_x),.y_cue_front(track_front_y),
					 .x_cue_back(track_back_x),.y_cue_back(track_back_y),
					 .pixel_speed(pixel_speed),
					 // Outputs
					 .phsync(phsync),.pvsync(pvsync),.pblank(pblank),
					 .pixel(pixel_p),.coll_cue_out(cue_hit),
					 .x_cue_speed(x_diff_out), .y_cue_speed(y_diff_out),
					 .pocket(pocket),.stripes_pts(stripes_pts),.solid_pts(solid_pts),
					 .game_state(game_state),.done_fric_all(done_fric_all));

	// Game FSM
	game_fsm fsm(.clk(clk),.game_state(game_state),.is_bright(is_bright),
		.hcount(hcount),.vcount(vcount),.calib_done(calib_done),
		.done_fric_all(done_fric_all),.cue_hit(cue_hit),.reset(reset),
		.pocket(pocket),.stripes_pts(stripes_pts),.solid_pts(solid_pts));

	// Display points and winner
	assign dispdata[63:0] = {game_state,stripes_pts,solid_pts,52'b0};
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// Accelerometer reading
	//
	////////////////////////////////////////////////////////////////////////////////

	// 2MHz clock
	reg clk_2mhz = 0;
	reg [4:0] clock_count = 5'b0;
	always @(posedge clock_27mhz) begin
		if (clock_count==5'd5) begin
			clk_2mhz <= ~clk_2mhz;
			clock_count <= 0;
		end
		else clock_count <= clock_count+1;
	end	
		
	// SPI reader
	parameter MEM_ADDR = 7'd59;
	parameter rw = 1;
	reg [7:0] addr = {rw,MEM_ADDR};
	wire signed [47:0] output_data;
	wire new_data, busy;
	wire button0_cln;
	wire sck; // ~1.1MHz
	assign user1[8] = sck;
	spi_reading spi(.sys_clock(clock_27mhz),.clk(clk_2mhz),.reset(reset),.miso(user1[4]),
		.command({addr,8'b0}),.start(switch[4]),.mosi(user1[6]),.cs(user1[2]),.sck(sck),
		.data_out(output_data),.new_data(new_data),.busy(busy));
		
	// Average accelerometer readings
	wire signed [15:0] x_avg,y_avg,z_avg;
	lpf avg_data(.clk(clk_2mhz),.data(output_data),.x_avg(x_avg),
		.y_avg(y_avg),.z_avg(z_avg));
		
	// Cue speed calculator
	wire signed [31:0] speed;
	wire [4:0] max_speed;
	accel_speed_calculator accel_speed(.clk(clk_2mhz),.x_avg(x_avg),
		.y_avg(y_avg),.z_avg(z_avg),.cue_speed(speed),.max_cue_speed(max_speed));

	// Output accelerometer data
	parameter signed ACCEL_THRESH = 16'd16_000;
	wire x = (x_avg>=ACCEL_THRESH);
	wire y = (y_avg>=ACCEL_THRESH);
	wire z = (z_avg>=ACCEL_THRESH);

	
	////////////////////////////////////////////////////////////////////////////////
	//
	// Camera decoding
	//
	////////////////////////////////////////////////////////////////////////////////

   // ADV7185 NTSC decoder interface code
   // adv7185 initialization module
   adv7185init adv7185(.reset(reset), .clock_27mhz(clock_27mhz), 
		       .source(1'b0), .tv_in_reset_b(tv_in_reset_b), 
		       .tv_in_i2c_clock(tv_in_i2c_clock), 
		       .tv_in_i2c_data(tv_in_i2c_data));

   wire [29:0] ycrcb;	// video data (luminance, chrominance)
   wire [2:0] fvh;	// sync for field, vertical, horizontal
   wire       dv;	// data valid
   
   ntsc_decode decode (.clk(tv_in_line_clock1), .reset(reset),
		       .tv_in_ycrcb(tv_in_ycrcb[19:10]), 
		       .ycrcb(ycrcb), .f(fvh[2]),
		       .v(fvh[1]), .h(fvh[0]), .data_valid(dv));

   // code to write NTSC data to video memory

   wire [18:0] ntsc_addr;
   wire [35:0] ntsc_data;
   wire        ntsc_we;
   ntsc_to_zbt n2z (clk, tv_in_line_clock1, fvh, dv, ycrcb[29:22],
		    ntsc_addr, ntsc_data, ntsc_we, switch[6]);

   // code to write pattern to ZBT memory
   reg [31:0] 	count;
   always @(posedge clk) count <= reset ? 0 : count + 1;

   wire [18:0] 	vram_addr2 = count[0+18:0];
   wire [35:0] 	vpat = ( switch[1] ? {4{count[3+3:3],4'b0}}
			 : {4{count[3+4:4],4'b0}} );

   // mux selecting read/write to memory based on which write-enable is chosen

   wire 	sw_ntsc = ~switch[7];
   wire 	my_we = sw_ntsc ? (hcount[1:0]==2'd2) : blank;
   wire [18:0] 	write_addr = sw_ntsc ? ntsc_addr : vram_addr2;
   wire [35:0] 	write_data = sw_ntsc ? ntsc_data : vpat;

//   wire 	write_enable = sw_ntsc ? (my_we & ntsc_we) : my_we;
//   assign 	vram_addr = write_enable ? write_addr : vram_addr1;
//   assign 	vram_we = write_enable;

   assign 	vram_addr = my_we ? write_addr : vram_addr1;
   assign 	vram_we = my_we;
   assign 	vram_write_data = write_data;

	////////////////////////////////////////////////////////////////////////////////
	//
	// Pixel output
	//
	////////////////////////////////////////////////////////////////////////////////
	
   // Select output pixel data
   reg [7:0] 	pixel;
   reg 	b,hs,vs;
   reg [23:0] rgb;
   
	// Output pool game pixel
   always @(posedge clk) begin
		if (switch[5]) begin
			 hs <= phsync;
			 vs <= pvsync;
			 b <= pblank;
      end
		else begin
			pixel <= switch[0] ? {hcount[8:6],5'b0} : vr_pixel;
			b <= blank;
			hs <= hsync;
			vs <= vsync;
		end
	end

   // VGA Output.  In order to meet the setup and hold times of the
   // AD7125, we send it ~clk.
   assign vga_out_red = (switch[5]) ? pixel_p[23:16] : pixel;
   assign vga_out_green = (switch[5]) ? pixel_p[15:8] : pixel;
   assign vga_out_blue = (switch[5]) ? pixel_p[7:0] : pixel;
   assign vga_out_sync_b = 1'b1;    // not used
   assign vga_out_pixel_clock = ~clk;
   assign vga_out_blank_b = ~b;
   assign vga_out_hsync = hs;
   assign vga_out_vsync = vs;

   // debugging
//   assign led = ~{vram_addr[18:13],reset,switch[0]};	
	assign led[7:3] = {1,1,1,1,1};
	assign led[1:0] = {1,1};
		
endmodule
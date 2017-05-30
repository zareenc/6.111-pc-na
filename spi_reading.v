`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:23:34 10/31/2016 
// Design Name: 
// Module Name:    spi_reading
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
module clock_7Mhz (input reset, input clock, output reg slow_clock);
	//the incoming clock is the 27Mhz clock;
	//generatin the 7Mhz clock
	reg [3:0] count;

    always @(posedge clock)begin
        if (reset) begin
            count <= 0;
            slow_clock <= 0;
        end 
        else begin
            if (count == 1) begin
                slow_clock <= ~slow_clock;
                count <= 0;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule

module clock_14Mhz (input reset, input clock, output reg slow_clk);
	//the incoming clock is the 27Mhz clock; rising edge every 8th count
	//generatin the 14Mhz clock
	reg [3:0]count;

    always @(posedge clock)begin
        if (reset) begin
            count <= 0;
            slow_clk <= 0;
        end 
        else begin
				//if (count == 7) begin
					slow_clk <= ~slow_clk;
					count <= 0;
				//end
				//else begin
				//	count <= count + 1;
				//end
        end
    end
endmodule

//declare 2 of this modules, one for the gyroscope and one for the accelerometer
module spi_reading(
	 input sys_clock,  //system clock (27Mhz)
	 input clk,  //2x the speed of the sck
    input reset,  //reset the protocol
    input miso,  //output from the chip
    input [15:0] command,  //(1 READ or 0 WWRITE) then 7 bit address 8 bit command
    input start,  //HI when the game start
    output mosi,  //send the info the chip
	 output cs,
    output sck,  //clock for the master and the slave
    output signed [47:0] data_out,  //data to send out
    output new_data,  //HI if the transfer is successful, LOW if the data isn't
    output busy   //HI if the state is not in idle
    );

	localparam IDLE = 3'd0;  //initial state
	localparam READ_ADDR = 3'd1;  //the first bit is read, 0; send to the address what to read from
	localparam ADDR = 3'd2;  //sending the reg address 7 bit
	localparam WRITE = 3'd3;  //send the command to the chip
	localparam TRANSFER = 3'd4; //reading the incoming data

	reg [5:0] bit_count = 0;
	reg signed [47:0] data_out_q;
	reg mosi_q = 1;
	reg new_data_q;
	reg cs_q = 1;
	reg sck_q;
	//reg enable = 0;
	reg [22:0] pause = 0;
	reg [2:0] state = IDLE;
	
	//wire slow_clock;
	//clock_7Mhz slow_clk(.reset(reset),.clock(sys_clock),.slow_clock(slow_clock));

	//wire sck_risingedge;
	//wire sck_fallingedge;
	//assign sck_risingedge = (sck_q[2:1] == 2'b01);
	//assign sck_fallingedge = (sck_q[2:1] == 2'b10);

	//assign sck = (enable && slow_clock);
	assign data_out = data_out_q;
	assign mosi = mosi_q;
	assign cs = cs_q;
	assign sck = sck_q;
	assign busy = (state != IDLE);
	assign new_data = new_data_q;

	always @(posedge clk) begin
		if (reset) begin
			state <= IDLE;
			mosi_q <= 1;
			bit_count <= 0;
			cs_q <= 1;
		end
		//sck_q <= {sck_q[1:0],slow_clock};  //pulsing the slow 7Mhz clock
		case (state)
			IDLE: begin
				if (pause <= 23'd100) begin
					pause <= pause+1;
					mosi_q <= 1;
					bit_count <= 0;   //reset the bit count
					//data_out_q <= 0;  //empty the data
					new_data_q <= 0;    //data is now brand new
					sck_q <= 1;
					//enable <= 0;
					cs_q <= 1;
				end
//				if (command[15] && (start)) begin   //go to read state
				else if (start) begin
					state <= READ_ADDR;
					bit_count <= bit_count + 1;
					mosi_q <= command[15 - bit_count];
					//enable <= 1;
					sck_q <= 0;
					cs_q <= 0;
					pause <= 0;
				end
//				else if (!command[15] && (start)) begin   //go to address state
//					state <= ADDR;
//					//enable <= 1;
//					cs_q <= 0;
//					sck_q <= 0;
//					bit_count <= bit_count + 1;
//					mosi_q <= command[15 - bit_count];
//					//pause <= 0;
//				end
				else begin
					mosi_q <= 1;
					bit_count <= 0;   //reset the bit count
					//data_out_q <= 0;  //empty the data
					new_data_q <= 0;    //data is now brand new
					sck_q <= 1;
					//enable <= 0;
					cs_q <= 1;
					pause <= 0;
				end
				
			end  
//			ADDR: begin    //select the address
//				if (sck_q) begin
//					if (bit_count == 8) begin
//						state <= WRITE;
//						bit_count <= 0;
//					end
//					else begin
//						bit_count <= bit_count + 1;
//						mosi_q <= command[15 - bit_count];
//					end
//					sck_q <= 0;
//				end
//				else begin
//					sck_q <= 1;
//				end
//			end
//			WRITE: begin     //writing the command to the chip
//				if (sck_q) begin
//					if (bit_count == 8) begin
//						state <= READ_ADDR;
//						bit_count <= 0;
//					end
//					else begin
//						bit_count <=  bit_count + 1;
//						mosi_q <= command[8 - bit_count];
//					end
//					sck_q <= 0;
//				end
//				else begin
//					sck_q <= 1;
//				end
//			end
			READ_ADDR: begin
				if (sck_q) begin
					if (bit_count == 8) begin
						state <= TRANSFER;
						bit_count <= 0;
					end
					else begin
						bit_count <= bit_count + 1;
						mosi_q <= command[15 - bit_count];
					end
					sck_q <= 0;
				end 
				else begin
					sck_q <= 1;
				end
			end
			TRANSFER: begin
				if (sck_q) begin
					if (bit_count == 48) begin
						state <= IDLE;
						bit_count <= 0;
						new_data_q <= 1;
					end
					else begin
						mosi_q <= 1;
						bit_count <= bit_count + 1;
						data_out_q <= {data_out_q[46:0],miso};
					end
					sck_q <= 0;
				end
				else begin
					sck_q <= 1;
				end
			end
		endcase
	end
endmodule

	
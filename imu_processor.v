`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:01:08 11/11/2016 
// Design Name: 
// Module Name:    imu_processor 
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
module imu_processor(clk,mosi,miso,ncs,csb,sck,output_data,state_out);
	input clk;
	input miso;
	output reg mosi;
	output reg [47:0] output_data;
	output ncs,csb;
	output sck;
	output [2:0] state_out;
	
	// States
	parameter ADDR = 3'd0;
	parameter READ = 3'd1;
	parameter PAUSE = 3'd2;
	reg [2:0] state = ADDR;
	reg [2:0] next_state = ADDR;
	reg ncs_r = 1'b0; // initialize MPU to active low
	
	// Set chip select outputs
	assign ncs = ncs_r; 
	assign csb = 1'b1; // never select BMP
	assign state_out = next_state;
	
	// Registers
	parameter ADDR_LEN = 6'd8;
	parameter MAX_COUNT = 6'd8;
	parameter PAUSE_LEN = 8'd10;
	parameter NUM_ACCEL = 6'd48;
	parameter MEM_ADDR = 7'd59;
	parameter rw = 1;
	reg [7:0] addr = {rw,MEM_ADDR};
	reg [2:0] i = 3'd7; // Index in address byte
//	reg [2:0] j; // Index in data byte
	reg [7:0] pause_count = 0; // Count clock cycles
	reg [5:0] accel_count = 0;
	reg [47:0] data = {48{1'b1}};
//	assign output_data = data;
	
	reg sck = 0;
	always @(posedge clk) begin
		sck <= ~sck;
//		case (state)
//			// Set synchronous clock
//			ADDR: sck <= ~sck; 
//			READ: sck <= ~sck;
//			// Set clock high
//			PAUSE: sck <= 1'b1;
//		endcase
	end 

	always @(negedge sck) begin
		//state <= next_state;
		
		
		case (next_state)
			// Send address value
			ADDR: begin
				// Send address byte
				ncs_r <= 1'b0;
				mosi <= addr[i];
				if (i>0) begin
					i <= i-1;
					next_state <= ADDR;
				end
				// Set next address byte
				else begin
					i <= ADDR_LEN-1;
					next_state <= READ;
				end
			end
			
			// Read accel data
			READ: begin
				// Read in data byte MSB->LSB
				ncs_r <= 1'b0;
				mosi <= 1;
				data <= {data[46:0],miso};
//				data[i] <= miso;
//				if (i>0) begin
//					i <= i-1;
//				end
//				else begin
//					i <= ADDR_LEN-1;
//					accel_count <= accel_count+1;
//					output_data <= data;
//				end
				// Update state
				if (accel_count==NUM_ACCEL-1) begin
					next_state <= PAUSE;
					accel_count <= 0;
					output_data <= data;
				end
				else begin
					accel_count <= accel_count+1;
					next_state <= READ;
				end
			end
			
			// Pause until next accel sample
			PAUSE: begin
				ncs_r <= 1'b1;
				if (pause_count==PAUSE_LEN-1) begin
					pause_count <= 0;
					next_state <= ADDR;
				end
				else begin
					pause_count <= pause_count+1;
					next_state <= PAUSE;
				end
			end
		endcase
	end
	
//	always @(posedge clk) begin
//		state <= next_state;
//		case (state)
//			READ: begin
//				if (count==MAX_COUNT) begin
//					count <= 1; // Reset count
//					j <= ADDR_LEN-1; // Reset index
//					next_state <= PAUSE2; // Update state
//					output_data <= data; 
//				end
//				else begin
//					data[j] <= miso;
//					count <= count+1;
//					next_state <= READ; // Update state
//					j <= j-1;
//				end
//			end
//			PAUSE2: begin
//				if (count==PAUSE_LEN) begin
//					count <= 1;
//					next_state <= ADDR;
//				end
//				else begin
//					count <= count+1;
//					next_state <= PAUSE2;
//				end
//			end
//		end
//	end

endmodule

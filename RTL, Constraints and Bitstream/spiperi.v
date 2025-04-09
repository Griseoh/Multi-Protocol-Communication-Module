`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2025 09:00:32 PM
// Design Name: 
// Module Name: spiperi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spiperi(clk, sclk, mosi, mode, cs, rcvd_p_dat);
    input clk, sclk, mosi, cs;
    input [1:0] mode = 0;
    output [7:0]rcvd_p_dat;
    
    wire [7:0] posedge_dat, negedge_dat;
    spiperipos sppp(clk, sclk, mosi, (mode == 0 || mode == 3) ? cs : 1'b1, posedge_dat);
    spiperineg sppn(clk, sclk, mosi, (mode == 1 || mode == 2) ? cs : 1'b1, negedge_dat);
    assign rcvd_p_dat = (mode == 1 || mode == 2) ? negedge_dat : posedge_dat;
endmodule

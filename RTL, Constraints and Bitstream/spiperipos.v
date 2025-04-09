`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2025 05:06:18 PM
// Design Name: 
// Module Name: spiperipos
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


module spiperipos(clk, sclk, mosi, cs, rcvd_p_dat);
    input clk, sclk, mosi, cs;
    output reg [7:0]rcvd_p_dat;
    reg [7:0]mosi_p_dat0 = 0;
    reg [3:0]count0 = 0;
    reg sclk_d = 0;
    wire sclk_r = (sclk == 1 && sclk_d == 0);
    
    always @(posedge clk)begin
        sclk_d <= sclk;
        if(cs == 0 && sclk_r)begin
            count0 <= 0;
            mosi_p_dat0 <= 0;
            if(count0 <8)begin
                mosi_p_dat0 <= {mosi_p_dat0[6:0],mosi};
                count0 <= count0 + 1'b1;
            end
            else begin
                count0 <= 0;
            end
        end
    end
    
    always @(*)begin
        rcvd_p_dat = mosi_p_dat0;
    end
endmodule

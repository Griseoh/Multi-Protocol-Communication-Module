`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2025 05:06:18 PM
// Design Name: 
// Module Name: spiperineg
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


module spiperineg(clk, sclk, mosi, cs, rcvd_p_dat);
    input clk, sclk, mosi, cs;
    output reg [7:0]rcvd_p_dat;
    reg [7:0]mosi_p_dat1 = 0;
    reg [3:0]count1 = 0;
    reg sclk_d = 0;
    wire sclk_f = (sclk == 0 && sclk_d == 1);
    
    always @(negedge clk)begin
        sclk_d <= sclk;
        if(cs == 0 && sclk_f)begin
            count1 <= 0;
            mosi_p_dat1 <= 0;
            if(count1 <8)begin
                mosi_p_dat1 <= {mosi_p_dat1[6:0],mosi};
                count1 <= count1 + 1'b1;
            end
            else begin
                count1 <= 0;
            end
        end
    end
    
    always @(*)begin
        rcvd_p_dat = mosi_p_dat1;
    end
endmodule

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


module spiperi(sclk, mosi, mode, cs, rcvd_p_dat);
    input sclk, mosi, cs;
    input [1:0] mode = 0;
    output [7:0]rcvd_p_dat;
    reg [7:0]mosi_p_dat0;
    reg [7:0]mosi_p_dat1;
    reg [3:0]count0;
    reg [3:0]count1;
    //mode 0 and mode 3 logic
    always @(posedge sclk)begin
        if((cs == 0) && (mode == 0 || mode == 3))begin
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
    //mode 1 and mode 2 logic
    always @(negedge sclk)begin
        if((cs == 0) && (mode == 1 || mode == 2))begin
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
       
    assign rcvd_p_dat =  (mode == 1 || mode == 2) ? mosi_p_dat0 : mosi_p_dat1;
endmodule

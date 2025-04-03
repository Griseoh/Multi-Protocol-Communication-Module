`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2025 04:53:38 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(clk, rst, rx, rx_done, rx_dat);
    input clk, rst;
    input rx;
    output reg rx_done;
    output reg [7:0]rx_dat;
    parameter clk_freq = 50000000;
    parameter baud_rate = 9600;
    parameter clk_cnt = clk_freq/baud_rate;
    reg uclk = 0;
    reg [3:0]bit_cnt = 0;
    reg [12:0]cnt = 0;
    parameter IDLE = 1'b0, START = 1'b1;
    reg state;
    //UART Clock Generation
    always @(posedge clk)begin
        if(cnt < clk_cnt/2)begin
            cnt <= cnt + 1;
        end
        else begin
            cnt <= 0;
            uclk <= ~uclk;
        end
    end
    //Receiver FSM Logic
    always @(posedge uclk)begin
        if(rst)begin
            rx_dat <= 8'b00000000;
            bit_cnt <= 0;
            rx_done <= 1'b0;
        end
        else begin
            case(state)
                IDLE:begin
                    rx_dat <= 8'b00000000;
                    bit_cnt <= 0;
                    rx_done <= 1'b0;
                    if(rx == 1'b0)begin
                        state <= START;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                START:begin
                    if(bit_cnt <= 7)begin
                        bit_cnt <= bit_cnt + 1;
                        rx_dat <= {rx,rx_dat[7:1]};
                    end
                    else begin
                        bit_cnt <= 0;
                        rx_done <= 1'b1;
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

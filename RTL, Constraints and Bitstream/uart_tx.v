`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2025 01:18:27 AM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(clk, rst, new_dat, tx_dat, tx, tx_done);
    input clk, rst;
    input new_dat;
    input [7:0]tx_dat;
    output reg tx;
    output reg tx_done;
    reg [7:0]dat_in = 0;
    parameter clk_freq = 125000000;
    parameter baud_rate = 62500;
    parameter clk_cnt = (clk_freq/baud_rate);
    reg [12:0]cnt = 0;
    reg [3:0]bit_cnt = 0;
    reg uclk = 0;
    parameter IDLE = 1'b0, TRANSFER = 1'b1;
    reg state = 0;
    //UART Clock Generation
    always @(posedge clk)begin
        if(rst)begin
            cnt <= 13'b0;
            uclk <= 1'b0;
        end
        else if(cnt == clk_cnt - 1'b1)begin
            cnt <= 13'b0;
            uclk <= 1'b1;
        end
        else begin
            cnt <= cnt + 1'b1;
            uclk <= 1'b0;
        end
    end
    //Reset Handler and FSM Logic
    always @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
            bit_cnt <= 0;
            tx_done <= 1'b0;
            tx <= 1'b1;
        end
        else begin
            if (uclk)begin
                case(state)
                    IDLE:begin
                        bit_cnt <= 0;
                        tx <= 1'b1;
                        tx_done <= 1'b0;
                        if(new_dat)begin
                            state <= TRANSFER;
                            dat_in <= tx_dat;
                            tx <= 1'b0;
                        end
                        else begin
                            state <= IDLE;
                        end
                    end
                    TRANSFER:begin
                        if(bit_cnt <= 7)begin
                            bit_cnt <= bit_cnt + 1;
                            tx <= dat_in[bit_cnt];
                            state <= TRANSFER;
                        end
                        else begin
                            bit_cnt <= 0;
                            tx <= 1'b1;
                            state <= IDLE;
                            tx_done <= 1'b1;
                        end
                    end
                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule

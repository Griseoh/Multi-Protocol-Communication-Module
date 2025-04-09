`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2025 05:14:01 PM
// Design Name: 
// Module Name: uart_top
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


module uart_top(clk, rst, new_dat, dat_in, dat_out, tx_done, rx_done);
    input clk,rst;
    input new_dat;
    input [7:0]dat_in;
    output [7:0]dat_out;
    output tx_done, rx_done;
    wire serial_data;
    
    uart_tx utx(clk, rst, new_dat, dat_in, serial_data, tx_done);
    uart_rx urx(clk, rst, serial_data, rx_done, dat_out);
endmodule

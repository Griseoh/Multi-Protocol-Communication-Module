`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2025 06:27:19 PM
// Design Name: 
// Module Name: multi_module_top
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


module multi_module_top(
    input clk, rst,
    input load, i2c_op,
    input [6:0]i2c_addr,
    input [7:0]p_dat,
    input [1:0]prot_sel,
    input [1:0]spi_mode,
    output [7:0] rcvd_dat_spi, rcvd_dat_uart,
    output i2c_s_ack_err, sdone, utdone, urdone, mdone,
    output i2c_master_busy, i2c_m_ack_err,
    output [7:0]i2c_read_dat
    );
    
    wire s_dat_spi, s_dat_uart, i2c_s_dat, sclk, cs, i2c_sclk;
    wire [1:0]mode;
    
    master_transmitter mt(clk, rst, prot_sel, p_dat, load, i2c_op, i2c_addr, i2c_read_dat, i2c_master_busy, i2c_m_ack_err, i2c_s_dat, i2c_sclk, spi_mode, cs, mode, sclk, s_dat_spi, s_dat_uart, utdone, mdone);
    master_receiver mr(clk, rst, prot_sel, cs, mode, sclk, i2c_sclk, i2c_s_dat, i2c_s_ack_err, sdone, urdone, s_dat_spi, s_dat_uart, rcvd_dat_spi, rcvd_dat_uart);
endmodule

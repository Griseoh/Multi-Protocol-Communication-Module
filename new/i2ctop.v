`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 10:07:59 PM
// Design Name: 
// Module Name: i2ctop
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


module i2ctop(clk, rst, new_dat, addr, r_w, dat_in, dat_out, busy, ack_err, done);
    input clk, rst, new_dat, r_w;
    input [6:0]addr;
    input [7:0]dat_in;
    output [7:0]dat_out;
    output busy, ack_err, done;
    
    wire sda, sclk;
    wire sda_m_out, sda_s_out;
    wire msda_en, ssda_en;
    wire ack_errm, ack_errs, donem, dones;
    
    i2cmaster master(clk, rst, new_dat, addr, r_w, sda, sclk, dat_in, dat_out, busy, ack_errm, donem, msda_en, sda_m_out);
    i2cslave slave(sclk, clk, rst, sda, ack_errs, dones, ssda_en, sda_s_out);
    assign ack_err = ack_errm | ack_errs;
    assign done = donem | dones;
    assign sda = (msda_en) ? sda_m_out : (ssda_en) ? sda_s_out : 1'bz;
endmodule

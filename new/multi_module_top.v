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
    output [7:0] rcvd_dat,
    output i2c_done, utdone, urdone,
    output i2c_master_busy, i2c_ack_err,
    output [7:0]i2c_read_dat,
    output no_load
    );
    reg load_standby = 1'b1;
    reg [3:0] out;
    wire [7:0] spi_rcvd_dat, uart_rcvd_dat;
    wire spi_load = out[3];
    wire uart_load = out[2];
    wire i2c_load = out[1];
    assign no_load = out[0];
    
    always @(*)begin
        case (prot_sel)
            2'b00 : out = {3'b000, load_standby};
            2'b01 : out = {2'b00, load_standby, 1'b0};
            2'b10 : out = {1'b0, load_standby, 2'b00};
            2'b11 : out = {load_standby, 3'b000};
            default : out = {3'b000, load_standby}; 
        endcase
    end
    
    i2ctop i2cprot(clk, rst, (i2c_load & load), i2c_addr, i2c_op, p_dat, i2c_read_dat, i2c_master_busy, i2c_ack_err, i2c_done);
    spi_top spiprot(clk, spi_mode[1], spi_mode[0], (spi_load & load), p_dat, spi_rcvd_dat);
    uart_top uartprot(clk, rst, (uart_load & load), p_dat, uart_rcvd_dat, utdone, urdone);
    
    assign rcvd_dat = (spi_rcvd_dat | uart_rcvd_dat);
endmodule
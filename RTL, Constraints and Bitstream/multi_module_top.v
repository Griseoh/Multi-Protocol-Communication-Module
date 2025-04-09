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
    output i2cm_done, i2cs_done, utdone, urdone,
    output i2c_master_busy, i2c_ack_err,
    output [7:0]i2c_read_dat,
    output no_load
    );
    reg load_standby = 1'b1;
    wire [7:0] spi_rcvd_dat, uart_rcvd_dat;
    wire spi_load;
    wire uart_load;
    wire i2c_load;
    
    assign no_load   = (prot_sel == 2'b00) ? load_standby : 1'b0;
    assign spi_load  = (prot_sel == 2'b01) ? load_standby : 1'b0;
    assign uart_load = (prot_sel == 2'b10) ? load_standby : 1'b0;
    assign i2c_load  = (prot_sel == 2'b11) ? load_standby : 1'b0;
    
    i2ctop i2cprot(clk, rst, (i2c_load & load), i2c_addr, i2c_op, p_dat, i2c_read_dat, i2c_master_busy, i2c_ack_err, i2cs_done, i2cm_done);
    spi_top spiprot(clk, spi_mode[1], spi_mode[0], (spi_load & load), p_dat, spi_rcvd_dat);
    uart_top uartprot(clk, rst, (uart_load & load), p_dat, uart_rcvd_dat, utdone, urdone);
    
    assign rcvd_dat = (prot_sel == 2'b01) ? spi_rcvd_dat : (prot_sel == 2'b10) ? uart_rcvd_dat : (prot_sel == 2'b11) ? i2c_read_dat : 8'd0;
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2025 05:13:26 PM
// Design Name: 
// Module Name: master_transmitter
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


module master_transmitter(clk, rst, prot_sel, p_dat, load, i2c_op, i2c_addr, i2c_read_dat, i2c_master_busy, i2c_m_ack_err, i2c_s_dat, i2c_sclk, spi_mode, cs, mode, sclk, s_dat_spi, s_dat_uart, utdone, mdone);
    input clk, rst;
    input load, i2c_op;
    input [6:0]i2c_addr;
    input [7:0]p_dat;
    input [1:0]prot_sel;
    input [1:0]spi_mode;
    output s_dat_spi, s_dat_uart;
    inout i2c_s_dat;
    output i2c_master_busy, i2c_m_ack_err;
    output [7:0]i2c_read_dat;
    output sclk, cs, i2c_sclk;
    output [1:0]mode;
    output utdone, mdone;
    
    reg clk_spi, clk_i2c, clk_uart;
    parameter DEFAULT  = 2'b00, SPI = 2'b01, I2C = 2'b10, UART = 2'b11;
    //Clock Gating Logic
    always @(*)begin
        case(prot_sel)
            DEFAULT:begin
               clk_spi = 0;
                clk_i2c = 0;
                clk_uart = 0; 
            end
            SPI:begin
                clk_spi = clk;
                clk_i2c = 0;
                clk_uart = 0;
            end
            I2C:begin
                clk_spi = 0;
                clk_i2c = clk;
                clk_uart = 0;
            end
            UART:begin
                clk_spi = 0;
                clk_i2c = 0;
                clk_uart = clk;
            end
            default:begin
                clk_spi = 0;
                clk_i2c = 0;
                clk_uart = 0;
            end
        endcase
    end
    
    spigen spg(clk_spi, spi_mode[1], spi_mode[0], load, p_dat, s_dat_spi, sclk, cs, mode);
    i2cmaster i2cm(clk_i2c, rst, load, i2c_addr, i2c_op, i2c_s_dat, i2c_sclk, p_dat, i2c_read_dat, i2c_master_busy, i2c_m_ack_err, mdone);
    uart_tx utx(clk_uart, rst, load, p_dat, s_dat_uart, utdone);
endmodule
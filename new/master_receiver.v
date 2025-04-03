`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2025 05:53:13 PM
// Design Name: 
// Module Name: master_receiver
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


module master_receiver(clk, rst, prot_sel, cs, mode, sclk, i2c_sclk, i2c_s_dat, i2c_s_ack_err, sdone, urdone, s_dat_spi, s_dat_uart, rcvd_dat_spi, rcvd_dat_uart);
    input clk, rst;
    input cs, sclk;
    input [1:0]mode;
    input [1:0]prot_sel;
    input s_dat_spi, s_dat_uart;
    inout i2c_s_dat;
    input i2c_sclk;
    output [7:0] rcvd_dat_spi, rcvd_dat_uart;
    output i2c_s_ack_err, sdone, urdone;
    
    reg clk_i2c, clk_uart;
    parameter DEFAULT  = 2'b00, SPI = 2'b01, I2C = 2'b10, UART = 2'b11;
    //Clock Gating Logic
    always @(*)begin
        case(prot_sel)
            DEFAULT:begin
                clk_i2c = 0;
                clk_uart = 0; 
            end
            SPI:begin
                clk_i2c = 0;
                clk_uart = 0;
            end
            I2C:begin
                clk_i2c = clk;
                clk_uart = 0;
            end
            UART:begin
                clk_i2c = 0;
                clk_uart = clk;
            end
            default:begin
                clk_i2c = 0;
                clk_uart = 0;
            end
        endcase
    end
    
    spiperi spp(sclk, s_dat_spi, mode, cs, rcvd_dat_spi);
    i2cslave i2cs(i2c_sclk, clk_i2c, rst, i2c_s_dat, i2c_s_ack_err, sdone);
    uart_rx urx(clk_uart, rst, s_dat_uart, urdone, rcvd_dat_uart);
    
endmodule

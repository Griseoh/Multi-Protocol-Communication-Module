`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 09:59:42 PM
// Design Name: 
// Module Name: top_tb
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


module top_tb;
    reg clk, rst;
    reg load, i2c_op;
    reg [6:0]i2c_addr;
    reg [7:0]p_dat;
    reg [1:0]prot_sel;
    reg [1:0]spi_mode;
    wire [7:0] rcvd_dat;
    wire i2cm_done, i2cs_done, utdone, urdone;
    wire i2c_master_busy, i2c_ack_err;
    wire [7:0]i2c_read_dat;
    wire no_load;
    
    multi_module_top dut (clk, rst,
                          load, i2c_op,
                          i2c_addr,
                          p_dat,
                          prot_sel,
                          spi_mode,
                          rcvd_dat,
                          i2cm_done, i2cs_done, utdone, urdone,
                          i2c_master_busy, i2c_ack_err,
                          i2c_read_dat,
                          no_load);
    
    always #4 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 1;
        spi_mode = 2'b00;
        load = 1'b0;
        i2c_op = 1'b0;
        i2c_addr = 7'd0;
        p_dat = 8'b01010101;
        prot_sel = 2'b00;
        repeat(25)@(posedge clk)
        rst = 0;
        prot_sel = 2'b01;    
        repeat(5)@(posedge clk);
        load = 1;
        repeat(1)@(posedge clk);
        load = 0;
        repeat(45)@(posedge clk);
        spi_mode = 2'b10;
        p_dat = 8'b01000010;
        load = 1;
        repeat(1)@(posedge clk);
        load = 0;
        repeat(50)@(posedge clk);
        prot_sel = 2'b10;
        p_dat = 8'b11101110;
        load = 1;
        repeat(2)@(posedge dut.uartprot.utx.uclk);
        load = 0;
        wait(utdone);
        wait(urdone);
        repeat(5)@(posedge clk);
        p_dat = 8'b01101100;
        load = 1;
        repeat(2)@(posedge dut.uartprot.utx.uclk);
        load = 0;
        wait(utdone);
        wait(urdone);
        repeat(5)@(posedge clk)
        prot_sel = 2'b11;
        repeat(5)@(posedge clk);
        load = 1;
        i2c_op = 1;
        i2c_addr = 7'b0000011;
        p_dat = 8'd0;
        wait(i2cs_done);
        repeat(5000)@(posedge clk);
        repeat(5)@(posedge clk);
        rst = 1;
        load = 0;
        prot_sel = 2'b00;
        repeat(10)@(posedge clk);
        $stop;
    end
endmodule

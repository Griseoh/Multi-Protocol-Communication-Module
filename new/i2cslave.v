`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 01:52:31 PM
// Design Name: 
// Module Name: i2cslave
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


module i2cslave(sclk, clk, rst, sda, ack_err, done);
    input sclk, clk, rst;
    inout sda;
    output reg ack_err, done;
    
    reg r_ack;
    reg [3:0]state;
    parameter IDLE = 0, READ_ADDR = 1, SEND_ACK = 2, SEND_DATA = 3, MASTER_ACK = 4, READ_DATA = 5, SEND_ACK_2 = 6, WAIT = 7, DETECT_STOP = 8;
    reg [7:0]memory_bank[7:0];
    reg [7:0]r_addr;
    reg [6:0]addr;
    reg r_mem = 0;
    reg w_mem = 0;
    reg [7:0]dat_in;
    reg [7:0]dat_out;
    reg buf_sda;
    reg sda_en;
    reg [3:0]bit_cnt = 0;
    reg [3:0]mem_cnt = 0;
    parameter board_freq = 50000000;
    parameter i2c_freq = 125000;
    parameter single_bit_dur = (board_freq/i2c_freq); //-> 400
    parameter delta = single_bit_dur/4; //-> 100
    reg [8:0]count = 0;
    reg i2c_clk = 0;
    reg [1:0]pulse = 0;
    reg busy = 0;
    //Initializing Memory Bank
    always @(posedge clk)begin
        if(rst)begin
            for(mem_cnt = 0; mem_cnt < 8; mem_cnt = mem_cnt + 1)begin
                memory_bank[mem_cnt] = mem_cnt;
            end
            dat_out <= 8'b00000000;
        end
        else if(r_mem == 1'b1)begin
            dat_out <= memory_bank[addr];
        end
        else if(w_mem == 1'b1)begin
            memory_bank[addr] <= dat_in;
        end
    end
    //Pulse Generation Logic
    always @(posedge clk)begin
        if(rst)begin
            pulse <= 0;
            count <= 0;
        end
        else if(busy == 1'b0)begin
            pulse <= 2;
            count <= 202;
        end
        else if(count == delta - 1)begin
            pulse <= 1;
            count <= count + 1;
        end
        else if(count == delta*2 - 1)begin
            pulse <= 2;
            count <= count + 1;
        end
        else if(count == delta*3 - 1)begin
            pulse <= 3;
            count <= count + 1;
        end
        else if(count == delta*4 - 1)begin
            pulse <= 0;
            count <= 0;
        end
        else begin
            count <= count + 1;
        end
    end 
    //Slave FSM Logic
    always @(posedge clk)
    begin
        if(rst)begin
            bit_cnt <= 0;
            state <= IDLE;
            r_addr <= 7'b0000000;
            sda_en <= 1'b0;
            buf_sda <= 1'b0;
            addr <= 0;
            r_mem <= 0;
            dat_in <= 8'b00000000;
            ack_err <= 0;
            done <= 1'b0;
            busy <= 1'b0;
        end
        else begin
            case(state)
                IDLE:begin
                    if(sclk == 1'b1 && sda == 1'b0)begin
                        busy <= 1'b1;
                        state <= WAIT;
                    end
                    else begin
                        state <= IDLE;
                    end                  
                end
                READ_ADDR:begin
                    sda_en <= 1'b0;
                    if(bit_cnt <= 7)begin
                        case(pulse)
                            0:begin
                            end
                            1:begin
                            end
                            2:begin
                                r_addr <= (count == 200)?{r_addr[6:0], sda}: r_addr;
                            end
                            3:begin
                            end
                        endcase
                        if(count == delta*4 -1)begin
                            state <= READ_ADDR;
                            bit_cnt <= bit_cnt + 1;
                        end
                        else begin
                            state <= READ_ADDR;
                        end
                    end
                    else begin
                        state <= SEND_ACK;
                        bit_cnt <= 0;
                        sda_en <= 1'b1;
                        addr <= r_addr[7:1];
                    end
                end
                SEND_ACK:begin
                    case(pulse)
                        0:begin
                            buf_sda <= 1'b0;
                        end
                        1:begin
                        end
                        2:begin
                        end
                        3:begin
                        end
                    endcase
                    if(count == delta*4 - 1)begin
                        if(r_addr[0] == 1'b1)begin
                            state <= SEND_DATA;
                            r_mem <= 1'b1;
                        end
                        else begin
                            state <= READ_DATA;
                            r_mem <= 1'b0;
                        end
                    end
                    else begin
                        state <= SEND_ACK;
                    end
                end
                SEND_DATA:begin
                    sda_en <= 1'b1;
                    if(bit_cnt <= 7)begin
                        r_mem <= 1'b0;
                        case(pulse)
                            0:begin
                            end
                            1:begin
                                buf_sda <= (count == 100)? dat_out[7 - bit_cnt]: buf_sda;
                            end
                            2:begin
                            end
                            3:begin
                            end
                        endcase
                        if(count == delta*4 - 1)begin
                            state <= SEND_DATA;
                            bit_cnt <= bit_cnt + 1;
                        end
                        else begin
                            state <= SEND_DATA;
                        end
                    end
                    else begin
                        state <= MASTER_ACK;
                        bit_cnt <= 0;
                        sda_en <= 1'b0;
                    end
                end
                MASTER_ACK:begin
                    case(pulse)
                        0:begin
                        end
                        1:begin
                        end
                        2:begin
                            r_ack <= (count == 200)? sda : r_ack;
                        end
                        3:begin
                        end
                    endcase
                    if(count == delta*4 - 1)begin
                        if(r_ack == 1'b1)begin
                            ack_err <= 1'b0;
                            state <= DETECT_STOP;
                            sda_en <= 1'b0;
                        end
                        else begin
                            ack_err <= 1'b1;
                            state <= DETECT_STOP;
                            sda_en <= 1'b0;
                        end
                    end
                    else begin
                        state <= MASTER_ACK;
                    end
                end
                READ_DATA:begin
                    sda_en <= 1'b0;
                    if(bit_cnt <= 7)begin
                        case(pulse)
                            0:begin
                            end
                            1:begin
                            end
                            2:begin
                                dat_in <= (count == 200)?{dat_in[6:0], sda}: dat_in;
                            end
                            3:begin
                            end
                        endcase
                        if(count == delta*4 - 1)begin
                            state <= READ_DATA;
                            bit_cnt <= bit_cnt + 1;
                        end
                        else begin
                            state <= READ_DATA;
                        end
                    end
                    else begin
                        state <= SEND_ACK_2;
                        bit_cnt <= 0;
                        sda_en <= 1'b1;
                        w_mem <= 1'b1;
                    end
                end
                SEND_ACK_2:begin
                    case(pulse)
                        0:begin
                            buf_sda <= 1'b0;
                        end
                        1:begin
                            w_mem <= 1'b0;
                        end
                        2:begin
                        end
                        3:begin
                        end
                    endcase
                    if(count == delta*4 - 1)begin
                        state <= DETECT_STOP;
                        sda_en <= 1'b0;
                    end
                    else begin
                        state <= SEND_ACK_2;
                    end
                end
                WAIT:begin
                    if(pulse == 2'b11 && count == 399)begin
                        state <= READ_ADDR;
                    end
                    else begin
                        state <= WAIT;
                    end
                end
                DETECT_STOP:begin
                    if(pulse == 2'b11 && count == 399)begin
                        state <= IDLE;
                        busy <= 1'b0;
                        done <= 1'b1;
                    end
                    else begin
                        state <= DETECT_STOP;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
    
    assign sda = (sda_en == 1'b1)? buf_sda : 1'bz;
endmodule

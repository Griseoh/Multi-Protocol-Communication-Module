`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 01:52:31 PM
// Design Name: 
// Module Name: i2cmaster
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


module i2cmaster(clk, rst, new_dat, addr, r_w, sda, scl, dat_in, dat_out, busy, ack_err, done, master_sda_en, msda_buffer);
    input clk, rst, new_dat;
    input [6:0]addr;
    input r_w;
    input sda;
    output scl;
    input [7:0]dat_in;
    output [7:0]dat_out;
    output reg busy, ack_err, done;
    output master_sda_en;
    output msda_buffer;
    reg buf_scl = 0;
    reg buf_sda = 0;
    reg [3:0]bit_cnt = 0;
    reg[7:0]data_addr = 0, data_tx = 0;
    reg r_ack = 0;
    reg [7:0]data_rx = 0;
    reg m_sda_en = 0;
    parameter board_freq = 125000000;
    parameter i2c_freq = 312500;
    parameter single_bit_dur = (board_freq/i2c_freq); //-> 400
    parameter delta = single_bit_dur/4; //-> 100
    parameter IDLE = 0, START = 1, WRITE_ADDR = 2, ACK = 3, WRITE_DATA = 4, READ_DATA = 5, STOP = 6, ACK_2 = 7, MASTER_ACK = 8;
    reg [3:0]state = IDLE;
    reg [8:0]count = 0;
    reg i2c_clk = 0;
    reg [1:0]pulse = 0;
    //Pulse Generation Logic
    always @(posedge clk or posedge rst)begin
        if(rst)begin
            pulse <= 0;
            count <= 0;
        end
        else if(busy == 1'b0)begin
            pulse <= 0;
            count <= 0;
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
            count <= count +1;
        end
        else if(count == delta*4 -1)begin
            pulse <= 0;
            count <= 0;
        end
        else begin
            count <= count + 1;
        end
    end
    //Master FSM Logic
    always @(posedge clk or posedge rst)begin
        if(rst)begin
            bit_cnt <= 0;
            data_addr <= 0;
            data_tx <= 0;
            buf_scl <= 1;
            buf_sda <= 1;
            state <= IDLE;
            busy <= 1'b0;
            ack_err <= 1'b0;
            done <= 1'b0; 
        end
        else begin
            case(state)
                IDLE:begin
                    done <= 1'b0;
                    if(new_dat == 1'b1)begin
                        data_addr <= {addr,r_w};
                        data_tx <= dat_in;
                        buf_sda <= 1'b0;
                        busy <= 1'b1;
                        state <= START;
                        ack_err <= 1'b0;
                    end
                    else begin
                        data_addr <= 0;
                        data_tx <= 0;
                        buf_sda <= 1'b0;
                        busy <= 1'b0;
                        state <= IDLE;
                        ack_err <= 1'b0;
                    end
                end
                START:begin
                    m_sda_en <= 1'b1;
                    case(pulse)
                        0:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b1;
                        end
                        1:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b1;                        
                        end
                        2:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b0;
                        end
                        3:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b0;
                        end
                    endcase
                        if(count == delta*4 - 1)begin
                            state <= WRITE_ADDR;
                            buf_scl <= 1'b0;
                        end
                        else
                            state <= START;
                end
                WRITE_ADDR:begin
                    m_sda_en <= 1'b1;
                    if(bit_cnt <= 7)begin
                        case(pulse)
                            0:begin
                                buf_scl <= 1'b0;
                                buf_sda <= 1'b0;
                            end
                            1:begin
                                buf_scl <= 1'b0;
                                buf_sda <= data_addr[7 - bit_cnt];
                            end
                            2:begin
                                buf_scl <= 1'b1;
                            end
                            3:begin
                                buf_scl <= 1'b1;
                            end
                        endcase
                        if(count == delta*4 - 1)begin
                            state <= WRITE_ADDR;
                            buf_scl <= 1'b0;
                            bit_cnt <= bit_cnt + 1;
                        end
                        else begin
                            state <= WRITE_ADDR;
                        end
                    end
                    else begin
                        state <= ACK;
                        bit_cnt <= 0;
                        m_sda_en <= 1'b0;
                    end
                end
                ACK:begin
                    m_sda_en <= 1'b0;
                    case(pulse)    
                        0:begin
                            buf_scl <= 1'b0;
                            buf_sda <= 1'b0;
                        end
                        1:begin
                            buf_scl <= 1'b0;
                            buf_sda <= 1'b0;
                        end
                        2:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b0;
                            r_ack <= sda;
                        end
                        3:begin
                            buf_scl <= 1'b1;
                        end
                    endcase
                    if(count == delta*4 - 1)begin
                        if(r_ack == 1'b0 && data_addr[0] == 1'b0)begin
                            state <= WRITE_DATA;
                            buf_sda <= 1'b0;
                            m_sda_en <= 1'b1;
                            bit_cnt <= 0;
                        end
                        else if(r_ack == 1'b0 && data_addr[0] == 1'b1)begin
                            state <= READ_DATA;
                            buf_sda <= 1'b1;
                            m_sda_en <= 1'b0;
                            bit_cnt <= 0;
                        end
                        else begin
                            state <= STOP;
                            m_sda_en <= 1'b1;
                            ack_err <= 1'b1;
                        end
                    end
                    else begin
                        state <= ACK;
                    end
                end
                WRITE_DATA:begin
                    if(bit_cnt <= 7)begin
                        case(pulse)
                            0:begin
                                buf_scl <= 1'b0;
                            end
                            1:begin
                                buf_scl <= 1'b0;
                                m_sda_en <= 1'b1;
                                buf_sda <= data_tx[7 - bit_cnt];
                            end
                            2:begin
                                buf_scl <= 1'b1;
                            end
                            3:begin
                                buf_scl <= 1'b1;
                            end
                        endcase
                        if(count == delta*4 - 1)begin
                            state <= WRITE_DATA;
                            buf_scl <= 1'b0;
                            bit_cnt <= bit_cnt + 1;
                        end
                        else begin
                            state <= WRITE_DATA;
                        end
                    end
                    else begin
                        state <= ACK_2;
                        bit_cnt <= 0;
                        m_sda_en <= 1'b0;
                    end
                end
                READ_DATA:begin
                    m_sda_en <= 1'b0;
                    if(bit_cnt <= 7)begin
                        case(pulse)
                            0:begin
                                buf_scl <= 1'b0;
                                buf_sda <= 1'b0;
                            end
                            1:begin
                                buf_scl <= 1'b0;
                                buf_sda <= 1'b0;
                            end
                            2:begin
                                buf_scl <= 1'b1;
                                data_rx[7:0] <= (count == 200)? {data_rx[6:0],sda}: data_rx;
                            end
                            3:begin
                                buf_scl <= 1'b1;
                            end
                        endcase
                        if(count == delta*4 - 1)begin
                            state <= READ_DATA;
                            buf_scl <= 1'b0;
                            bit_cnt <= bit_cnt + 1;
                        end
                        else begin
                            state <= READ_DATA;
                        end
                    end
                    else begin
                        state <= MASTER_ACK;
                        bit_cnt <= 0;
                        m_sda_en <= 1'b1;
                    end
                end
                STOP:begin
                    m_sda_en <= 1'b1;
                    case(pulse)
                        0:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b0;
                        end
                        1:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b0;
                        end
                        2:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b1;
                        end
                        3:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b1;
                        end
                    endcase
                    if(count <= delta*4 - 1)begin
                        state <= IDLE;
                        buf_scl <= 1'b0;
                        busy <= 1'b0;
                        m_sda_en <= 1'b1;
                        done <= 1'b1;
                    end
                    else begin
                        state <= STOP;
                    end
                end
                ACK_2:begin
                    m_sda_en <= 1'b0;
                    case(pulse)
                        0:begin
                            buf_scl <= 1'b0;
                            buf_sda <= 1'b0;
                        end
                        1:begin
                            buf_scl <= 1'b0;
                            buf_sda <= 1'b0;
                        end
                        2:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b0;
                            r_ack <= sda;
                        end
                        3:begin
                            buf_scl <= 1'b1;
                        end
                    endcase
                    if(count <= delta*4 - 1)begin
                        buf_sda <= 1'b0;
                        m_sda_en <= 1'b1;
                        if(r_ack == 1'b0)begin
                            state <= STOP;
                            ack_err <= 1'b0;
                        end
                        else begin
                            state <= STOP;
                            ack_err <= 1'b1; 
                        end
                    end
                    else begin
                        state <= ACK_2;
                    end
                end
                MASTER_ACK:begin
                    m_sda_en <= 1'b1;
                    case(pulse)
                        0:begin
                            buf_scl <= 1'b0;
                            buf_sda <= 1'b1;
                        end
                        1:begin
                            buf_scl <= 1'b0;
                            buf_sda <= 1'b1;
                        end
                        2:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b1;
                        end
                        3:begin
                            buf_scl <= 1'b1;
                            buf_sda <= 1'b1;
                        end
                    endcase
                    if(count == delta*4 - 1)begin
                        buf_sda <= 1'b0;
                        state <= STOP;
                        m_sda_en <= 1'b1;
                    end
                    else begin
                        state <= MASTER_ACK;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
    
    //assign sda = (m_sda_en == 1)?(buf_sda == 0)? 1'b0:1'b1:1'bz;
    assign scl = buf_scl;
    assign dat_out = data_rx;
    assign master_sda_en = m_sda_en;
    assign msda_buffer = buf_sda;
endmodule

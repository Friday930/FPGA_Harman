`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/26 12:34:49
// Design Name: 
// Module Name: dht11_controller
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


module dht11_controller(
    input                       clk,
    input                       rst,
    input                       tick,
    input                       start,
    input   [3:0]               led_m,
    output  [15:0]              humidity,
    output  [15:0]              celcius,
    inout                       dht_io
    );

    parameter                   CNT = 1800, WAIT_CNT = 3, TIME_OUT = 2000;
    localparam                  IDLE = 0, START = 1, WAIT = 2, READ = 3;
    reg [2:0]                   fsm_state, fsm_next;
    reg [$clog2(CNT) - 1:0]     cnt_reg, cnt_next;
    reg                         out_reg, out_next;
    reg                         en_reg, en_next;
    reg                         led_reg, led_next;

    assign                      dht_io = (en_reg) ? out_reg : 1'bz;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            fsm_state <= IDLE;
            cnt_reg <= 0;
            out_reg <= 0;
            en_reg <= 0;
            led_reg <= 0;
        end else begin
            fsm_state <= fsm_next;
            cnt_reg <= cnt_next;
            out_reg <= out_next;
            en_reg <= en_next;
            led_reg <= led_next;
        end
    end

    always @(*) begin
        fsm_state = fsm_next;
        cnt_reg = cnt_next;
        out_reg = out_next;
        en_reg = en_next;
        led_reg = led_next;
        case (fsm_state)
            IDLE: begin
                out_reg = 1;
                if (start) begin
                    fsm_next = START;
                    cnt_next = 0;
                end
            end

            START: begin
                out_reg = 0;
                if (tick) begin
                    if (cnt_reg == CNT - 1) begin
                        fsm_next = WAIT;
                        cnt_next = 0;
                    end else cnt_next = cnt_reg + 1;
                end
            end
            
            WAIT: begin
                out_next = 0;
                if (tick) begin
                    if (cnt_reg == WAIT_CNT - 1) begin
                        fsm_next = READ;
                        cnt_next = 0;
                    end else cnt_next = cnt_reg + 1;
                end
            end
            
            READ: begin
                // output open, High-Z
                en_next = 0;
                if (tick) begin
                    if (cnt_reg == TIME_OUT - 1) begin
                        fsm_next = IDLE;
                        cnt_next = 0;
                    end else cnt_next = cnt_reg + 1;
                end

                if (dht_io == 0) begin
                    led_next = 1;
                end else led_next = 0;
            end
        endcase
    end


endmodule

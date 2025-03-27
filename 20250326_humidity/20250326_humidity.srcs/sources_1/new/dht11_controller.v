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
    // input                       tick,
    input                       start,
    input   [3:0]               led_m,
    output  [15:0]              humidity,
    output  [15:0]              celcius,
    inout                       dht_io
    );

    wire                        tick;
    baud_tick_gen U_Tick(
        .clk                    (clk),
        .reset                  (rst),      
        .tick_1us               (tick) // tick 넣어줘야함
    );

    parameter                   CNT = 1800, WAIT_CNT = 3, SYNC_CNT = 8, DATA_SYNC = 5, DATA_01 = 4, STOP_CNT = 5, TIME_OUT = 2000;
    localparam                  IDLE = 0, START = 1, WAIT = 2, SYNC_LOW = 3, SYNC_HIGH = 4, DATA_IDLE = 5, DATA = 6, STOP = 7;
    reg [2:0]                   fsm_state, fsm_next;
    reg [$clog2(CNT) - 1:0]     cnt_reg, cnt_next;
    reg                         out_reg, out_next;
    reg                         en_reg, en_next; // 0 : read mode
    reg                         led_reg, led_next;
    reg [39:0]                  data_reg, data_next; // shift register

    assign                      dht_io = (en_reg) ? out_reg : 1'bz;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            fsm_state <= IDLE;
            cnt_reg <= 0;
            out_reg <= 0;
            en_reg <= 0;
            led_reg <= 0;
            data_reg <= 0;
        end else begin
            fsm_state <= fsm_next;
            cnt_reg <= cnt_next;
            out_reg <= out_next;
            en_reg <= en_next;
            led_reg <= led_next;
            data_reg <= data_next;
        end
    end

    always @(*) begin
        fsm_next = fsm_state;
        cnt_next = cnt_reg;
        out_next = out_reg;
        en_next = en_reg;
        led_next = led_reg;
        data_next = data_reg;
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
                        fsm_next = SYNC_LOW;
                        cnt_next = 0;
                    end else cnt_next = cnt_reg + 1;
                end
            end
            
            SYNC_LOW: begin
                // output open, High-Z
                en_next = 0;
                if (tick) begin
                    if (cnt_reg == SYNC_CNT - 1) begin
                        fsm_next = SYNC_HIGH;
                        cnt_next = 0;
                    end else cnt_next = cnt_reg + 1;
                end

            end

            SYNC_HIGH: begin
                en_next = 0;
                if (tick) begin
                    if (cnt_reg == SYNC_CNT - 1) begin
                        fsm_next = DATA_IDLE;
                        cnt_next = 0;
                    end else cnt_next = cnt_reg + 1;
                end
            end

            DATA_IDLE: begin
                en_next = 0;
                if (tick) begin
                    if (cnt_reg == DATA_SYNC - 1) begin
                        fsm_next = DATA;
                        cnt_next = 0;
                    end else cnt_next = cnt_reg + 1;
                end
            end

            // 데이터 판별 부분 -> DATA_0이 40보다 작으면 0, 크면 1
            DATA: begin
                en_next = 0;
                if (tick) begin
                    if (cnt_reg <= 40) begin
                        // data_next [bit_count_reg] = 0; -> software적임
                        data_next = {data_reg[39:1],1'b0};
                        fsm_next = STOP;
                    end else begin
                        data_next = {data_reg[39:1],1'b1};
                        fsm_next = STOP;
                    end
                end else fsm_next = SYNC_LOW;
            end

            STOP: begin
                en_next = 1;
                if (tick) begin
                    if (cnt_reg == TIME_OUT) begin
                        fsm_next = IDLE;
                        cnt_next = 0;
                    end else cnt_next = cnt_reg + 1;
                end

                // if (dht_io == 0) begin
                //     led_next = 1;
                // end else led_next = 0;
            end
        endcase
    end
endmodule

module baud_tick_gen(
    input               clk,        // 시스템 클럭 (예: 100MHz)
    input               reset,      // 리셋 신호 (활성 높음)
    output reg          tick_1us    // 1us 마다 발생하는 틱
);

    // 클럭 주파수에 따른 카운터 값 설정
    // 예: 100MHz 클럭에서 1us를 위한 카운트 값 = 100MHz * 0.000001s = 100
    parameter COUNT_MAX = 100;
    
    // 카운터 레지스터
    reg [5:0] counter; // 최대 63까지 카운트 가능
    
    // 카운터 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 6'd0;
            tick_1us <= 1'b0;
        end else begin
            if (counter >= COUNT_MAX - 1) begin
                counter <= 6'd0;
                tick_1us <= 1'b1;  // 1us 마다 틱 발생
            end else begin
                counter <= counter + 1'b1;
                tick_1us <= 1'b0;  // 틱은 1클럭 주기만 유지
            end
        end
    end

endmodule

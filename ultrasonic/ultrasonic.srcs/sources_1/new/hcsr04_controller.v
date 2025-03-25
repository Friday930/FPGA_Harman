`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/25 11:22:24
// Design Name: 
// Module Name: hcsr04_controller
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


module hcsr04_controller(
    input wire clk,           // 시스템 클럭
    input wire reset_n,       // 리셋 신호
    input wire tick_10us,     // 10us 타이머 틱
    input wire echo,          // HC-SR04 에코 핀
    output reg trigger,       // HC-SR04 트리거 핀
    output reg [15:0] distance // 계산된 거리 (mm 단위)
);

    // 상태 정의
    localparam IDLE = 2'b00;
    localparam TRIGGER = 2'b01;
    localparam WAIT_ECHO = 2'b10;
    localparam CALC_DISTANCE = 2'b11;
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    // 내부 카운터와 신호
    reg [3:0] trigger_counter;  // 트리거 펄스 생성용 (10us 단위로 카운트)
    reg [16:0] echo_counter;    // 에코 펄스 길이 측정용 (10us 단위로 카운트)
    
    // 음속 관련 상수
    // 음속: 약 340m/s = 0.34mm/us
    // 거리 = (echo 시간 * 음속) / 2 (왕복 시간이므로 2로 나눔)
    // 10us 단위로 카운트하므로, 1 카운트 = 10us = 3.4mm (왕복 기준)
    // 따라서 거리(mm) = echo_counter * 34 / 20 = echo_counter * 1.7
    
    // 상태 전이 로직
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // 다음 상태 결정 로직
    always @(*) begin
        case (state)
            IDLE: begin
                if (tick_10us)
                    next_state = TRIGGER;
                else
                    next_state = IDLE;
            end
            
            TRIGGER: begin
                if (trigger_counter >= 4'd1) // 10us 트리거 펄스 (최소 10us 필요)
                    next_state = WAIT_ECHO;
                else
                    next_state = TRIGGER;
            end
            
            WAIT_ECHO: begin
                if (echo == 1'b0 && echo_counter > 0) // 에코 펄스 종료
                    next_state = CALC_DISTANCE;
                else if (echo_counter > 17'd29000) // 타임아웃 (약 30cm * 100 = 3m)
                    next_state = IDLE;
                else
                    next_state = WAIT_ECHO;
            end
            
            CALC_DISTANCE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // 트리거 카운터 및 출력 로직
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            trigger_counter <= 4'd0;
            trigger <= 1'b0;
        end else if (state == TRIGGER) begin
            if (tick_10us) begin
                trigger_counter <= trigger_counter + 4'd1;
            end
            trigger <= 1'b1;
        end else begin
            trigger_counter <= 4'd0;
            trigger <= 1'b0;
        end
    end
    
    // 에코 카운터 로직
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            echo_counter <= 17'd0;
        end else if (state == WAIT_ECHO) begin
            if (echo) begin
                if (tick_10us) begin
                    echo_counter <= echo_counter + 17'd1;
                end
            end
        end else if (state == IDLE) begin
            echo_counter <= 17'd0;
        end
    end
    
    // 거리 계산 로직
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            distance <= 16'd0;
        end else if (state == CALC_DISTANCE) begin
            // 거리(mm) = echo_counter * 1.7
            // 곱셉과 나눗셈을 적용하여 계산
            distance <= (echo_counter * 17) / 10;
        end
    end

endmodule

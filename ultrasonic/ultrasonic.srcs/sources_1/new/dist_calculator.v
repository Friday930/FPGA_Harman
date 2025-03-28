`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/25 15:33:08
// Design Name: 
// Module Name: dist_calculator
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


module dist_calculator(
    input               clk,        // 시스템 클럭
    input               reset,      // 리셋 신호 (활성 높음)
    input               tick_1us,   // 1us 타이머 틱
    input               echo,       // HC-SR04 에코 핀
    input               tick_start, // 측정 시작 신호
    output reg [15:0]   dist,       // 계산된 거리 (cm 단위)
    output reg          done        // 측정 완료 신호
);
    // 상태 정의
    localparam IDLE = 2'b00;
    localparam HIGH_LEVEL_COUNT = 2'b01;
    localparam DIST_CALC = 2'b10;
    localparam DONE_STATE = 2'b11;
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    // 에코 펄스 카운터
    reg [19:0] echo_time_counter; // 최대 1,048,575us까지 카운트 가능
    
    // 에코 타임아웃 (38ms = 최대 약 6.5m)
    parameter ECHO_TIMEOUT = 38000;
    
    // 에코 신호 샘플링을 위한 레지스터
    reg echo_reg1, echo_reg2;
    wire echo_rising, echo_falling;
    
    // 에코 신호 에지 감지
    always @(posedge clk) begin
        if (reset) begin
            echo_reg1 <= 1'b0;
            echo_reg2 <= 1'b0;
        end else begin
            echo_reg1 <= echo;
            echo_reg2 <= echo_reg1;
        end
    end
    
    assign echo_rising = echo_reg1 & ~echo_reg2;   // 상승 에지
    assign echo_falling = ~echo_reg1 & echo_reg2;  // 하강 에지
    
    // 상태 전이 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // 다음 상태 결정 로직
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (tick_start)
                    next_state = HIGH_LEVEL_COUNT;
            end
            
            HIGH_LEVEL_COUNT: begin
                if ((echo_falling && echo_time_counter > 0) || echo_time_counter >= ECHO_TIMEOUT)
                    next_state = DIST_CALC;
            end
            
            DIST_CALC: begin
                next_state = DONE_STATE;
            end
            
            DONE_STATE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // 에코 타임 카운터 및 거리 계산 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            echo_time_counter <= 20'd0;
            dist <= 16'd0;
            done <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    echo_time_counter <= 20'd0;
                    done <= 1'b0;
                end
                
                HIGH_LEVEL_COUNT: begin
                    if (echo_reg1 && tick_1us) begin
                        echo_time_counter <= echo_time_counter + 1'b1;
                    end
                end
                
                DIST_CALC: begin
                // 거리 계산: 시간(us) / 58 = 거리(cm)
                // 데이터시트 권장 계산법 사용
                if (echo_time_counter >= ECHO_TIMEOUT) begin
                    dist <= 16'd9999;  // 범위 초과 표시
                end else begin
                    // 정확한 나눗셈 사용
                    dist <= (echo_time_counter * 100) / (58 * 120);
                     
                    // 또는 나눗셈을 근사값으로 최적화할 경우:
                    // dist <= (echo_time_counter * 17) / 1000;  // 0.017 * echo_time_counter
                    end
                end
                
                DONE_STATE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end
endmodule

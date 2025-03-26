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


module hscr04_controller(
    input               clk,        // 시스템 클럭
    input               reset,      // 리셋 신호 (활성 높음)
    input               tick_1us,   // 1us 타이머 틱
    input               btn_start,  // 시작 버튼
    output reg          trigger,    // HC-SR04 트리거 핀
    output reg          tick_start  // 거리 측정 시작 신호
);

    // 상태 정의
    localparam          IDLE = 2'b00;
    localparam          START = 2'b01;
    localparam          WAIT = 2'b10;
    
    reg [1:0]           state;
    reg [1:0]           next_state;
    
    // 트리거 펄스 카운터 (10us 트리거 펄스 생성)
    reg [3:0]           trigger_counter;
    
    // 500ms 대기 타이머 (0.5초)
    reg [19:0]          wait_counter; // 최대 1,048,575까지 카운트 가능
    parameter           WAIT_500MS = 500000; // 500ms = 500,000us
    
    // 버튼 에지 검출을 위한 레지스터
    reg                 btn_start_r1, btn_start_r2;
    wire                btn_start_posedge;
    
    // 버튼 에지 검출 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_start_r1 <= 1'b0;
            btn_start_r2 <= 1'b0;
        end else begin
            btn_start_r1 <= btn_start;
            btn_start_r2 <= btn_start_r1;
        end
    end
    
    // 버튼 상승 에지 검출
    assign btn_start_posedge = btn_start_r1 & ~btn_start_r2;
    
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
                if (btn_start_posedge)
                    next_state = START;
            end
            
            START: begin
                if (trigger_counter >= 4'd10) // 10us 트리거 펄스 완료
                    next_state = WAIT;
            end
            
            WAIT: begin
                if (wait_counter >= WAIT_500MS) // 0.5초 대기 완료
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // 트리거 신호 및 카운터 관리
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            trigger <= 1'b0;
            trigger_counter <= 4'd0;
            wait_counter <= 20'd0;
            tick_start <= 1'b0;
        end else begin
            // 기본값 설정
            tick_start <= 1'b0;
            
            case (state)
                IDLE: begin
                    trigger <= 1'b0;
                    trigger_counter <= 4'd0;
                    wait_counter <= 20'd0;
                    
                    // 버튼 입력 시 즉시 tick_start 활성화
                    if (btn_start_posedge) begin
                        tick_start <= 1'b1;
                    end
                end
                
                START: begin
                    trigger <= 1'b1; // 트리거 펄스 활성화
                    if (tick_1us) begin
                        trigger_counter <= trigger_counter + 1'b1;
                    end
                end
                
                WAIT: begin
                    trigger <= 1'b0; // 트리거 펄스 비활성화
                    trigger_counter <= 4'd0;
                    if (tick_1us) begin
                        wait_counter <= wait_counter + 1'b1;
                    end
                end
            endcase
        end
    end

endmodule

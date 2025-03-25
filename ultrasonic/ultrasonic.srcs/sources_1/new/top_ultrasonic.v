`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/25 10:21:06
// Design Name: 
// Module Name: top_ultrasonic
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


module top_ultrasonic(
    input               clk,        // 시스템 클럭
    input               reset,      // 리셋 신호 (활성 높음)
    input               btn_start,  // 측정 시작 버튼
    input               echo,       // HC-SR04 에코 입력
    output              trigger,    // HC-SR04 트리거 출력
    output [15:0]       dist,       // 계산된 거리 (cm 단위)
    output              done        // 측정 완료 신호
);

    // 내부 신호
    wire                tick_1us;   // 1us 타이머 틱
    wire                tick_start; // FSM 시작 틱
    
    // 1us 타이머 모듈
    baud_tick_gen U_Tick_Gen(
        .clk            (clk),
        .reset          (reset),
        .tick_1us       (tick_1us)
    );
    
    // 초음파 센서 컨트롤러 모듈
    hscr04_controller U_Controller(
        .clk            (clk),
        .reset          (reset),
        .tick_1us       (tick_1us),
        .btn_start      (btn_start),
        .trigger        (trigger),
        .tick_start     (tick_start)
    );
    
    // 거리 계산 모듈
    dist_calculator U_Dist_Calc(
        .clk            (clk),
        .reset          (reset),
        .tick_1us       (tick_1us),
        .echo           (echo),
        .tick_start     (tick_start),
        .dist           (dist),
        .done           (done)
    );

endmodule



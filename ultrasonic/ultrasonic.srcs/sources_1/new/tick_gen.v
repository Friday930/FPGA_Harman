`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/25 10:41:40
// Design Name: 
// Module Name: tick_gen
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


module baud_tick_gen(
    input               clk,        // 시스템 클럭 (예: 50MHz)
    input               reset,      // 리셋 신호 (활성 높음)
    output reg          tick_1us    // 1us 마다 발생하는 틱
);

    // 클럭 주파수에 따른 카운터 값 설정
    // 예: 50MHz 클럭에서 1us를 위한 카운트 값 = 50MHz * 0.000001s = 50
    parameter COUNT_MAX = 50;
    
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

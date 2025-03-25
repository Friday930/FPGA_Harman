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


module tick_gen(
    input wire clk_in,     // 시스템 클럭 입력 (예: 50MHz 또는 100MHz)
    input wire reset,      // 리셋 신호
    output reg tick_10us   // 10us 마다 발생하는 틱 신호
);

    // 클럭 주파수에 따른 카운터 값 설정
    // 예시: 100MHz 클럭에서 10us 틱을 생성하려면 1000 카운트 필요
    // 100MHz = 10ns 주기, 10us / 10ns = 1000
    parameter COUNT_MAX = 1000 - 1;  // 0부터 시작하므로 1 빼기
    
    // 카운터 레지스터
    reg [15:0] counter;
    
    // 카운터 로직
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 16'd0;
            tick_10us <= 1'b0;
        end else begin
            if (counter >= COUNT_MAX) begin
                counter <= 16'd0;
                tick_10us <= 1'b1;  // 10us 마다 틱 발생
            end else begin
                counter <= counter + 1'b1;
                if (counter == 16'd0) begin
                    tick_10us <= 1'b0;  // 틱 신호는 1클럭 주기만 유지
                end
            end
        end
    end

endmodule

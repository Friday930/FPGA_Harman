`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/21 10:23:54
// Design Name: 
// Module Name: uart_CU
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


module uart_CU(
    input               clk,
    input               rst,
    input   [7:0]       loopback,  // UART 수신 데이터 (ASCII 코드)
    output  reg [7:0]   inst   // 명령 출력 (예: "R", "C", "H", "M", "S")
);

    // 레지스터 선언
    reg [7:0] last_loopback;  // 이전 입력 값 저장
    
    // 입력 변화 감지 및 출력 처리
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inst <= 8'b0;
            last_loopback <= 8'b0;
        end
        else begin
            // 입력 값을 이전 입력과 비교하여 변화 감지
            if (loopback != last_loopback) begin
                // 유효한 명령인 경우 출력에 반영
                if (loopback == "R" || loopback == "r")
                    inst <= "R";
                else if (loopback == "C" || loopback == "c")
                    inst <= "C";
                else if (loopback == "H" || loopback == "h")
                    inst <= "H";
                else if (loopback == "M" || loopback == "m")
                    inst <= "M";
                else if (loopback == "S" || loopback == "s")
                    inst <= "S";
                else 
                    inst <= 8'b0;
            end
            else if (loopback == 8'b0) begin
                // 입력이 0이면 출력도 초기화
                inst <= 8'b0;
            end
            
            // 현재 입력 값 저장
            last_loopback <= loopback;
        end
    end

endmodule
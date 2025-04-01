`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/01 11:39:10
// Design Name: 
// Module Name: simple_counter
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

module simple_counter(
    input wire clk,           // 클럭 입력
    input wire reset,         // 리셋 입력 (활성 하이)
    input wire mode,          // 모드 선택 (0: 업 카운터, 1: 다운 카운터)
    output reg [6:0] seg,     // 7-세그먼트 LED 출력 (a~g)
    output wire dp,           // 소수점 출력 (항상 꺼짐)
    output reg [3:0] an       // 애노드 선택 (활성 로우)
);
    // 각 자리 값 (BCD)
    reg [3:0] digit0;  // 일의 자리
    reg [3:0] digit1;  // 십의 자리
    reg [3:0] digit2;  // 백의 자리
    reg [3:0] digit3;  // 천의 자리
    
    // 현재 표시할 자릿수
    reg [1:0] digit_sel;
    
    // 클럭 분주기 (카운팅용)
    reg [26:0] clk_div;
    
    // 디스플레이 스캐닝용 카운터
    reg [16:0] scan_counter;
    
    // 소수점은 항상 꺼짐 (활성 로우에서 1은 꺼짐)
    assign dp = 1'b1;
    
    // 카운팅 속도 조절 (약 1Hz)
    wire count_tick;
    assign count_tick = (clk_div == 27'd10000000);  // 100MHz 기준 1Hz
    
    // 스캐닝 속도 조절 (약 1KHz)
    wire scan_tick;
    assign scan_tick = (scan_counter == 17'd100000);  // 100MHz 기준 1KHz
    
    // 클럭 분주 카운터
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div <= 27'd0;
        end else begin
            if (count_tick)
                clk_div <= 27'd0;
            else
                clk_div <= clk_div + 1'b1;
        end
    end
    
    // 스캐닝용 카운터
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            scan_counter <= 17'd0;
        end else begin
            if (scan_tick)
                scan_counter <= 17'd0;
            else
                scan_counter <= scan_counter + 1'b1;
        end
    end
    
    // 메인 카운터 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // 모드에 따라 초기화
            if (mode == 1'b0) begin
                // 업 카운터는 0000으로 초기화
                digit0 <= 4'd0;
                digit1 <= 4'd0;
                digit2 <= 4'd0;
                digit3 <= 4'd0;
            end else begin
                // 다운 카운터는 9999로 초기화
                digit0 <= 4'd9;
                digit1 <= 4'd9;
                digit2 <= 4'd9;
                digit3 <= 4'd9;
            end
        end else if (count_tick) begin
            if (mode == 1'b0) begin
                // 업 카운터 (0000 → 9999)
                if (digit0 == 4'd9) begin
                    digit0 <= 4'd0;
                    if (digit1 == 4'd9) begin
                        digit1 <= 4'd0;
                        if (digit2 == 4'd9) begin
                            digit2 <= 4'd0;
                            if (digit3 == 4'd9)
                                digit3 <= 4'd0;
                            else
                                digit3 <= digit3 + 1'b1;
                        end else
                            digit2 <= digit2 + 1'b1;
                    end else
                        digit1 <= digit1 + 1'b1;
                end else
                    digit0 <= digit0 + 1'b1;
            end else begin
                // 다운 카운터 (9999 → 0000)
                if (digit0 == 4'd0) begin
                    digit0 <= 4'd9;
                    if (digit1 == 4'd0) begin
                        digit1 <= 4'd9;
                        if (digit2 == 4'd0) begin
                            digit2 <= 4'd9;
                            if (digit3 == 4'd0)
                                digit3 <= 4'd9;
                            else
                                digit3 <= digit3 - 1'b1;
                        end else
                            digit2 <= digit2 - 1'b1;
                    end else
                        digit1 <= digit1 - 1'b1;
                end else
                    digit0 <= digit0 - 1'b1;
            end
        end
    end
    
    // 디스플레이 스캔 카운터
    always @(posedge clk or posedge reset) begin
        if (reset)
            digit_sel <= 2'b00;
        else if (scan_tick)
            digit_sel <= digit_sel + 1'b1;
    end
    
    // 현재 표시할 BCD 값
    reg [3:0] bcd;
    always @* begin
        case (digit_sel)
            2'b00: bcd = digit0;  // 일의 자리
            2'b01: bcd = digit1;  // 십의 자리
            2'b10: bcd = digit2;  // 백의 자리
            2'b11: bcd = digit3;  // 천의 자리
            default: bcd = 4'd0;
        endcase
    end
    
    // 애노드 선택 (활성 로우)
    always @* begin
        case (digit_sel)
            2'b00: an = 4'b1110;  // 오른쪽 첫 번째
            2'b01: an = 4'b1101;  // 오른쪽 두 번째
            2'b10: an = 4'b1011;  // 오른쪽 세 번째
            2'b11: an = 4'b0111;  // 왼쪽 (천의 자리)
            default: an = 4'b1111;  // 모두 끄기
        endcase
    end
    
    // 7-세그먼트 디코더 (공통 애노드 방식, 활성 로우)
    always @* begin
        case (bcd)
            4'd0: seg = 7'b1000000;  // 0
            4'd1: seg = 7'b1111001;  // 1
            4'd2: seg = 7'b0100100;  // 2
            4'd3: seg = 7'b0110000;  // 3
            4'd4: seg = 7'b0011001;  // 4
            4'd5: seg = 7'b0010010;  // 5
            4'd6: seg = 7'b0000010;  // 6
            4'd7: seg = 7'b1111000;  // 7
            4'd8: seg = 7'b0000000;  // 8
            4'd9: seg = 7'b0010000;  // 9
            default: seg = 7'b1111111;  // 모두 끄기
        endcase
    end
    
endmodule
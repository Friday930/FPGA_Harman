`timescale 1ns / 1ps

module clock_cu(
    input       clk, 
    input       reset,
    input       [5:0]  c_sec,
    input       [5:0]  c_minute,
    input       [4:0]  c_hour,
    input       cs,
    output      reg [5:0] o_c_sec,     // 비트 폭 수정 (6비트)
    output      reg [5:0] o_c_minute,  // 비트 폭 수정 (6비트)
    output      reg [4:0] o_c_hour     // 비트 폭 수정 (5비트)
    );

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            o_c_sec <= 0;
            o_c_minute <= 0;
            o_c_hour <= 0;
        end else begin
            // cs를 복제하여 각 시간 비트와 AND 연산
            o_c_sec <= c_sec & {6{cs}};
            o_c_minute <= c_minute & {6{cs}};
            o_c_hour <= c_hour & {5{cs}};
        end
    end
endmodule

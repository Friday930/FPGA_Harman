// `timescale 1ns / 1ps

// module clock_cu(
//     input       clk, 
//     input       reset,
//     input       [5:0]  c_sec,
//     input       [5:0]  c_minute,
//     input       [4:0]  c_hour,
//     input       cs,
//     output      reg [5:0] o_c_sec,     // 비트 폭 수정 (6비트)
//     output      reg [5:0] o_c_minute,  // 비트 폭 수정 (6비트)
//     output      reg [4:0] o_c_hour     // 비트 폭 수정 (5비트)
//     );

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             o_c_sec <= 0;
//             o_c_minute <= 0;
//             o_c_hour <= 0;
//         end else begin
//             // cs를 복제하여 각 시간 비트와 AND 연산
//             o_c_sec <= c_sec & {6{cs}};
//             o_c_minute <= c_minute & {6{cs}};
//             o_c_hour <= c_hour & {5{cs}};
//         end
//     end
// endmodule

`timescale 1ns / 1ps

module clock_cu(
    input           clk, reset,
    input           sec_tick,       // 1Hz tick for automatic time increment
    input           btn_hour,       // Button to increment hour
    input           btn_min,        // Button to increment minute
    input           btn_sec,        // Button to increment second
    input           cs,             // Clock mode enable (1 = clock mode active)
    output reg      [5:0] o_sec,    // 0-59 seconds
    output reg      [5:0] o_minute, // 0-59 minutes
    output reg      [4:0] o_hour    // 0-23 hours
);
    // Edge detection for buttons
    reg btn_hour_prev, btn_min_prev, btn_sec_prev;
    wire hour_pulse, min_pulse, sec_pulse;
    
    // Detect rising edges
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_hour_prev <= 0;
            btn_min_prev <= 0;
            btn_sec_prev <= 0;
        end else begin
            btn_hour_prev <= btn_hour;
            btn_min_prev <= btn_min;
            btn_sec_prev <= btn_sec;
        end
    end
    
    assign hour_pulse = btn_hour & ~btn_hour_prev;
    assign min_pulse = btn_min & ~btn_min_prev;
    assign sec_pulse = btn_sec & ~btn_sec_prev;
    
    // Clock logic - handles both automatic progression and button inputs
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset to 00:00:00
            o_sec <= 0;
            o_minute <= 0;
            o_hour <= 0;
        end else if (cs) begin  // Only active in clock mode
            // Button inputs for manual setting
            if (hour_pulse) begin
                if (o_hour >= 23)
                    o_hour <= 0;
                else
                    o_hour <= o_hour + 1;
            end
            
            if (min_pulse) begin
                if (o_minute >= 59)
                    o_minute <= 0;
                else
                    o_minute <= o_minute + 1;
            end
            
            if (sec_pulse) begin
                if (o_sec >= 59)
                    o_sec <= 0;
                else
                    o_sec <= o_sec + 1;
            end
            
            // Automatic time progression on 1Hz tick
            if (sec_tick) begin
                if (o_sec >= 59) begin
                    o_sec <= 0;
                    
                    // Increment minute when seconds roll over
                    if (o_minute >= 59) begin
                        o_minute <= 0;
                        
                        // Increment hour when minutes roll over
                        if (o_hour >= 23)
                            o_hour <= 0;
                        else
                            o_hour <= o_hour + 1;
                    end else
                        o_minute <= o_minute + 1;
                end else
                    o_sec <= o_sec + 1;
            end
        end
    end
endmodule

module clock_divider #(
    parameter CLOCK_FREQ = 100_000_000  // 보드 클럭 주파수: 100MHz
)(
    input clk,
    input reset,
    output reg o_msec_tick,    // 1ms 펄스
    output reg o_sec_tick,     // 1초 펄스
    output reg o_minute_tick,  // 1분 펄스
    output reg o_hour_tick     // 1시간 펄스
);
    // 1ms에 필요한 클럭 사이클 수
    localparam integer MSEC_COUNT_MAX = CLOCK_FREQ / 1000;
    // 1초에 필요한 클럭 사이클 수
    localparam integer SEC_COUNT_MAX  = CLOCK_FREQ;
    
    // 명시적으로 32비트 카운터 사용
    reg [31:0] msec_count;
    reg [31:0] sec_count;
    reg [5:0]  minute_count;  // 0~59
    reg [4:0]  hour_count;    // 0~23

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            msec_count    <= 0;
            sec_count     <= 0;
            minute_count  <= 0;
            hour_count    <= 0;
            o_msec_tick   <= 0;
            o_sec_tick    <= 0;
            o_minute_tick <= 0;
            o_hour_tick   <= 0;
        end else begin
            // 1ms tick 생성
            if (msec_count == MSEC_COUNT_MAX - 1) begin
                msec_count  <= 0;
                o_msec_tick <= 1;
            end else begin
                msec_count  <= msec_count + 1;
                o_msec_tick <= 0;
            end

            // 1초 tick 생성
            if (sec_count == SEC_COUNT_MAX - 1) begin
                sec_count <= 0;
                o_sec_tick <= 1;
                // 1초마다 분 카운터 증가
                if (minute_count == 59) begin
                    minute_count <= 0;
                    o_minute_tick <= 1;
                    // 1분마다 시 카운터 증가
                    if (hour_count == 23) begin
                        hour_count <= 0;
                        o_hour_tick <= 1;
                    end else begin
                        hour_count <= hour_count + 1;
                        o_hour_tick <= 0;
                    end
                end else begin
                    minute_count <= minute_count + 1;
                    o_minute_tick <= 0;
                    o_hour_tick <= 0;
                end
            end else begin
                sec_count <= sec_count + 1;
                o_sec_tick <= 0;
            end
        end
    end
endmodule
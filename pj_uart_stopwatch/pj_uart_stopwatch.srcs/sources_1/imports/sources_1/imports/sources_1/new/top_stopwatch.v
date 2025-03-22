`timescale 1ns / 1ps

module top_stopwatch(
    input               clk, 
    input               reset,
    input               btn_run,   // Run signal from cmd_decoder
    input               btn_clear, // Clear signal from cmd_decoder
    input               btn_hour,  // Hour increment signal from cmd_decoder
    input               btn_min,   // Minute increment signal from cmd_decoder
    input               btn_sec,   // Second increment signal from cmd_decoder
    input               [1:0] sw,  // Mode switches
    output              [3:0] fnd_comm,  // 7-segment display control
    output              [7:0] fnd_font,  // 7-segment display data
    output              [3:0] led        // LED indicators
    );

    // Internal signals
    wire                w_msec_tick, w_sec_tick, w_minute_tick, w_hour_tick;
    wire                w_run, w_clear, run, clear; 
    wire                cs, cs_inv;  // Clock/Stopwatch mode selector

    // Time values for display
    wire                [6:0] msec;
    wire                [5:0] sec;
    wire                [5:0] minute;
    wire                [4:0] hour;

    // Clock controller outputs
    wire                [5:0] ccu_sec;
    wire                [5:0] ccu_minute;
    wire                [4:0] ccu_hour;
    
    // Stopwatch datapath outputs
    wire                [6:0] sdp_msec;
    wire                [5:0] sdp_sec;
    wire                [5:0] sdp_minute;
    wire                [4:0] sdp_hour;

    // Switch control logic
    assign              cs = sw[1];      // Clock mode when sw[1] is high
    assign              cs_inv = ~sw[1]; // Stopwatch mode when sw[1] is low
    
    // Clock divider for 1Hz pulse generation (for the real-time clock)
    clock_divider #(
        .CLOCK_FREQ(100_000_000)
    ) U_CLK_DIV(
        .clk            (clk),
        .reset          (reset),
        .o_msec_tick    (w_msec_tick),
        .o_sec_tick     (w_sec_tick),
        .o_minute_tick  (w_minute_tick),
        .o_hour_tick    (w_hour_tick)
    );
    
    // Stopwatch datapath instance
    stopwatch_dp U_StopWatch_DP(
        .clk            (clk),
        .reset          (reset),
        .run            (run),
        .clear          (clear),
        .msec           (sdp_msec),
        .sec            (sdp_sec),
        .minute         (sdp_minute),
        .hour           (sdp_hour)
    );

    // Button debouncing for run/clear signals
    btn_debounce U_Btn_DB_RUN(
        .clk            (clk),
        .reset          (reset),
        .i_btn          (btn_run),
        .o_btn          (w_run)
    );

    btn_debounce U_Btn_DB_CLEAR(
        .clk            (clk),
        .reset          (reset),
        .i_btn          (btn_clear),
        .o_btn          (w_clear)
    );

    // Stopwatch control unit
    stopwatch_cu U_Stopwatch_CU(
        .clk            (clk),
        .reset          (reset),
        .cs             (cs_inv),        // Active in stopwatch mode
        .i_btn_run      (w_run),
        .i_btn_clear    (w_clear),
        .o_run          (run),
        .o_clear        (clear)
    );
    
    // Clock control unit - updated to handle both automatic time progression and button inputs
    clock_cu U_Clock_CU(
        .clk            (clk), 
        .reset          (reset),
        .sec_tick       (w_sec_tick),     // 1Hz tick for automatic time progression
        .btn_hour       (btn_hour),       // Direct button inputs, no debounce needed as already processed
        .btn_min        (btn_min), 
        .btn_sec        (btn_sec),
        .cs             (cs),             // Active in clock mode
        .o_sec          (ccu_sec),
        .o_minute       (ccu_minute),
        .o_hour         (ccu_hour)
    );

    // LED indicator control
    led_indicator U_LED(
        .sw             (sw),
        .led            (led)
    );

    // Multiplexer to select between stopwatch and clock values
    MUX_7 U_MUX_7(
        .st_hour        (sdp_hour),
        .st_minute      (sdp_minute),
        .st_sec         (sdp_sec),
        .st_msec        (sdp_msec),
        .ck_hour        (ccu_hour),
        .ck_minute      (ccu_minute),
        .ck_sec         (ccu_sec),
        .cs             (cs),
        .mux_hour       (hour),
        .mux_minute     (minute),
        .mux_sec        (sec),
        .mux_msec       (msec)
    );    

    // 7-segment display controller
    fnd_controller U_Fnd_Ctrl(
        .clk            (clk), 
        .reset          (reset),
        .sw_mode        (sw[0]),         // Display mode control
        .msec           (msec), 
        .sec            (sec), 
        .minute         (minute), 
        .hour           (hour),
        .fnd_font       (fnd_font),
        .fnd_comm       (fnd_comm)
    );
endmodule
// // Module to convert button presses to clock values
// module btn_to_clock(
//     input           clk, reset,
//     input           btn_hour,
//     input           btn_min,
//     input           btn_sec,
//     output reg      [4:0] o_hour,    // 0-23 hours
//     output reg      [5:0] o_min,     // 0-59 minutes
//     output reg      [5:0] o_sec      // 0-59 seconds
// );
//     // Edge detection for buttons
//     reg btn_hour_prev, btn_min_prev, btn_sec_prev;
//     wire hour_pulse, min_pulse, sec_pulse;
    
//     // Detect rising edges
//     always @(posedge clk) begin
//         if (reset) begin
//             btn_hour_prev <= 0;
//             btn_min_prev <= 0;
//             btn_sec_prev <= 0;
//         end else begin
//             btn_hour_prev <= btn_hour;
//             btn_min_prev <= btn_min;
//             btn_sec_prev <= btn_sec;
//         end
//     end
    
//     assign hour_pulse = btn_hour & ~btn_hour_prev;
//     assign min_pulse = btn_min & ~btn_min_prev;
//     assign sec_pulse = btn_sec & ~btn_sec_prev;
    
//     // Update time values on button presses
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             o_sec <= 0;
//             o_min <= 0;
//             o_hour <= 0;
//         end else begin
//             // Second increment
//             if (sec_pulse) begin
//                 if (o_sec == 59)
//                     o_sec <= 0;
//                 else
//                     o_sec <= o_sec + 1;
//             end
            
//             // Minute increment
//             if (min_pulse) begin
//                 if (o_min == 59)
//                     o_min <= 0;
//                 else
//                     o_min <= o_min + 1;
//             end
            
//             // Hour increment
//             if (hour_pulse) begin
//                 if (o_hour == 23)
//                     o_hour <= 0;
//                 else
//                     o_hour <= o_hour + 1;
//             end
//         end
//     end
// endmodule




// `timescale 1ns / 1ps

// module top_stopwatch(
//     input               clk, 
//     input               reset,
//     input               btn_run,
//     input               btn_sec,
//     input               btn_clear,
//     input               btn_hour,
//     input               btn_min,
//     input               [1:0] sw,
//     output              [3:0] fnd_comm,
//     output              [7:0] fnd_font,
//     output              [3:0] led
//     );

//     wire                w_clk_100Hz;
//     wire                w_msec_tick, w_sec_tick, w_minute_tick;
//     wire                w_run, w_clear, run, clear; // 반드시 선언
//     wire                [4:0] w_btn_hour;
//     wire                [5:0] w_btn_min, w_btn_sec;
//     wire                cs, cs_inv;

//     wire                [6:0] msec;
//     wire                [5:0] sec;
//     wire                [5:0] minute;
//     wire                [4:0] hour;

//     wire                [5:0] ccu_sec;
//     wire                [5:0] ccu_minute;
//     wire                [4:0] ccu_hour;
    
//     wire                [6:0] sdp_msec;
//     wire                [5:0] sdp_sec;
//     wire                [5:0] sdp_minute;
//     wire                [4:0] sdp_hour;

//     wire                [6:0] c_msec;
//     wire                [5:0] c_sec; 
//     wire                [5:0] c_minute;
//     wire                [4:0] c_hour;

//     assign              cs = sw[1];
//     assign              cs_inv = ~sw[1];

//     stopwatch_dp U_StopWatch_DP(
//         .clk            (clk),
//         .reset          (reset),
//         .run            (run),
//         .clear          (clear),
//         .msec           (sdp_msec),
//         .sec            (sdp_sec),
//         .minute         (sdp_minute),
//         .hour           (sdp_hour)
//     );

    
//     btn_debounce U_Btn_DB_RUN(
//         .clk            (clk),
//         .reset          (reset),
//         .i_btn          (btn_run),
//         .o_btn          (w_run)
//     );

//     btn_debounce U_Btn_DB_CLEAR(
//         .clk            (clk),
//         .reset          (reset),
//         .i_btn          (btn_clear),
//         .o_btn          (w_clear)
//     );

//     clock_module U_Btn_Clock_Module(
//         .clk            (clk), 
//         .reset          (reset),
//         .i_btn_hour     (btn_hour),     // 시간 설정 버튼 (아래 버튼)
//         .i_btn_min      (btn_min),      // 분 설정 버튼 (왼쪽 버튼)
//         .i_btn_sec      (btn_sec),      // 초 설정 버튼 (위 버튼)
//         .o_sec          (w_btn_sec),    // 초 (0-59)
//         .o_min          (w_btn_min),    // 분 (0-59)
//         .o_hour         (w_btn_hour)    // 시 (0-23)
//     );

//     stopwatch_cu U_Stopwatch_CU(
//         .clk            (clk),
//         .reset          (reset),
//         .cs             (cs_inv),
//         .i_btn_run      (w_run),
//         .i_btn_clear    (w_clear),
//         .o_run          (run),
//         .o_clear        (clear)
//     );
    
//     clock_cu U_Clock_CU(
//     .clk                (clk), 
//     .reset              (reset),
//     .c_sec              (w_btn_sec),
//     .c_minute           (w_btn_min),
//     .c_hour             (w_btn_hour),
//     .cs                 (cs),
//     .o_c_sec            (ccu_sec),     // 비트 폭 수정 (6비트)
//     .o_c_minute         (ccu_minute),  // 비트 폭 수정 (6비트)
//     .o_c_hour           (ccu_hour)     // 비트 폭 수정 (5비트)
//     );

//     led_indicator U_LED(
//         .sw             (sw),
//         .led            (led)
//     );

//     MUX_7 U_MUX_7(
//     .st_hour            (sdp_hour),
//     .st_minute          (sdp_minute),
//     .st_sec             (sdp_sec),
//     .st_msec            (sdp_msec),
//     .ck_hour            (ccu_hour),
//     .ck_minute          (ccu_minute),
//     .ck_sec             (ccu_sec),
//     .cs                 (cs),
//     .mux_hour           (hour),
//     .mux_minute         (minute),
//     .mux_sec            (sec),
//     .mux_msec           (msec)
//     );    

//     fnd_controller U_Fnd_Ctrl(
//         .clk            (clk), 
//         .reset          (reset),
//         .sw_mode        (sw[0]),
//         .msec           (msec), 
//         .sec            (sec), 
//         .minute         (minute), 
//         .hour           (hour),
//         .fnd_font       (fnd_font),
//         .fnd_comm       (fnd_comm)
//     );
// endmodule


module led_indicator (
    input               [1:0] sw,
    output              reg [3:0] led
);
    
    always @(*) begin
        case (sw)
            2'b00: led = 4'b0001;
            2'b01: led = 4'b0010;
            2'b10: led = 4'b0100;
            2'b11: led = 4'b1000;
            default: led = 4'bx;
        endcase
    end

endmodule

module MUX_7 (
    input               [4:0] st_hour,
    input               [5:0] st_minute,
    input               [5:0] st_sec,
    input               [6:0] st_msec,
    input               [4:0] ck_hour,
    input               [5:0] ck_minute,
    input               [5:0] ck_sec,
    input               cs,
    output              reg [4:0] mux_hour,
    output              reg [5:0] mux_minute,
    output              reg [5:0] mux_sec,
    output              reg [6:0] mux_msec
);
    always @(*) begin
        mux_hour = 0;
        mux_minute = 0;
        mux_sec = 0;
        mux_msec = 0;

        case (cs)
            1'b0: begin
                mux_hour = st_hour;
                mux_minute = st_minute;
                mux_sec = st_sec;
                mux_msec = st_msec;
            end

            1'b1: begin
                mux_hour = ck_hour;
                mux_minute = ck_minute;
                mux_sec = ck_sec;
            end
        endcase
    end    
endmodule
`timescale 1ns / 1ps

module top_stopwatch(
    input               clk, reset, btn_run, btn_clear, sw_mode,
    output              [3:0] fnd_comm,
    output              [7:0] fnd_font
    );

    wire                w_clk_100Hz;
    wire                w_msec_tick, w_sec_tick, w_minute_tick;
    wire                w_run, w_clear, run, clear; // 반드시 선언
    wire                [6:0] msec;
    wire                [5:0] sec, minute;
    wire                [4:0] hour;

    //sfdg
    stopwatch_dp U_StopWatch_DP(
        .clk            (clk),
        .reset          (reset),
        .run            (run),
        .clear          (clear),
        .msec           (msec),
        .sec            (sec),
        .minute         (minute),
        .hour           (hour)
    );

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

    stopwatch_cu U_Stopwatch_CU(
        .clk            (clk),
        .reset          (reset),
        .i_btn_run      (w_run),
        .i_btn_clear    (w_clear),
        .o_run          (run),
        .o_clear        (clear)
    );

    fnd_controller U_Fnd_Ctrl(
        .clk            (clk), 
        .reset          (reset),
        .sw_mode        (sw_mode),
        .msec           (msec), 
        .sec            (sec), 
        .minute         (minute), 
        .hour           (hour),
        .dot            (dot),
        .fnd_font       (fnd_font),
        .fnd_comm       (fnd_comm)
    );
endmodule

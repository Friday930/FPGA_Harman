`timescale 1ns / 1ps

module top_stopwatch(
    input               clk, reset, btn_run, btn_clear,
    output              [3:0] fnd_comm,
    output              [7:0] fnd_font
    );

    wire                w_clk_100Hz;
    wire                w_msec_tick, w_sec_tick, w_minute_tick;
    wire                w_run, w_clear;
    wire                [7:0] msec, sec, min, hour;


    stopwatch_dp U_StopWatch_DP(
        .clk            (clk),
        .reset          (reset),
        .run            (w_run),
        .clear          (w_clear),
        .msec           (msec),
        .sec            (sec),
        .minute         (minute),
        .hour           (hour)
    );

    stopwatch_cu U_Stopwatch_CU(
        .clk            (clk),
        .reset          (reset),
        .i_btn_run      (btn_run),
        .i_btn_clear    (btn_clear),
        .o_run          (w_run),
        .o_clear        (w_clear)
    );

    fnd_controller U_Fnd_Ctrl(
        .clk            (clk), 
        .reset          (reset),
        .msec           (msec), 
        .sec            (sec), 
        .minute         (minute), 
        .hour           (hour),
        .fnd_font       (fnd_font),
        .fnd_comm       (fnd_comm)
    );
endmodule

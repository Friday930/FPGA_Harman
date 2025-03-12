`timescale 1ns / 1ps

module top_stopwatch(
    input               clk, reset, btn_run, btn_clear, 
    input               [1:0] sw,
    output              [3:0] fnd_comm,
    output              [7:0] fnd_font,
    output              [3:0] led
    );

    wire                w_clk_100Hz;
    wire                w_msec_tick, w_sec_tick, w_minute_tick;
    wire                w_run, w_clear, run, clear; // 반드시 선언
    wire                [6:0] msec;
    wire                [5:0] sec, minute;
    wire                [4:0] hour;

    wire [1:0] sw_debug = sw;


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

    led_indicator U_LED(
        .sw             (sw),
        .led            (led)
    );

    fnd_controller U_Fnd_Ctrl(
        .clk            (clk), 
        .reset          (reset),
        .sw_mode        (sw[0]),
        .msec           (msec), 
        .sec            (sec), 
        .minute         (minute), 
        .hour           (hour),
        .fnd_font       (fnd_font),
        .fnd_comm       (fnd_comm)
    );
endmodule

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
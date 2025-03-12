`timescale 1ns / 1ps

module tb_stopwatch();

    reg         clk, reset, run, clear;
    reg         sw_mode;
    wire        [6:0] msec;
    wire        [5:0] sec, minute;
    wire        [4:0] hour;
    wire        [7:0] fnd_font;
    wire        [3:0] fnd_comm;

    stopwatch_dp DUT(
        .clk    (clk),
        .reset  (reset),
        .run    (run),
        .clear  (clear),
        .msec   (msec), 
        .sec    (sec), 
        .minute (minute), 
        .hour   (hour)
    );
    // reg mode;
    // wire[3:0] comm;
    // wire [7:0]font;
    // top_stopwatch DUT(
    // .clk(clk), 
    // .reset(reset), 
    // .btn_run(run),
    // .btn_clear(clear),
    // .sw_mode(mode),
    // .fnd_comm(comm),
    // .fnd_font(font)
    // );

    fnd_controller DUT1(
    .clk(clk), 
    .reset(reset), 
    .sw_mode(sw_mode),
    .msec(msec), 
    .sec(sec), 
    .minute(minute), 
    .hour(hour),
    .fnd_font(fnd_font),
    .fnd_comm(fnd_comm)
    );

    always #5 clk = ~clk; // clk 생성

    initial begin
        // 초기화
        clk = 0; 
        reset = 1; 
        run = 0; 
        clear = 0;
        sw_mode = 0;
        // mode = 0;
        
        #10; // 10ns run = 1
        reset = 0;
        run = 1;


        // wait (hour == 23); // 2sec 대기

        // // wait (hour == 1); // 2sec 대기
        // #10;
        // run = 0; // stop
        // repeat(4) @(posedge clk) // 4번 반복, clk posedge 이벤트 
        // clear = 1;
        // #100;
    $stop;
    end

endmodule

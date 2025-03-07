`timescale 1ns / 1ps

module tb_stopwatch();
    reg clk, reset, w_clear, w_tick_100Hz;
    wire [$clog2(10_000)-1:0] w_count;
    wire w_tick_msec;

    counter_tick U_Counter_Tick(  // msec
        .clk            (clk),
        .reset          (reset),
        .clear          (w_clear),
        .tick           (w_tick_100Hz),
        .counter        (w_count),
        .o_tick         (w_tick_msec)
    );

    always #5           clk = ~clk;
    integer i;
    initial begin
        clk = 0; reset = 1; w_clear = 0; w_tick_100Hz = 0;
        #10; reset = 0;
        for (i=0;i<250;i=i+1) begin
            #10; w_tick_100Hz = 1'b1;
            #10; w_tick_100Hz = 1'b0;
        end $stop;
    end
endmodule

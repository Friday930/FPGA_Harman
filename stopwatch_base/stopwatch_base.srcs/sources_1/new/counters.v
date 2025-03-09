`timescale 1ns / 1ps


module counter_tic #(parameter COUNT_60 = 60)(
    input       clk, reset,
    output      [$clog2(COUNT_60) - 1:0] cnt_60;
);
    reg         [$clog2(COUNT_60) - 1:0] count_60;
    assign      cnt_60 = count_60;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_60 <= 0;
        end else count_60 = count_60 + 1;
    end
endmodule

module counter_msec (
    input       clk, reset,
    output      [$clog2(100) - 1:0] cnt_100
);
    reg         [$clog2(100) - 1:0] count_100;
    assign      cnt_100 = count_100;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_100 <= 0;
        end else count_100 = count_100 + 1;
    end
endmodule

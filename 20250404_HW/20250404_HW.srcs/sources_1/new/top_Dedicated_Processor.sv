`timescale 1ns / 1ps


module top_Dedicated_Processor(
    input                       clk,
    input                       rst,
    output  [$clog2(55)-1:0]    out
    );

    logic                       alt10, asrcmuxsel, aen, outbuf;
    logic   [$clog2(10)-1:0]    count;

    control_unit U_Control_Unit(
        .clk                    (clk),
        .rst                    (rst),
        .ALt10                  (alt10),
        .ASrcMuxSel             (asrcmuxsel),
        .AEn                    (aen),
        .EN_cnt                 (count),
        .Outbuf                 (outbuf)
    );

    data_path U_Data_Path(
        .clk                    (clk),
        .rst                    (rst),
        .ASrcMuxSel             (asrcmuxsel),
        .AEn                    (aen),
        .Outbuf                 (outbuf),
        .EN_cnt                 (count),
        .ALt10                  (alt10),
        .Outport                (out)
    );
endmodule

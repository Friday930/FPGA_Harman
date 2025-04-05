`timescale 1ns / 1ps


module data_path(
    input                           clk,
    input                           rst,
    input                           ASrcMuxSel,
    input                           AEn,
    input                           Outbuf,
    output                          ALt10,
    output  [$clog2(55)-1:0]        Outport
    );

    logic   [$clog2(55)-1:0]        d, q, sum;

    mux_2x1 U_MUX_2x1(
        // .zero                       (),
        .ASrcMuxSel                 (ASrcMuxSel),
        .adder_res                  (sum),
        .d                          (d)           
    );

    Register U_REG(
        .clk                        (clk),
        .rst                        (rst),
        .en                         (AEn),
        .d                          (d),
        .q                          (q)
    );

    Comparator U_Comp(
        .q                          (q),
        .ALt10                      (ALt10)
    );

    adder U_ADD(
        .q                          (q),
        .sum                        (sum)
    );

    outbuf U_BUF(
        .q                          (q),
        .outbuf                     (Outbuf),
        .result                     (Outport)
    );

endmodule

module mux_2x1 (
    // input                           zero,
    input                           ASrcMuxSel,
    input   [$clog2(55)-1:0]        adder_res,
    output  [$clog2(55)-1:0]        d           
);

    assign                          d = (ASrcMuxSel) ? adder_res : 0;

endmodule

module Register (
    input                           clk,
    input                           rst,
    input                           en,
    input   [$clog2(55)-1:0]        d,
    output reg  [$clog2(55)-1:0]    q
);
    always_ff @( posedge clk, posedge rst ) begin
        if (rst) begin
            q <= 0;
        end else if (en) begin
            q <= d;
        end
    end
endmodule

module Comparator (
    input   [$clog2(55)-1:0]        q,
    output                          ALt10
);

    assign                          ALt10 = q < 11;
    
endmodule

module adder (
    input   [$clog2(55)-1:0]        q,
    output  [$clog2(55)-1:0]        sum
);

    assign                          sum = q + 1;
    
endmodule

module outbuf (
    input   [$clog2(55)-1:0]        q,
    input                           outbuf,
    output  [$clog2(55)-1:0]        result
);

    assign                          result = (outbuf) ? q : 0;
    
endmodule
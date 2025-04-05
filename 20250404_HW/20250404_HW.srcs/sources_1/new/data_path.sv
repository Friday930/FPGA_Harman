`timescale 1ns / 1ps


module data_path(
    input                           clk,
    input                           rst,
    input                           ASrcMuxSel,
    input                           AEn,
    input                           Outbuf,
    input                           EN_cnt,
    output                          ALt10,
    output  [$clog2(55)-1:0]        Outport
    );

    logic   [$clog2(55)-1:0]        d, q, sum;
    logic   [$clog2(10)-1:0]        count;


    mux_2x1 U_MUX_2x1(
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

    counter U_Counter(
        .clk                        (clk),
        .rst                        (rst),
        .en_cnt                     (EN_cnt),
        .count                      (count)
    );

    Comparator U_Comp(
        .count                      (count),
        .ALt10                      (ALt10)
    );

    adder U_ACC(
        .q                          (q),
        .count                      (count),
        .sum                        (sum)
    );

    outbuf U_BUF(
        .q                          (q),
        .outbuf                     (Outbuf),
        .result                     (Outport)
    );

endmodule

module counter (
    input                           clk,
    input                           rst,
    input                           en_cnt,
    output  reg [$clog2(10)-1:0]    count
);

    always_ff @( posedge clk, posedge rst ) begin
        if (rst) begin
            count <= 0;
        end else if(en_cnt) begin
            count <= count + 1;
        end
        
    end

endmodule

module mux_2x1 (
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
    input   [$clog2(10)-1:0]        count,
    output                          ALt10
);

    assign                          ALt10 = count < 10;
    
endmodule

module adder (
    input   [$clog2(55)-1:0]        q,
    input   [$clog2(10)-1:0]        count,
    output  [$clog2(55)-1:0]        sum
);

    assign  sum = q + count;
    
endmodule

module outbuf (
    input   [$clog2(55)-1:0]        q,
    input                           outbuf,
    output  [$clog2(55)-1:0]        result
);

    assign                          result = (outbuf) ? q : 0;
    
endmodule
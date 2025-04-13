`timescale 1ns / 1ps


module ControlUnit(
    input   logic           clk,
    input   logic           reset,
    output  logic           ASrcMuxSel,
    output  logic           AEn,
    input   logic           ALt10,
    output  logic           OutBuf
);

    localparam              S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5;
    logic   [2:0]           state, next;
    
    always_ff @( posedge clk, posedge reset ) begin
        if (reset) begin
            state <= S0;
        end else state <= next;
    end

    always_comb begin
        next = state;
        ASrcMuxSel = 0;
        AEn = 0;
        OutBuf = 0;
        case (state)
            S0: begin
                ASrcMuxSel = 0;
                AEn = 1;
                OutBuf = 0;
                next = S1;
            end
            S1: begin
                ASrcMuxSel = 0;
                AEn = 1;
                OutBuf = 0;
                if (ALt10) begin
                    next = S2;
                end else next = S4;
            end
            S2: begin
                ASrcMuxSel = 0;
                AEn = 0;
                OutBuf = 1;
                next = S3;
            end
            S3: begin
                ASrcMuxSel = 1;
                AEn = 1;
                OutBuf = 0;
                next = S1;
            end
            S4: begin
                ASrcMuxSel = 0;
                AEn = 0;
                OutBuf = 0;
                next = S4;
            end
        endcase
    end

endmodule

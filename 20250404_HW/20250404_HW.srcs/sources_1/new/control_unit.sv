`timescale 1ns / 1ps

module control_unit(
    input           clk,
    input           rst,
    input           ALt10,
    output reg      ASrcMuxSel,
    output reg      EN_cnt,
    output reg      AEn,
    output reg      Outbuf
    );

    parameter       S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;
    logic [2:0]     state, next;

    always_ff @( posedge clk, posedge rst ) begin
        if (rst) begin
            state <= 0;
        end else state <= next;
    end 

    always_comb begin
        next = state;
        ASrcMuxSel = 0;
        AEn = 0;
        EN_cnt = 0;
        Outbuf = 0;
        case (state)
            S0: begin
                ASrcMuxSel = 0;
                AEn = 1;
                Outbuf = 0;
                EN_cnt = 0;
                next = S1;
            end 
            S1: begin
                ASrcMuxSel = 0;
                AEn = 0;
                Outbuf = 0;
                EN_cnt = 0;
                if (ALt10) begin
                    next = S2;
                end else next = S4;
            end
            S2: begin
                ASrcMuxSel = 0;
                AEn = 0;
                Outbuf = 1;
                EN_cnt = 0;
                next = S3;
            end
            S3: begin
                ASrcMuxSel = 1;
                AEn = 1;
                Outbuf = 0;
                EN_cnt = 1;
                next = S1;
            end
            S4: begin
                ASrcMuxSel = 0;
                AEn = 0;
                Outbuf = 0;
                EN_cnt = 0;
                next = S4;
            end              
        endcase
    end

endmodule

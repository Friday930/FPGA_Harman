`timescale 1ns / 1ps

module control_unit(
    input           clk,
    input           reset,
    input           sw1,
    input           sw2,
    output          run_stop,
    output          clear
    );

    parameter       STOP = 0, RUN = 1, CLEAR = 2;

    reg [1:0]       state, next;
    reg             r, c;

    assign          sw1_inv = ~sw1;
    assign          run_stop = r;
    assign          clear = c;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
        end else begin
            state <= next;
        end
    end

    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (sw1_inv == 1) begin
                    next = RUN;
                end else if (sw2 == 1) begin
                    next = CLEAR;
                end
            end 
            RUN: begin
                if (sw1_inv == 0) begin
                    next = STOP;
                end else if (sw2 == 1) begin
                    next = CLEAR;
                end
            end
            CLEAR: begin
                if (sw2 == 1) begin
                    next = STOP;
                end else next = RUN;
            end
        endcase
    end

    always @(*) begin
        r = 0;
        c = 0;
        case (state)
            STOP: begin
                r = 0;
                c = 0;
            end
            RUN: begin
                r = 1;
                c = 0;
            end
            CLEAR: begin
                // r = 0;
                c = 1;
            end
        endcase
    end

endmodule

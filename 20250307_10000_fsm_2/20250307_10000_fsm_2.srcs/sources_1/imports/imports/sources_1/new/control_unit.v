`timescale 1ns / 1ps

module control_unit (
    input       clk, reset,
    input       i_run_stop, i_clear,
    output      reg o_run_stop, o_clear
);

    parameter   STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;

    // state 관리
    reg         [2:0] state, next;

    // state sequencial logic (<=)
    always @(posedge clk, posedge reset) begin
        if(reset) state <= STOP;
        else state <= next;
    end

    // next combination logic (=)
    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (i_run_stop == 1'b1) begin
                    next = RUN;
                end else if (i_clear == 1'b1) begin
                    next = CLEAR;
                end else next = state;
            end

            RUN: begin
                if (i_run_stop == 1'b1) begin
                    next = STOP;
                end else next = state;
            end

            CLEAR: begin
                if (i_clear == 1'b1) begin
                    next = STOP;
                end else next = state;
            end
            default: next = state;
        endcase
    end
    
    // combinational output logic
    always @(*) begin
        o_run_stop = 1'b0;
        o_clear = 1'b0;

        case (state)
            STOP:   begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
            RUN:    begin
                o_run_stop = 1'b1;
                o_clear = 1'b0;
            end
            CLEAR:  begin
                o_run_stop = 1'b0;
                o_clear = 1'b1;
            end
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end
endmodule

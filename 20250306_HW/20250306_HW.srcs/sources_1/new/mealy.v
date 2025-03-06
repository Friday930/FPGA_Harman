`timescale 1ns / 1ps


module mealy(
    input       clk, reset, din_bit,
    output      dout_bit
    );

    parameter   START = 3'b000, RD0_ONCE = 3'b001, RD1_ONCE = 3'b010, RD0_TWICE = 3'b011, RD1_TWICE = 3'b100;
    reg         [2:0] next, state;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 3'b000;
        end else state <= next;
    end

    always @(*) begin
        next = state;
        case (state)
            START: begin
                if (din_bit == 1'b0) begin
                    next = RD0_ONCE;
                end else if (din_bit == 1'b1) begin
                    next = RD1_ONCE;
                end else next = state;
            end
            RD0_ONCE: begin
                if (din_bit == 1'b0) begin
                    next = RD0_TWICE;
                end else if (din_bit == 1'b1) begin
                    next = RD1_ONCE;
                end else next = state;
            end
            RD1_ONCE: begin
                
            end
            default: 
        endcase
    end

endmodule

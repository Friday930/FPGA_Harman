`timescale 1ns / 1ps

module fsm_exam(
    input       clk,
    input       reset,
    input       [2:0] sw,
    output      [2:0] led
    );

    parameter   IDLE = 3'b000, ST1 = 3'b001, ST2 = 3'b010, ST3 = 3'b100, ST4 = 3'b111;

    reg         [2:0] r_led;
    reg         [2:0] state;
    reg         [2:0] next;
    assign      led = r_led;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 2'b00;
        end else begin
            state <= next;
        end
    end

    always @(*) begin
        next = state;
        case (state)
            IDLE: if(sw == 3'b010) begin
                next <= ST2;
            end else if(sw == 3'b001) begin
                next <= ST1;
            end else begin
                next <= state;
            end

            ST1: if(sw == 3'b010) begin
                next <= ST2;
            end else next <= state;

            ST2: if(sw == 3'b100) begin
                next <= ST3;
            end else next <= state;

            ST3: if(sw == 3'b000) begin
                next <= IDLE;
            end else if(sw == 3'b001) begin
                next <= ST1;
            end else if(sw == 3'b111) begin
                next <= ST4;
            end else begin
                next <= state;
            end

            ST4: if(sw == 3'b100) begin
                next <= ST3;
            end

            default: next = state;
        endcase
    end

    always @(*) begin
            case (state)
                IDLE: r_led = 3'b000;
                ST1: r_led = 3'b001;
                ST2: r_led = 3'b010;
                ST3: r_led = 3'b100;
                ST4: r_led = 3'b111;
                default: r_led = 3'b000;
            endcase
    end
endmodule

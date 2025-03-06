`timescale 1ns / 1ps

module fsm_exam(
    input       clk,
    input       reset,
    input       [2:0] sw,
    output      [2:0] led
    );

    parameter   [2:0] IDLE = 3'b000, ST1 = 3'b001, ST2 = 3'b010, ST3 = 3'b100, ST4 = 3'b111;

    reg         [2:0] r_led;
    reg         [2:0] state;
    reg         [2:0] next;
    assign      led = r_led;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 3'b000;
        end else begin
            state <= next;
        end
    end

    always @(*) begin
        next = state;
        case (state)
            IDLE: begin 
                if(sw == 3'b010) begin
                    next = ST2;
                end else if(sw == 3'b001) begin
                    next = ST1;
                end else begin
                    next = state;
                end
            end

            ST1: begin
                if(sw == 3'b010) begin
                    next = ST2;
                end else next <= state;
            end

            ST2: begin
                if(sw == 3'b100) begin
                    next = ST3;
                end else next = state;
            end

            ST3: begin
                if(sw == 3'b000) begin
                    next = IDLE;
                end else if(sw == 3'b001) begin
                    next = ST1;
                end else if(sw == 3'b111) begin
                    next = ST4;
                end else begin
                    next = state;
                end
            end

            ST4: begin
                if(sw == 3'b100) begin
                    next = ST3;
                end else next = state;
            end
            default: next = state;
        endcase
    end

    always @(*) begin
            case (state)
                IDLE: begin
                    // r_led = 3'b000; // moore
                    if(sw == 3'b001) r_led = 3'b001;// mealy
                    else if(sw == 3'b010) r_led = 3'b010;
                    else r_led = 3'b000;
                end 

                ST1: begin
                    if(sw == 3'b001) r_led = 3'b001;
                    else r_led = 3'b001;
                end

                ST2: begin
                    if(sw == 3'b010) r_led = 3'b010;
                    else r_led = 3'b100;
                end

                ST3: begin
                    if(sw == 3'b000) r_led = 3'b000;
                    else if(sw == 3'b001) r_led = 3'b001;
                    else if(sw == 3'b111) r_led = 3'b111;
                    else r_led = 3'b101;
                end 
                
                ST4: begin
                    if(sw == 3'b100) r_led = 3'b100;
                    else r_led = 3'b111;
                end

                default: r_led = 3'b000;
            endcase
    end
endmodule

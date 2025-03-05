`timescale 1ns / 1ps

module fsm_led(
        input clk, reset,
        input [2:0] sw,
        output [1:0] led
    );

    parameter [1:0] IDLE = 2'b00, LED01 = 2'b01, LED02 = 2'b10;

    reg [1:0] state, next;
    reg [1:0] r_led;
    assign led = r_led;

    // state 저장
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 0;
            // next <= 0;
        end else begin
            state <= next; // 상태관리, next를 현재상태로 바꿔라
        end
    end

    // next combinational logic
    always @(*) begin
        next = state; // 초기화
        case (state) // 현재상태
            IDLE: if (sw == 3'b001) begin // next로 가기 위한 조건
                next = LED01; // led 1 on
            end
            LED01: if (sw == 3'b011) begin
                next = LED02;
            end
            LED02: if (sw == 3'b111) begin
                next = IDLE;
            end else if (sw == 3'b110) begin
                next = LED01;
            end else begin
                next = state;
            end
            default: next = state;
        endcase
    end

    // output combinational logic

    always @(*) begin
        case (state) // state?? next??
            IDLE: r_led = 2'b00;
            LED01: r_led = 2'b10;
            LED02: r_led = 2'b01;
            default: r_led = 2'b00;
        endcase
    end

endmodule

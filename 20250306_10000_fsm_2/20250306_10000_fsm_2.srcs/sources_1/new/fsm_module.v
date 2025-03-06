`timescale 1ns / 1ps

module clk_100Hz_tick(
    input       clk, reset, run_stop,
    output      o_tick_100Hz
    );

    parameter   STOP = 1'b0, RUN = 1'b1;
    parameter   FCOUNT = 1_000_000;
    reg         state, next;
    reg         [$clog2(FCOUNT)-1:0] r_counter;
    reg         r_clk_100Hz;
    assign      o_tick_100Hz = r_clk_100Hz; // always 구문 reg 출력을 위해서

    // state 저장
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
        end else state <= next;
    end

    // next combinational logic
    always @(*) begin
        next = state; // latch 제거
        case (state)
            STOP: begin
                if(run_stop == 1'b1) next = RUN;
            end

            RUN: begin
                if(run_stop == 1'b0) next = STOP;
            end

            default: next = state; // latch 제거
        endcase
    end

    // output combinational logic
    always @(*) begin
        r_counter = 0;
        case (state)
            RUN: begin
                if(r_counter == (FCOUNT - 1)) begin // 100Hz
                    r_counter = 0;
                    r_clk_100Hz = 1'b1; // 출력 clk를 high
                end else begin
                    r_counter = r_counter + 1;
                    r_clk_100Hz = 1'b0;
                end
            end 
            default: begin
                r_counter = 1'b0;
                r_clk_100Hz = 1'b0;
            end
        endcase
    end
endmodule

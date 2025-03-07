`timescale 1ns / 1ps


module btn_debounce(
    input       i_btn, clk, reset,
    output      o_btn
    );

    // state
    reg         state, next;
    reg         [7:0] q_reg, q_next; // shift register
    reg         edge_detect;
    wire        btn_debounce;

    // state logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
        end else next <= state;
    end

    // next logic
    always @(*) begin
        // q_reg 현재의 상위 7비트를 다음 하위 7비트에 넣고 최상위에는 i_btn을 넣어라
        q_next = {i_btn,q_reg[7:1]}; // shift 동작 
    end

    // 8 input AND gate
    assign btn_debounce = q_reg;

    // edge_detector, 100MHz -> F/F 추가
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_detect <= btn_debounce;
        end
    end

    // 최종 출력
    assign o_btn = btn_debounce & (~edge_detect);
endmodule

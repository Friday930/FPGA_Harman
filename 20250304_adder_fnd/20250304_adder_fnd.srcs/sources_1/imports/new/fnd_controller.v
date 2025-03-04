`timescale 1ns / 1ps

module fnd_controller(
    input [8:0] bcd,
    input [1:0] seg_sel,
    output [7:0] seg,
    output [3:0] seg_comm
);

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000, w_bcd;
    decoder_2x4 U_decoder_2x4(
        .seg_sel(seg_sel),
        .seg_comm(seg_comm)
    );

    digit_splitter U_Digit_Splitter(
        .bcd(bcd),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    mux_4x1 U_MUX_4x1(
        .sel(seg_sel),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .bcd(w_bcd)
    );

    bcdtoseg U_bcdtoseg(
        .bcd(w_bcd), // [7:0] sum 값
        .seg(seg)
    );
endmodule

module bcdtoseg (
    input [3:0] bcd, // [3:0] sum 값
    output reg [7:0] seg
);
    // always 구문 출력으로 reg type를 가져야 한다
    always @(bcd) begin // 항상 대상(bcd)의 이벤트를 감시
        
        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hf9;
            4'h2: seg = 8'ha4;
            4'h3: seg = 8'hb0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'ha: seg = 8'h88;
            4'hb: seg = 8'h83;
            4'hc: seg = 8'hc6;
            4'hd: seg = 8'ha1;
            4'he: seg = 8'h86;
            4'hf: seg = 8'h8e;
            default: seg = 8'hff;
        endcase
    end
endmodule

module digit_splitter (
    input [8:0] bcd,
    output [3:0] digit_1, digit_10, digit_100, digit_1000
);
    
    assign digit_1 = bcd % 10;
    assign digit_10 = bcd / 10 % 10;
    assign digit_100 = bcd / 100 % 10;
    assign digit_1000 = bcd / 1000 % 10;
    
endmodule

module mux_4x1 (
    input [1:0] sel,
    input [3:0] digit_1, digit_10, digit_100, digit_1000,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;
    // * : input 모두 감시, 아니면 개별 입력 선택
    // always : 항상 감시한다 @이벤트 이하를 ()의 변화가 있으면, begin end를 수행
    always @(sel, digit_1, digit_10, digit_100, digit_1000) begin
        case (sel)
            2'b00: r_bcd = digit_1;
            2'b01: r_bcd = digit_10;
            2'b10: r_bcd = digit_100;
            2'b11: r_bcd = digit_1000;
            default: r_bcd = 4'bx; // x : 아무거나 상관 없음
        endcase
    end

endmodule

module decoder_2x4 (
    input [1:0] seg_sel,
    output reg [3:0] seg_comm
);

    // 2x4 decoder
    always @(*) begin
        case (seg_sel)
            2'b00 : seg_comm = 4'b1110;
            2'b01 : seg_comm = 4'b1101;
            2'b10 : seg_comm = 4'b1011;
            2'b11 : seg_comm = 4'b0111;
            default: seg_comm = 4'b1110;
        endcase
    end
    
endmodule
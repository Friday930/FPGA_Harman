`timescale 1ns / 1ps

module fnd_controller(
    input clk, reset,
    input [13:0] bcd,
    output [7:0] seg,
    output [3:0] seg_comm
);

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000, w_bcd;
    wire [1:0] w_seg_sel;
    wire w_clk_100Hz;
    wire [13:0] w_cnt; // 10000을 $clog2로 필요한 비트 수 계산된 결과 값

    counter U_Counter_10000(
        .clk(clk),
        .rst(reset),
        .cnt(w_cnt[13:0])
    );

    clk_divider U_Clk_Divider(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100Hz)
    );

    counter_4 U_counter_4(
        .clk(w_clk_100Hz),
        .reset(reset),
        .o_sel(w_seg_sel)
    );

    decoder_2x4 U_decoder_2x4(
        .seg_sel(w_seg_sel),
        .seg_comm(seg_comm)
    );

    digit_splitter U_Digit_Splitter(
        .bcd(w_cnt[13:0]),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    mux_4x1 U_MUX_4x1(
        .sel(w_seg_sel),
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
    input [13:0] bcd, // [3:0] sum 값
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
    input [13:0] bcd,
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

module clk_divider(
    input clk, reset,
    output o_clk
);
    parameter FCOUNT = 10_000_000;
    reg [$clog2(FCOUNT)-1:0] r_counter; // $clog2 : 숫자를 나타내는데 필요한 비트 수 계산
    reg r_clk;

    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0; // 리셋 상태
            r_clk <= 1'b0;
        end else begin
            if (r_counter == FCOUNT - 1) begin // clk divide 계산, 100MHz -> 100Hz
                r_counter <= 0;
                r_clk <= 1'b1; // r_clk을 99999999번째 posedge에 1로 바꿈 r_clk : 0->1
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0; // r_clk : 1->0 or 0으로 유지
            end
        end
    end
    
endmodule

module counter_4 (
    input clk, reset,
    output [1:0] o_sel
);
    reg [1:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end      
        else begin
            r_counter <= r_counter + 1;
        end  
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
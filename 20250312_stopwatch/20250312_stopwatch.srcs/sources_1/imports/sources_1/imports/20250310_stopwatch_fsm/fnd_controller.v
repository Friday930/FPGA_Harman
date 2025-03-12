`timescale 1ns / 1ps

module fnd_controller(
    input           clk, reset, sw_mode,
    input           [6:0] msec, 
    input           [5:0] sec, minute, 
    input           [4:0] hour,
    output          [7:0] fnd_font,
    output          [3:0] fnd_comm
);
    wire            [3:0] w_bcd, w_digit_msec_1, w_digit_msec_10, w_digit_sec_1, w_digit_sec_10;
    wire            [3:0] w_digit_min_1, w_digit_min_10, w_digit_hour_1, w_digit_hour_10;
    wire            [3:0] w_seg_sel;
    wire            [3:0] w_dot;
    wire            w_clk_100Hz;
    wire            [3:0] w_msec_sec, w_hour_min;
    parameter       VDD = 4'hf, VSS = 0;


    clk_divider U_Clk_Divider(
        .clk        (clk),
        .reset      (reset),
        .o_clk      (w_clk_100Hz)
    );
    
    counter_8 U_Counter_8(
        .clk        (w_clk_100Hz),
        .reset      (reset),
        .o_sel      (w_seg_sel)
    );

    decoder_3x8 U_Decoder_3x8(
        .seg_sel    (w_seg_sel),
        .seg_comm   (fnd_comm)
    );

    digit_splitter #(.BIT_WIDTH(7)) U_mSec_ds(
        .bcd        (msec),
        .digit_1    (w_digit_msec_1),
        .digit_10   (w_digit_msec_10)
    );

    digit_splitter #(.BIT_WIDTH(6)) U_Sec_ds(
        .bcd        (sec),
        .digit_1    (w_digit_sec_1),
        .digit_10   (w_digit_sec_10)
    );

    digit_splitter #(.BIT_WIDTH(6)) U_Minute_ds(
        .bcd        (minute),
        .digit_1    (w_digit_min_1),
        .digit_10   (w_digit_min_10)
    );

    digit_splitter #(.BIT_WIDTH(5)) U_Hour_ds(
        .bcd        (hour),
        .digit_1    (w_digit_hour_1),
        .digit_10   (w_digit_hour_10)
    );

    mux_8x1 U_MUX_8x1_Sec(
        .sel        (w_seg_sel),
        .x0         (w_digit_msec_1),
        .x1         (w_digit_msec_10),
        .x2         (w_digit_sec_1),
        .x3         (w_digit_sec_10),
        .x4         (VDD),
        .x5         (VDD),
        .x6         (w_dot),
        .x7         (VDD),
        .y          (w_msec_sec)
    );

    mux_8x1 U_MUX_8x1_Hour(
        .sel        (w_seg_sel),
        .x0         (w_digit_min_1),
        .x1         (w_digit_min_10),
        .x2         (w_digit_hour_1),
        .x3         (w_digit_hour_10),
        .x4         (VDD),
        .x5         (VDD),
        .x6         (w_dot),
        .x7         (VDD),
        .y          (w_hour_min)
    );    

    comparator_msec U_Comp_dot(
        .msec       (msec),
        .dot        (w_dot)
    );

    mux_2x1 U_MUX_2x1_Mode(
        .sw_mode    (sw_mode),
        .msec_sec   (w_msec_sec),
        .min_hour   (w_hour_min),
        .bcd        (w_bcd)
    );

    bcdtoseg U_bcdtoseg(
        .bcd        (w_bcd), // [7:0] sum 값
        .seg        (fnd_font)
    );


endmodule

module bcdtoseg (
    input           [3:0] bcd, // [3:0] sum 값
    output          reg [7:0] seg
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
            4'he: seg = 8'h7f; // dot
            // 4'hf: seg = 8'h8e;
            4'hf: seg = 8'hff;
            default: seg = 8'hff;
        endcase
    end
endmodule

module digit_splitter #(parameter BIT_WIDTH = 7)(
    input           [BIT_WIDTH - 1:0] bcd,
    output          [3:0] digit_1, digit_10
);
    
    assign          digit_1 = bcd % 10;
    assign          digit_10 = bcd / 10 % 10;
    
endmodule

module mux_8x1 (
    input           [2:0] sel,
    input           [3:0] x0, x1, x2, x3, x4, x5, x6, x7,
    output          reg [3:0] y
);
    always @(*) begin
        case (sel)
            3'b000: y = x0; 
            3'b001: y = x1; 
            3'b010: y = x2; 
            3'b011: y = x3; 
            3'b100: y = x4;
            3'b101: y = x5;
            3'b110: y = x6;
            3'b111: y = x7; 
            default: y = 4'hf;
        endcase
    end
endmodule

module mux_2x1 (
    input           sw_mode,
    input           [3:0] msec_sec, min_hour,
    output          reg [3:0] bcd
);

    always @(*) begin
        case (sw_mode)
            1'b0: bcd = msec_sec;
            1'b1: bcd = min_hour;
            default: bcd = 4'hf;
        endcase
    end
    
endmodule

module clk_divider #(parameter FCOUNT = 250_000)(
    input           clk, reset,
    output          o_clk
);
    reg             [$clog2(FCOUNT)-1:0] r_counter; // $clog2 : 숫자를 나타내는데 필요한 비트 수 계산
    reg             r_clk;

    assign          o_clk = r_clk;

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

module counter_8 (
    input           clk, reset,
    output          [2:0] o_sel
);
    reg             [2:0] r_counter;
    assign          o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end      
        else begin
            r_counter <= r_counter + 1;
        end  
    end
    
endmodule

module decoder_3x8 (
    input           [2:0] seg_sel,
    output          reg [3:0] seg_comm
);

    // 3x8 decoder
    always @(*) begin
        case (seg_sel)
            3'b000 : seg_comm = 4'b1110;
            3'b001 : seg_comm = 4'b1101;
            3'b010 : seg_comm = 4'b1011;
            3'b011 : seg_comm = 4'b0111;
            3'b100 : seg_comm = 4'b1110;
            3'b101 : seg_comm = 4'b1101;
            3'b110 : seg_comm = 4'b1011;
            3'b111 : seg_comm = 4'b0111;
            default: seg_comm = 4'b1111;
        endcase
    end
    
endmodule


module comparator_msec (
    input           [6:0] msec,
    output          [3:0] dot
);
    assign          dot = (msec < 50) ? 4'he : 4'hf ; // dot on, off
endmodule

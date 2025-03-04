`timescale 1ns / 1ps


module fnd_controller(
    input [7:0] bcd,
    input [2:0] seg_sel,
    output [15:0] seg,
    output [7:0] seg_comm
);
    decoder_3x8 U_decoder_3x8(
        .seg_sel(seg_sel),
        .seg_comm(seg_comm)
    );
    bcdtoseg U_bcdtoseg(
        .bcd(bcd), // [3:0] sum 값
        .seg(seg)
    );
endmodule

module bcdtoseg (
    input [7:0] bcd, // [3:0] sum 값
    output reg [7:0] seg
);
    always @(bcd) begin // 항상 대상(bcd)의 이벤트를 감시
        
        case (bcd)
            8'h0: seg = 8'hc0;
            8'h1: seg = 8'hf9;
            8'h2: seg = 8'ha4;
            8'h3: seg = 8'hb0;
            8'h4: seg = 8'h99;
            8'h5: seg = 8'h92;
            8'h6: seg = 8'h82;
            8'h7: seg = 8'hf8;
            8'h8: seg = 8'h80;
            8'h9: seg = 8'h90;
            8'ha: seg = 8'h88;
            8'hb: seg = 8'h83;
            8'hc: seg = 8'hc6;
            8'hd: seg = 8'ha1;
            8'he: seg = 8'h86;
            8'hf: seg = 8'h8e;
            default: seg = 8'hff;
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
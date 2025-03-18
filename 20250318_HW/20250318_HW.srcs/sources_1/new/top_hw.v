`timescale 1ns / 1ps

module top_hw(
    input           clk,
    input           rst,
    input           rx,
    output          [7:0] fnd_font,
    output          [3:0] fnd_comm
    );

    TOP_UART U_UART (
        .clk        (clk),
        .rst        (rst),
        .rx         (rx),
        .tx         ()
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
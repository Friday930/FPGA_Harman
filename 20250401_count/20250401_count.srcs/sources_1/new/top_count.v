`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/01 10:45:24
// Design Name: 
// Module Name: top_count
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_count(
    input           clk,
    input           rst,
    input           sw,
    output  [7:0]   fnd_font,
    output  [3:0]   fnd_comm
    );

    parameter       VDD = 1;
    wire    [15:0]  cnt;
    wire    [3:0]   w_d1, w_d10, w_d100, w_1000;
    wire    [3:0]   w_sel;
    wire    [3:0]   w_bcd;
    
    
    count U_CNT(
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .count(cnt)
    );

    digit_splitter U_Digit_Splitter(
        .count(cnt),
        .digit_1(w_d1),
        .digit_10(w_d10), 
        .digit_100(w_d100), 
        .digit_1000(w_d1000)
    );

    counter_8 U_Comm_CNT(
        .clk(clk), 
        .reset(rst),
        .o_sel(w_sel)
    );

    decoder_3x8 U_DEC(
        .seg_sel(w_sel),
        .seg_comm(fnd_comm)
    );
    
    mux_8x1 U_MUX(
        .sel(w_sel),
        .x0(w_d1), 
        .x1(w_d10), 
        .x2(w_d100), 
        .x3(w_d1000), 
        .x4(VDD), 
        .x5(VDD), 
        .x6(VDD), 
        .x7(VDD),
        .y(w_bcd)
    );
    
    bcdtoseg U_bcdtoseg(
        .bcd        (w_bcd), // [7:0] sum 값
        .seg        (fnd_font)
    );

endmodule

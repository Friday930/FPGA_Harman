`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/21 12:12:09
// Design Name: 
// Module Name: prj_uart_stopwatch
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


module prj_uart_stopwatch(
    input           clk,
    input           rst,
    input           fifo_rx,
    output          fifo_tx,

    input   [1:0]   sw,
    output              [3:0] fnd_comm,
    output              [7:0] fnd_font,
    output              [3:0] led
    );

    wire            loopback;
    wire    [7:0]   ctrl;
    wire            r, c, h, m, s;

    uart_fifo U_UART_FIFO(
        .clk        (clk),
        .rst        (rst),
        .rx         (fifo_rx),
        .tx         (fifo_tx)
    );

    uart_CU U_UART_CU(
        .clk        (clk),
        .rst        (rst),
        .loopback   (U_UART_FIFO.data),
        .inst       (ctrl)
    );
    
    cmd_decoder U_CMD(
        .clk        (clk),
        .rst        (rst),
        .ctrl       (ctrl),
        .r          (r),
        .c          (c),
        .h          (h),
        .m          (m),
        .s          (s)
    );
    
    top_stopwatch U_Stopwatch_watch(
        .clk        (clk), 
        .reset      (rst),
        .btn_run    (r),
        .btn_clear  (c),
        .btn_hour   (h),
        .btn_min    (m),
        .btn_sec    (s),
        .sw         (sw),
        .fnd_comm   (fnd_comm),
        .fnd_font   (fnd_font),
        .led        (led)
    );

    ila_0 U_ila(
        .clk(clk),


        .probe0(h),
        .probe1(fnd_font)
    );

endmodule

module cmd_decoder(
    input clk,
    input rst,
    input [7:0] ctrl,
    output reg r,
    output reg c,
    output reg h,
    output reg m,
    output reg s
);

    always @(ctrl) begin
        // 기본값: 모두 0
        r = 0;
        c = 0;
        h = 0;
        m = 0;
        s = 0;
        
        case(ctrl)
            8'h52, 8'h72: r = 1; // "R", "r"의 ASCII 코드
            8'h43, 8'h63: c = 1; // "C", "c"의 ASCII 코드
            8'h48, 8'h68: h = 1; // "H", "h"의 ASCII 코드
            8'h4D, 8'h6D: m = 1; // "M", "m"의 ASCII 코드
            8'h53, 8'h73: s = 1; // "S", "s"의 ASCII 코드
            default: ;          // 모두 0 유지
        endcase
    end
endmodule

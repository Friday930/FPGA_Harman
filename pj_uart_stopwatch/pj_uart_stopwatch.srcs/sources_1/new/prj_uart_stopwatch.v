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
    output          fifo_tx
    );

    wire            loopback;
    wire    [7:0]   ctrl;
    wire            r, c, h, m, s;

    uart_fifo U_UART_FIFO(
        .clk        (clk),
        .rst        (rst),
        .rx         (rx),
        .tx         (tx)
    );

    uart_CU U_UART_CU(
        .clk        (clk),
        .rst        (rst),
        .loopback   (w_rx_data),
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
        .sw         (sw),
        .fnd_comm   (fnd_comm),
        .fnd_font   (fnd_font),
        .led        (led)
    );
endmodule

module cmd_decoder(
    input           clk,
    input           rst,
    input  [7:0]    ctrl,
    output reg      r,
    output reg      c,
    output reg      h,
    output reg      m,
    output reg      s
);
    always @(*) begin
        // 기본값: 모두 0
        r = 0;
        c = 0;
        h = 0;
        m = 0;
        s = 0;
        
        case(ctrl)
            "R", "r": r = 1;
            "C", "c": c = 1;
            "H", "h": h = 1;
            "M", "m": m = 1;
            "S", "s": s = 1;
            default: ; // 모두 0 유지
        endcase
    end
endmodule

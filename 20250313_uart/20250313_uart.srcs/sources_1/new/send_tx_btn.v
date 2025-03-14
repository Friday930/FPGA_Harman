`timescale 1ns / 1ps

module send_tx_btn(
    input               clk,
    input               rst,
    input               btn_start,
    output              tx
    );

    wire                w_start, w_tx_done;

    btn_debounce U_Start_btn(
    .i_btn              (btn_start), 
    .clk                (clk), 
    .reset              (rset),
    .o_btn              (w_start)
    );

    top_uart U_UART(
    .clk                (clk),
    .rst                (rst),
    .btn_start          (w_start),
    .tx                 (tx),
    .tx_done            (w_tx_done)
    );  

    // send tx ascii to PC

endmodule

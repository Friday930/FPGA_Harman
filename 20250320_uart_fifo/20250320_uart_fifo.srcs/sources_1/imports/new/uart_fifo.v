`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/20 11:57:49
// Design Name: 
// Module Name: uart_fifo
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


module uart_fifo(
    input           clk,
    input           rst,
    input           rx,
    output          tx
    );

    wire [7:0]      w_tx_data;
    wire            w_tx_done;
    wire [7:0]      w_rx_data;
    wire            w_rx_done;
    wire            empty;
    wire [7:0]      data;
    wire            tx_full;
    wire            rx_rd;
    wire            start;

    uart U_UART(
        .clk            (clk),
        .rst            (rst),
        .btn_start      (~start),
        .tx_data_in     (w_tx_data),
        .tx_done        (w_tx_done),
        .tx             (tx),   
        .rx             (rx),
        .rx_done        (w_rx_done),
        .rx_data        (w_rx_data)
    );   

    fifo U_FIFO_RX(
        .clk            (clk),
        .reset          (rst),
        .wr             (w_rx_done),
        .wdata          (w_rx_data),
        .full           (),
        .rd             (~rx_rd),
        .rdata          (data),
        .empty          (empty)
    );

    fifo U_FIFO_TX(
        .clk            (clk),
        .reset          (rst),
        .wr             (~empty),
        .wdata          (data),
        .full           (rx_rd),
        .rd             (~w_tx_done&(~start)),
        .rdata          (w_tx_data),
        .empty          (start)
    );
endmodule

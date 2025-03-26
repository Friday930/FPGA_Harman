`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/26 11:15:21
// Design Name: 
// Module Name: ultrasonic
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


module ultrasonic(
    input               clk,
    input               rst,
    input               btn_start,
    input               rx,
    input               tx,
    output  [7:0]       fnd_font,
    output  [3:0]       fnd_comm
    );

    wire    [15:0]      dist;
    wire                echo, trigger, done;

    // uart_fifo U_UART_FIFO(
    //     .clk            (clk),
    //     .rst            (rst),
    //     .rx             (rx),
    //     .tx             (tx)
    // );

    top_ultrasonic U_top_Ultrasonic(
        .clk            (clk),    
        .reset          (rst),
        .btn_start      (btn_start),  
        .echo           (echo),   
        .trigger        (trigger),    
        .dist           (dist),
        .done           (done)
    );

    fnd_controller U_FND_Ctrl_US(
        .clk            (clk),
        .reset          (rst),
        .data           (dist),
        .fnd_font       (fnd_font),
        .fnd_comm       (fnd_comm)
    );

endmodule

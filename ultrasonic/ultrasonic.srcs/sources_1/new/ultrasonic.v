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
    input               echo,       // 초음파 센서 에코 핀 추가
    input               rx,
    output              tx,
    output              trigger,    // 트리거 핀 출력 추가
    output  [7:0]       fnd_font,
    output  [3:0]       fnd_comm
    );

    wire    [15:0]      dist;
    wire                done;
    wire                w_start;

    uart_fifo U_UART_FIFO(
        .clk            (clk),
        .rst            (rst),
        .rx             (rx),
        .tx             (tx)
    );

    btn_debounce U_BTN(
        .clk            (clk),
        .reset          (rst),
        .i_btn          (btn_start), 
        .o_btn          (w_start)
    );

    top_ultrasonic U_UltraSonic(
        .clk            (clk),        
        .reset          (rst),      
        .btn_start      (w_start),  
        .echo           (echo),       // 외부에서 들어오는 echo 신호와 연결
        .trigger        (trigger),    // 외부로 나가는 trigger 신호와 연결
        .dist           (dist),       
        .data_valid     (done)  
    );

    fnd_controller U_FND_Ctrl_US(
        .clk            (clk),
        .reset          (rst),
        .data           (dist),
        .fnd_font       (fnd_font),
        .fnd_comm       (fnd_comm)
    );

endmodule

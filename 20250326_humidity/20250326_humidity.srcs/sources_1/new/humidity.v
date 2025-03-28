`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/27 11:27:53
// Design Name: 
// Module Name: humidity
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


module humidity(
    input               clk,
    input               rst,
    input               btn_start,
    inout               dht_io,
    output  [7:0]       fnd_font,
    output  [3:0]       fnd_comm
    );

    wire    [15:0]      humidity_data;
    wire    [15:0]      celcius_data;
    wire    [31:0]      display_data; // FND에 표시할 데이터 (32비트)

    assign              display_data = {humidity_data, celcius_data};

    fnd U_FND(
        .clk            (clk),
        .reset          (rst),
        .data           (display_data),
        .fnd_font       (fnd_font),
        .fnd_comm       (fnd_comm)
    );

    dht11_controller U_DHT11(
        .clk            (clk),
        .rst            (rst),
        .start          (btn_start),
        //.led_m(),
        .humidity       (humidity_data),
        .celcius        (celcius_data),
        .dht_io         (dht_io)
    );
    
endmodule

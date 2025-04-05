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
    input               sw,
    inout               dht_io,
    output  [7:0]       fnd_font,
    output  [3:0]       fnd_comm
    );

    wire    [15:0]      humidity_data;
    wire    [15:0]      celcius_data;
    
    wire    [15:0]      hum_display = humidity_data[15:8] * 100 + humidity_data[7:0];
    wire    [15:0]      temp_display = celcius_data[15:8] * 100 + celcius_data[7:0];

    wire    [31:0]      display_data; // FND에 표시할 데이터 (32비트)
    assign              display_data = sw ? {16'h0000, temp_display} : {16'h0000, hum_display};
    wire                btn;

    // assign              display_data = sw ? {16'h0000, celcius_data} : {16'h0000, humidity_data};

    fnd U_FND(
        .clk            (clk),
        .reset          (rst),
        .data           (display_data),
        .fnd_font       (fnd_font),
        .fnd_comm       (fnd_comm)
    );

    btn_debounce U_BTN(
        .i_btn          (btn_start),
        .clk            (clk),
        .reset          (rst),
        .o_btn          (btn)
    );

    dht11_controller U_DHT11(
        .clk            (clk),
        .rst            (rst),
        .start          (btn),
        //.led_m(),
        .humidity       (humidity_data),
        .celcius        (celcius_data),
        .dht_io         (dht_io)
    );
    
endmodule

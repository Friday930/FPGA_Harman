`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/27 10:47:17
// Design Name: 
// Module Name: tb_dht11
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


module tb_dht11();

    reg             clk;
    reg             rst;
    reg             btn_start;

    reg             dht_sensor_data;
    reg             en;

    wire            led;
    wire            dht_io;

    // tb io mode 변환
    assign          dht_io = (en) ? dht_sensor_data : 1'bz;

    dht11_controller dut(
    .clk            (clk),
    .rst            (rst),
    .start          (btn_start),
    .led_m          (led),
    .dht_io         (dht_io)
    );

    always  #5      clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        en = 0;
        btn_start = 0;

        #100;
        rst = 0;
        #100;
        btn_start = 1;
        #100;
        btn_start = 0;
        #10000;
        wait        (dht_io)
        #30000;

        // 입력모드 변환
        en = 1;
        dht_sensor_data = 1'b0;
        #80000;
        dht_sensor_data = 1'b1;
        #80000;
        #50000;
        $stop;
    end

endmodule

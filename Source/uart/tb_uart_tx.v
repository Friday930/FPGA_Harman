`timescale 1ns / 1ps


module tb_uart_tx();

    reg             clk;
    reg             rst;
    // reg             tx_start_trig;
    // reg             [7:0] tx_din;

    wire            tx_dout;
    wire            w_tick;
    wire            w_rx_done;
    wire            [7:0] rx_data;
    reg             rx;

    uart_tx UART_DUT(
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .start_trigger(btn_start),
        .data_in(tx_data_in),
        .o_tx(tx),
        .o_tx_done(tx_done)
    );

    //  top_uart dut(
    //      .clk        (clk),
    //      .rst        (rst),
    //      .btn_start  (tx_start_trig),
    //      .tx_data_in(tx_din),
    //      .tx(tx_dout),
    //      .tx_done   (tx_done)      
    //  );  

    // send_tx_btn dut1(
    //     .clk(clk),
    //     .rst(rst),
    //     .btn_start(tx_start_trig),
    //     .tx(tx_dout)
    // );
    uart_rx dut2(
    .clk(clk),
    .rst(rst),
    .tick(w_tick),
    .rx(rx),
    .rx_done(w_rx_done),
    .rx_data(rx_data)
);
    baud_tick_gen U_BAUD_TICK(
    .clk(clk),
    .rst(rst),
    .baud_tick(w_tick)
); 

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        rx = 1;
        #10;
        rst = 0;
        #100;
        rx = 0;    // start
        #104160; // 9600 1bit
        rx = 0;     // data 0
        #104160; // 9600 1bit
        rx = 0;     // data 1
        #104160; // 9600 1bit
        rx = 0;     // data 2
        #104160; // 9600 1bit
        rx = 0;     // data 3
        #104160; // 9600 1bit
        rx = 0;     // data 4
        #104160; // 9600 1bit
        rx = 0;     // data 5
        #104160; // 9600 1bit
        rx = 0;     // data 6
        #104160; // 9600 1bit
        rx = 0;     // data 7
        #104160; // 9600 1bit
        rx = 1;     // stop
        #10000; 
        $stop;
        
        // tx_din = 8'b01010101;
        // tx_start_trig = 1'b0;

        // #20 rst = 1'b0;
        // #20000 tx_start_trig = 1'b1;
        // #20000000 tx_start_trig = 1'b0;
    end

endmodule

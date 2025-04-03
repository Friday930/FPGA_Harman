`timescale 1ns / 1ps

module tb_uart();
    reg           clk;
    reg           reset;
    reg   [7:0]   tx_data;
    reg           tx_start;
    reg           rx;
    wire  [7:0]   rx_data;
    wire          rx_done;
    wire          tx_busy;
    wire          tx_done;
    wire          tx;
    
    uart dut(
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .rx(tx),// loop
        .rx_data(rx_data),
        .rx_done(rx_done),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx(tx)
    );

    always  #5      clk = ~clk;

    initial begin
        clk = 0; reset = 1;
        #10 reset = 0;

        @(posedge clk);
        #1 tx_data = 8'b11001010; tx_start = 1;
        @(posedge clk);
        #1 tx_start = 0;
        // @(posedge tx_done); // tx_done 될때까지 기다림
        // #20;
        @(posedge rx_done); // tx_done 될때까지 기다림
        #20;
        $finish;
    end

endmodule

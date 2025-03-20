`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/20 09:35:04
// Design Name: 
// Module Name: tb_fifo_2
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


module tb_fifo_2();
    reg         clk;
    reg         reset;
    reg         wr;
    reg [7:0]   wdata;
    reg         rd;
    wire        full;
    wire [7:0]  rdata;
    wire        empty;
    

    fifo dut(
        .clk    (clk),
        .reset  (reset),
        .wr     (wr),
        .wdata  (wdata),
        .full   (full),
        .rd     (rd),
        .rdata  (rdata),
        .empty  (empty)
    );

    always #5   clk = ~clk;
    integer     i;

    integer     rand_rd;
    integer     rand_wr;
    reg [7:0]   compare_data[2**4-1:0]; // 16byte buffer
    integer     write_count;
    integer     read_count;

    initial begin
        clk = 0;
        reset = 1;
        wdata = 0;
        wr = 0;
        rd = 0;

        #10;
        reset = 0;
        #10;

        // 쓰기(full) test
        wr = 1;
        for (i = 0; i < 17 ; i = i + 1 ) begin
            wdata = i;
            #10;
        end

        // 읽기(empty) test
        wr = 0;
        rd = 1;
        for (i = 0; i < 17 ; i = i + 1 ) begin
            #10;
        end      
        wr = 0;
        rd = 0;  
        #10;
        // 동시 읽고 쓰기
        wr = 1;
        rd = 1;
        for (i = 0; i < 17 ; i = i + 1 ) begin
            wdata = i * 2 + 1;
            #10;
        end

        for (i = 0 ; i < 50 ; i = i + 1) begin
            @(negedge clk); // 5ns clk
            rand_wr = $random%2;
            if (~full & rand_wr) begin
                wdata = $random%256; // 모든 값 집어넣기 위해 <- 256
            end
        end
    end
endmodule

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

    reg         rand_rd;
    reg         rand_wr;
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
        wr = 0;
        #10;
        rd = 0;
        #20; // empty 만들고 delay
        write_count = 0;
        read_count = 0;
        for (i = 0 ; i < 50 ; i = i + 1) begin
            @(negedge clk); // 5ns clk  // 쓰기 wdata를 negedge에서 시작하기 위함
            rand_wr = $random%2;        // wr 랜덤으로 1, 0 만들기
            if (~full && rand_wr) begin // full 아니면서 wr이 1일때만 새로운 wdata 생성
                wdata = $random%256; // wdata random 값 생성
                compare_data[write_count%2**4] = wdata; // read data와 비교하기 위함
                write_count = write_count + 1;
                wr = 1;
            end else begin
                wr = 0;
            end

            rand_rd = $random%2;      // rd random으로 생성 0, 1
            if (~empty&rand_rd) begin // read test
                #2;
                rd = 1;
                if (rdata == compare_data[read_count%16]) begin // rdata와 compare_data를 비교하여 출력
                    $display("pass");
                end else begin
                    $display("fail : rdata = %h, compare_data = %h", rdata, compare_data[read_count%16]);
                end
                read_count = read_count + 1;
            end else begin
                rd = 0;
            end
        end
    end
endmodule

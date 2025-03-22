`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 11:54:49
// Design Name: 
// Module Name: tb_mem_ip
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


module tb_mem_ip();

    parameter ADDR_WIDTH = 4, DATA_WIDTH = 8;

    reg         clk;
    reg         [ADDR_WIDTH-1:0] waddr;
    reg         [DATA_WIDTH-1:0] wdata;
    reg         wr;
    wire        [DATA_WIDTH-1:0] rdata;

    ram_ip DUT(
        .clk    (clk),
        .wr     (wr),
        .waddr  (waddr),
        .wdata  (wdata),
        .rdata  (rdata)
    );

    always #5   clk = ~clk;
    integer     i;
    reg         [DATA_WIDTH-1:0] radn_data;
    reg         [ADDR_WIDTH-1:0] radn_addr;

    initial begin
        clk = 0;
        waddr = 0;
        wdata = 0;
        wr = 0;
        #10;

        for (i = 0; i < 50; i = i + 1) begin
            @(posedge clk);
            // 난수 발생기
            radn_addr = $random%16; // 16가지 난수 중에 하나를 만든다
            radn_data = $random%256; // 난수의 모수 256가지

            // write
            wr = 1;
            waddr = radn_addr;
            wdata = radn_data;
            // @(posedge clk);

            //read
            waddr = radn_addr;
            #10;
            // == 값 비교, === case 비교 (0, 1, x, z 다 비교)
            if (rdata === wdata) begin // 출력과 입력이 같은지 비교
                $display("pass");
            end else $display("fail addr = %d, data = %h", waddr, rdata);
        end 
        #100;
        $stop;
    end

endmodule

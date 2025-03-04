`timescale 1ns / 1ps

module tb_cnt;
    reg clk,rst;
    wire [7:0] cnt;

    counter_up u0(clk,rst,cnt);

    always
        #10 clk = ~clk;
    
    initial begin
        clk = 1'b0;
        rst = 1'b0;
        #20 rst = 1'b1;
    end
endmodule
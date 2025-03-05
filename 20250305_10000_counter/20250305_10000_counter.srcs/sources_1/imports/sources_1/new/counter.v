`timescale 1ns / 1ps

module counter(
    input clk, rst,
    output [$clog2(10000) - 1:0] cnt
    );
    reg [$clog2(10000) - 1:0] count;
    assign cnt = count;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
        end else begin
                count <= count + 1;
            end
        
        end
endmodule

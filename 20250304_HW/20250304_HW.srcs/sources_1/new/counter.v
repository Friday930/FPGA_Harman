`timescale 1ns / 1ps

module counter(
    input clk, rst,
    output reg[19:0] cnt
    );

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt <= 0;
        end else begin cnt <= cnt + 1; end
    end
endmodule

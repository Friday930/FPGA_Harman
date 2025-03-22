`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 10:39:57
// Design Name: 
// Module Name: tb_register
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


module tb_register;

    reg         clk;
    reg         [31:0] d;
    wire        [31:0] q;

    register dut(
        .clk    (clk),
        .d      (d),
        .q      (q)
    );

    // clk generate
    always      #5 clk = ~clk;

    initial begin
        clk = 0;
        d = 32'h0;

        #10;
        d = 32'h0123_adcd;
        #10;
        @(posedge clk);
        if (d == q) begin
            $display ("pass");
        end else $display ("fail");

        @(posedge clk);
        $stop;
    end

endmodule

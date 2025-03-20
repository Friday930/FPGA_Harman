`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 16:34:22
// Design Name: 
// Module Name: tb_fifo
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


module tb_fifo();

    
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

    initial begin
        clk = 0;
        reset = 1;
        wdata = 0;
        wr = 0;
        rd = 0;

        #10;
        reset = 0;

        #10;
        wr = 1;
        wdata = 8'haa;
        #10; 
        wdata = 8'h55;
        #10;
        wdata = 8'ha7;
        #10; 
        wdata = 8'h23;
        #10;
        wdata = 8'hda;
        #10; 
        wdata = 8'h81;
        #10;
        wdata = 8'h67;
        #10; 
        wdata = 8'h25;
        #10;
        wdata = 8'hfa;
        #10; 
        wdata = 8'hce;
        #10;
        wdata = 8'h12;
        #10; 
        wdata = 8'h95;
        #10;
        wdata = 8'had;
        #10; 
        wdata = 8'h20;
        #10;
        wdata = 8'h45;
        #10;
        wdata = 8'hff;
        #10;
        wdata = 8'h90;
        #10;
        wdata = 8'hff;
        #10;
        wr = 0;
        rd = 1;
        #20;
        $stop;

    end

endmodule

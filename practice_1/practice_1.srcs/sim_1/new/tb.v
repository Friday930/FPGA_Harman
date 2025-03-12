`timescale 1ns / 1ps

// module blk();
//     reg     clk, a, b;

//     initial begin
//         a = 0;
//         b = 1;
//         clk = 0;
//     end

//     always
//         clk = #5 ~clk;
    
//     always @(posedge clk) begin
//         a = b; // a = 1
//         b = a; // b = a = 1
//     end
// endmodule

// module non_blk ();
//     reg     clk, a, b;

//     initial begin
//         a = 0;
//         b = 1;
//         clk = 0;
//     end

//     always
//         clk = #5 ~clk;

//     always @(posedge clk) begin
//         a <= b;
//         b <= a;
//     end
// endmodule

`timescale 1ns/1ps
module TB;
  reg clk, rst_n, x;
  wire z;
  
  seq_detector_1010 sd(clk, rst_n, x, z);
  initial clk = 0;   
  always #2 clk = ~clk;
    
  initial begin
    x = 0;
    #1 rst_n = 0;
    #2 rst_n = 1;
    
    #3 x = 1;
    #4 x = 1;
    #4 x = 0;
    #4 x = 1;
    #4 x = 0;
    #4 x = 1;
    #4 x = 0;
    #4 x = 1;
    #4 x = 1;
    #4 x = 1;
    #4 x = 0;
    #4 x = 1;
    #4 x = 0;
    #4 x = 1;
    #4 x = 0;
    #10;
    $finish;
  end
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
endmodule

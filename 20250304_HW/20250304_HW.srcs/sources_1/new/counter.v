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

// module counter (
//     input clk, reset,
//     output [$clog2(10000) - 1:0] cnt
// );
//     reg [$clog2(10000) - 1:0] r_counter;
//     assign cnt = r_counter;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             r_counter <= 0;
//         end      
//         else begin
//             r_counter <= r_counter + 1;
//         end  
//     end
    
// endmodule

// module clk_gen (
//     reg clk;

//     initial begin
//         clk <= 0;
//         #5 forever begin
//         #(10/2) clk = ~clk;
//         end
//     end
// );
    
// endmodule

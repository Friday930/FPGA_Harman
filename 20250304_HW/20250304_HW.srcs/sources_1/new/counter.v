`timescale 1ns / 1ps

// module counter(
//     input clk, rst,
//     output reg [$clog2(10000) - 1:0] cnt
//     );
//     reg [$clog2(10000) - 1:0] o_cnt;
//     assign o_cnt = cnt;
//     always @(posedge clk, posedge rst) begin
//         if (rst) begin
//             o_cnt <= 0;
//         end else begin 
//             if(o_cnt == 10000-1) begin
//                 o_cnt <= 0;
//             end else begin
//                 o_cnt <= o_cnt + 1;
//             end
        
//         end
//     end
// endmodule

module counter (
    input clk, reset,
    output [$clog2(10000) - 1:0] cnt
);
    reg [$clog2(10000) - 1:0] r_counter;
    assign cnt = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end      
        else begin
            r_counter <= r_counter + 1;
        end  
    end
    
endmodule

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

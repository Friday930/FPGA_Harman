`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 10:32:17
// Design Name: 
// Module Name: register
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


module register(
    input           clk,
    input           [31:0] d,
    // input           [3:0] addr,
    output          [31:0] q
    );

    // reg             [31:0] q_reg[15:0]; // 32bit memory
    reg             [31:0] q_reg; // 32bit memory
    // assign          q = q_reg[addr];
    assign          q = q_reg;

    always @(posedge clk) begin
        // q_reg[addr] <= d;
        q_reg <= d;
    end
endmodule

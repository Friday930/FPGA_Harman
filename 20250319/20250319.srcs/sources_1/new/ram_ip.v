`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 11:29:03
// Design Name: 
// Module Name: ram_ip
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


module ram_ip #(
    parameter ADDR_WIDTH = 4, 
    DATA_WIDTH = 8
)(
    input           clk,
    input           wr,
    input           [ADDR_WIDTH-1:0] waddr,
    input           [DATA_WIDTH-1:0] wdata,
    output          [DATA_WIDTH-1:0] rdata
);

    reg             [DATA_WIDTH-1:0] ram[0:2**(ADDR_WIDTH-1)]; // 2**4 == 2의 4승
    
    // write
    always @(posedge clk) begin
        if (wr) begin
            ram[waddr] <= wdata;
        end
    end
    
    assign         rdata = ram[waddr];
    // read
    // reg             [DATA_WIDTH-1:0] rdata;
    // assign          rdata = rdata_reg
    // always @(posedge clk) begin
    //     if (!wr) begin
    //         rdata <= ram[waddr];
    //     end
    // end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 15:10:16
// Design Name: 
// Module Name: fifo
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


module fifo(
    input           clk,
    input           reset,
    
    input           wr,
    input [7:0]     wdata,
    output          full,

    input           rd,
    output [7:0]    rdata,
    output          empty
    );

    // module instance

    wire [3:0]      waddr, raddr;
    fifo_control_unit U_FIFO_CU(
        .clk        (clk),
        .reset      (reset),
        .wr         (wr),
        .waddr      (waddr),
        .full       (full),
        .rd         (rd),
        .raddr      (raddr),
        .empty      (empty)
    );

    register_file U_REG_FILE(
        .clk        (clk),
        .waddr      (waddr),
        .wdata      (wdata),
        .wr         ({~full&wr}),
        .raddr      (raddr),
        .rdata      (rdata)
    );

endmodule

module register_file (
    input           clk,

    input [3:0]     waddr, // 4bit
    input [7:0]     wdata, // 8bit
    input           wr,

    input [3:0]     raddr,
    output [7:0]    rdata
);

    reg         [7:0] mem [0:(2**4)-1]; // 4bit address

    // write
    always @(posedge clk) begin
        if (wr) begin
            mem[waddr] <= wdata;
        end
    end

    // read
    assign      rdata = mem[raddr];

endmodule

module fifo_control_unit (
    input           clk,
    input           reset,

    input           wr,
    output [3:0]    waddr,
    output          full,

    input           rd,
    output [3:0]    raddr,
    output          empty
);
    // 1bit 상태 output
    reg             full_reg, full_next, empty_reg, empty_next; // 출력 내보내기 위한 fsm
    // W/R address 관리
    reg [3:0]       wptr_reg, wptr_next, rptr_reg, rptr_next;

    assign          waddr = wptr_reg;
    assign          raddr = rptr_reg;
    assign          full = full_reg;
    assign          empty = empty_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            full_reg <= 0;
            empty_reg <= 1; // empty 초기값 1
            wptr_reg <= 0;
            rptr_reg <= 0;
        end else begin
            full_reg <= full_next;
            empty_reg <= empty_next;
            wptr_reg <= wptr_next;
            rptr_reg <= rptr_next;
        end
    end

    // next
    always @(*) begin
        full_next = full_reg;
        empty_next = empty_reg;
        wptr_next = wptr_reg;
        rptr_next = rptr_reg;

        case ({wr,rd}) // state -> 외부에서 입력으로 변경됨

           2'b01: begin // rd = 1, read(pop)
                if (empty_reg == 1'b0) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 1'b0;
                    if (wptr_reg == rptr_next) begin
                        empty_next = 1'b1;
                    end
                end
           end

           2'b10: begin // wr = 1, write(push)
                if (full_reg == 1'b0) begin
                    wptr_next = wptr_reg + 1;
                    empty_next = 1'b0;
                    if (wptr_next == rptr_reg) begin // rptr_reg는 안변하므로 next랑 비교할 필요 X
                        full_next = 1'b1;
                    end
                end
           end 

           2'b11: begin
                // pop 먼저 조건(주소가 먼저 가버리면 데이터 다 버림)
                if (empty_reg == 1'b1) begin 
                    wptr_next = wptr_reg + 1;
                    empty_next = 1'b0;
                end else if (full_reg == 1'b1) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 1'b0;
                end else begin
                    wptr_next = wptr_reg + 1;
                    rptr_next = rptr_reg + 1;
                end
           end
        endcase
    end

endmodule

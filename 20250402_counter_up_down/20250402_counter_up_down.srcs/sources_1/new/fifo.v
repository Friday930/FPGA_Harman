`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/02 16:49:39
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


`timescale 1ns / 1ps

module fifo #(
    parameter DEPTH = 64,         // FIFO 메모리 깊이
    parameter ADDR_WIDTH = 6,     // 주소 비트 폭 (DEPTH = 2^ADDR_WIDTH)
    parameter DATA_WIDTH = 8      // 데이터 비트 폭
)(
    input                   clk,
    input                   reset,
    
    input                   wr,
    input [DATA_WIDTH-1:0]  wdata,
    output                  full,

    input                   rd,
    output [DATA_WIDTH-1:0] rdata,
    output                  empty
);

    // 내부 신호
    wire [ADDR_WIDTH-1:0]   waddr, raddr;
    wire                    wr_en;  // 실제 쓰기 활성화 신호
    
    // 컨트롤 유닛 인스턴스
    fifo_control_unit #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) U_FIFO_CU (
        .clk        (clk),
        .reset      (reset),
        .wr         (wr),
        .waddr      (waddr),
        .full       (full),
        .rd         (rd),
        .raddr      (raddr),
        .empty      (empty)
    );

    // FIFO가 가득 차면 쓰기 금지
    assign wr_en = wr & ~full;

    // 메모리 인스턴스
    register_file #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) U_REG_FILE (
        .clk        (clk),
        .waddr      (waddr),
        .wdata      (wdata),
        .wr         (wr_en),
        .raddr      (raddr),
        .rdata      (rdata)
    );

endmodule

module register_file #(
    parameter ADDR_WIDTH = 6,     // 주소 비트 폭
    parameter DATA_WIDTH = 8,     // 데이터 비트 폭
    parameter DEPTH = 64          // 메모리 깊이
)(
    input                   clk,

    input [ADDR_WIDTH-1:0]  waddr,
    input [DATA_WIDTH-1:0]  wdata,
    input                   wr,

    input [ADDR_WIDTH-1:0]  raddr,
    output [DATA_WIDTH-1:0] rdata
);

    // 메모리 선언
    reg [DATA_WIDTH-1:0]    mem [0:DEPTH-1];

    // 쓰기 로직
    always @(posedge clk) begin
        if (wr) begin
            mem[waddr] <= wdata;
        end
    end

    // 읽기 로직
    assign rdata = mem[raddr];

endmodule

module fifo_control_unit #(
    parameter ADDR_WIDTH = 6      // 주소 비트 폭
)(
    input                   clk,
    input                   reset,

    input                   wr,
    output [ADDR_WIDTH-1:0] waddr,
    output                  full,

    input                   rd,
    output [ADDR_WIDTH-1:0] raddr,
    output                  empty
);
    // FIFO 포인터는 주소 비트 + 1비트(MSB)로 구성
    // MSB는 랩어라운드 감지용
    reg [ADDR_WIDTH:0]      wptr_reg, wptr_next;
    reg [ADDR_WIDTH:0]      rptr_reg, rptr_next;
    
    // 상태 출력
    wire                    full_next;
    wire                    empty_next;
    
    // 실제 주소는 포인터의 하위 비트
    assign waddr = wptr_reg[ADDR_WIDTH-1:0];
    assign raddr = rptr_reg[ADDR_WIDTH-1:0];
    
    // 상태 계산 - 포인터의 전체 비트를 비교
    assign full_next = (wptr_next[ADDR_WIDTH] != rptr_next[ADDR_WIDTH]) && 
                      (wptr_next[ADDR_WIDTH-1:0] == rptr_next[ADDR_WIDTH-1:0]);
    assign empty_next = (wptr_next == rptr_next);
    
    // 상태 레지스터
    reg full_reg, empty_reg;
    
    // 상태 출력
    assign full = full_reg;
    assign empty = empty_reg;
    
    // 상태 레지스터 업데이트
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            wptr_reg <= 0;
            rptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;  // 초기 상태는 비어있음
        end else begin
            wptr_reg <= wptr_next;
            rptr_reg <= rptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
        end
    end
    
    // 다음 상태 계산
    always @(*) begin
        // 기본값 유지
        wptr_next = wptr_reg;
        rptr_next = rptr_reg;
        
        case ({wr, rd})
            // 아무 동작 없음
            2'b00: begin
                // 포인터 변경 없음
            end
            
            // 읽기만 진행
            2'b01: begin
                if (!empty_reg) begin  // FIFO가 비어있지 않을 때만 읽기
                    rptr_next = rptr_reg + 1;  // 읽기 포인터 증가
                end
            end
            
            // 쓰기만 진행
            2'b10: begin
                if (!full_reg) begin  // FIFO가 가득 차지 않을 때만 쓰기
                    wptr_next = wptr_reg + 1;  // 쓰기 포인터 증가
                end
            end
            
            // 읽기와 쓰기 동시 진행
            2'b11: begin
                if (!empty_reg) begin  // 비어있지 않으면 읽기 가능
                    rptr_next = rptr_reg + 1;
                end
                
                if (!full_reg) begin  // 가득 차지 않았으면 쓰기 가능
                    wptr_next = wptr_reg + 1;
                end
            end
        endcase
    end
    
endmodule

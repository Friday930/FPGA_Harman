`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/21 12:12:09
// Design Name: 
// Module Name: prj_uart_stopwatch
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


module prj_uart_stopwatch(
    input           clk,
    input           rst,
    input           fifo_rx,
    output          fifo_tx,

    input   [1:0]   sw,
    output  [3:0]   fnd_comm,
    output  [7:0]   fnd_font,
    output  [3:0]   led
    );

    wire            loopback;
    wire    [7:0]   ctrl;
    wire            r, c, h, m, s;

    uart_fifo U_UART_FIFO(
        .clk        (clk),
        .rst        (rst),
        .rx         (fifo_rx),
        .tx         (fifo_tx)
    );

    uart_CU U_UART_CU(
        .clk        (clk),
        .rst        (rst),
        .loopback   (U_UART_FIFO.data),
        .inst       (ctrl)
    );
    // 명령어 버퍼 추가
    // wire [7:0] buffered_cmd;
    // wire       cmd_ready;
    
    // command_buffer U_CMD_BUFFER(
    //     .clk        (clk),
    //     .rst        (rst),
    //     .cmd_in     (ctrl),
    //     .cmd_valid  (|ctrl), // ctrl이 0이 아니면 유효
    //     .cmd_out    (buffered_cmd),
    //     .cmd_ready  (cmd_ready)
    // );
        
    cmd_decoder U_CMD(
        .clk        (clk),
        .rst        (rst),
        .ctrl       (ctrl),
        .r          (r),
        .c          (c),
        .h          (h),
        .m          (m),
        .s          (s)
    );
    
    top_stopwatch U_Stopwatch_watch(
        .clk        (clk), 
        .reset      (rst),
        .btn_run    (r),
        .btn_clear  (c),
        .btn_hour   (h),
        .btn_min    (m),
        .btn_sec    (s),
        .sw         (sw),
        .fnd_comm   (fnd_comm),
        .fnd_font   (fnd_font),
        .led        (led)
    );

    // ila_0 U_ila(
    //     .clk(clk),


    //     .probe0(h),
    //     .probe1(fnd_font)
    // );

endmodule

module cmd_decoder(
    input clk,
    input rst,
    input [7:0] ctrl,
    output reg r,
    output reg c,
    output reg h,
    output reg m,
    output reg s
);

    always @(ctrl) begin
        // 기본값: 모두 0
        r = 0;
        c = 0;
        h = 0;
        m = 0;
        s = 0;
        
        case(ctrl)
            8'h52, 8'h72: r = 1; // "R", "r"의 ASCII 코드
            8'h43, 8'h63: c = 1; // "C", "c"의 ASCII 코드
            8'h48, 8'h68: h = 1; // "H", "h"의 ASCII 코드
            8'h4D, 8'h6D: m = 1; // "M", "m"의 ASCII 코드
            8'h53, 8'h73: s = 1; // "S", "s"의 ASCII 코드
            default: ;          // 모두 0 유지
        endcase
    end
endmodule

// module command_buffer(
//     input           clk, 
//     input           rst,
    
//     // 입력 명령 (UART/FIFO로부터)
//     input [7:0]     cmd_in,     // 입력 명령어
//     input           cmd_valid,  // 명령어 유효 신호
    
//     // 출력 명령 (시계 모듈로)
//     output reg [7:0] cmd_out,    // 출력 명령어
//     output reg       cmd_ready   // 명령어 준비 완료 신호
// );

//     // 상태 정의
//     localparam IDLE = 2'b00;
//     localparam CMD_RECEIVED = 2'b01;
//     localparam CMD_PROCESSING = 2'b10;
//     localparam CMD_COMPLETE = 2'b11;
    
//     // 상태 변수
//     reg [1:0] state, next_state;
    
//     // 내부 명령어 저장
//     reg [7:0] current_cmd;
    
//     // 상태 머신 - 상태 업데이트
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             state <= IDLE;
//             cmd_out <= 8'h00;
//             cmd_ready <= 1'b0;
//             current_cmd <= 8'h00;
//         end else begin
//             state <= next_state;
            
//             // CMD_RECEIVED 상태에서만 명령어 저장 및 출력
//             if (state == IDLE && cmd_valid && cmd_in != 8'h00) begin
//                 current_cmd <= cmd_in;
//                 cmd_out <= cmd_in;
//                 cmd_ready <= 1'b1;
//             end
            
//             // 처리 완료되면 ready 신호 내림
//             if (state == CMD_COMPLETE) begin
//                 cmd_ready <= 1'b0;
//             end
//         end
//     end
    
//     // 상태 머신 - 다음 상태 결정
//     always @(*) begin
//         next_state = state;
        
//         case (state)
//             IDLE: begin
//                 // 유효한 명령이 들어오면 다음 상태로
//                 if (cmd_valid && cmd_in != 8'h00) begin
//                     next_state = CMD_RECEIVED;
//                 end
//             end
            
//             CMD_RECEIVED: begin
//                 next_state = CMD_PROCESSING;
//             end
            
//             CMD_PROCESSING: begin
//                 // 명령 처리 중 - 현재 명령 완료 대기
//                 if (!cmd_valid) begin
//                     next_state = CMD_COMPLETE;
//                 end
//             end
            
//             CMD_COMPLETE: begin
//                 // 처리 완료 후 IDLE로 돌아감
//                 next_state = IDLE;
//             end
            
//             default: next_state = IDLE;
//         endcase
//     end

// endmodule

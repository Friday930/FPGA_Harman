`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/21 11:38:12
// Design Name: 
// Module Name: tb_uart_cu
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


// module tb_uart_CU();

//     reg             clk;
//     reg             rst;
//     reg [7:0]       loopback;
//     wire [7:0]      inst;
    
//     // uart_CU 인스턴스 생성
//     uart_CU uut (
//         .clk        (clk),
//         .rst        (rst),
//         .loopback   (loopback),
//         .inst       (inst)
//     );
    
//     // 클럭 생성: 10ns 주기 (5ns 하이, 5ns 로우)
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk;
//     end
    
//     // 테스트 시나리오
//     initial begin
//         // 초기화 및 리셋
//         rst = 1;
//         loopback = 8'b0;
//         #20;  // 20ns 대기
//         rst = 0;
//         #20;  // 리셋 후 안정화를 위한 대기
        
//         // 각 명령 테스트 - 충분한 간격을 두고 실행
        
//         // "R" 명령 테스트
//         loopback = "r";
//         #20;  // 클럭 2개 사이클 유지
//         loopback = 8'b0;
//         #20;  // 결과 관찰을 위한 대기
        
//         // "r" 명령 테스트
//         loopback = "r";
//         #20;
//         loopback = 8'b0;
//         #20;
        
//         // "C" 명령 테스트
//         loopback = "c";
//         #20;
//         loopback = 8'b0;
//         #20;
        
//         // "c" 명령 테스트
//         loopback = "c";
//         #20;
//         loopback = 8'b0;
//         #20;
        
//         // "H" 명령 테스트
//         loopback = "h";
//         #20;
//         loopback = 8'b0;
//         #20;
        
//         // "h" 명령 테스트
//         loopback = "h";
//         #20;
//         loopback = 8'b0;
//         #20;
        
//         // "M" 명령 테스트
//         loopback = "m";
//         #20;
//         loopback = 8'b0;
//         #20;
        
//         // "m" 명령 테스트
//         loopback = "M";
//         #20;
//         loopback = 8'b0;
//         #20;
        
//         // "S" 명령 테스트
//         loopback = "S";
//         #20;
//         loopback = 8'b0;
//         #20;
        
//         // "s" 명령 테스트
//         loopback = "s";
//         #20;
//         loopback = 8'b0;
//         #20;
        
//         // 시뮬레이션 종료
//         $finish;
//     end
    
//     // 신호 모니터링
//     initial begin
//         $monitor("Time = %0t | rst = %b | loopback = %c(%h) | inst = %c(%h)", 
//                  $time, rst, loopback, loopback, inst, inst);
//     end

// endmodule


// module tb_uart_cu();
//     reg clk;
//     reg rst;
//     reg [7:0] loopback;
//     wire [7:0] inst;
    
//     // UART_CU 모듈 인스턴스화
//     uart_CU uut (
//         .clk(clk),
//         .rst(rst),
//         .loopback(loopback),
//         .inst(inst)
//     );
    
//     // 클럭 생성
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk;
//     end
    
//     // 테스트 시나리오
//     initial begin
//         // 초기화
//         rst = 1;
//         loopback = 8'h00;
//         #20;
//         rst = 0;
//         #20;
        
//         // 테스트 1: 'R' 명령
//         loopback = 8'h52; // ASCII 'R'
//         #20;
        
//         // 테스트 2: 다른 값으로 변경
//         loopback = 8'h00; // 0으로 변경
//         #20;
        
//         // 테스트 3: 'r' 명령 (소문자)
//         loopback = 8'h72; // ASCII 'r'
//         #20;
        
//         // 테스트 4: 빠른 연속 변경
//         loopback = 8'h43; // C
//         #10;
//         loopback = 8'h68; // h
//         #10;
//         loopback = 8'h6D; // m
//         #10;
        
//         // 끝
//         #50;
//         $finish;
//     end
    
//     // 모니터링
//     initial begin
//         $monitor("Time: %0t, rst: %b, loopback: %h, inst: %h", 
//                  $time, rst, loopback, inst);
//     end
// endmodule

`timescale 1ns / 1ps

module edge_detection_tb;
    // 테스트 신호 생성용 파라미터
    parameter CLK_PERIOD = 10; // 10ns = 100MHz
    
    // 테스트베드 신호
    reg clk;
    reg rst;
    reg rx_done_reg_in;
    wire rx_done_pulse_out;
    
    // 엣지 검출 모듈 (DUT)
    edge_detector dut (
        .clk(clk),
        .rst(rst),
        .rx_done_reg_in(rx_done_reg_in),
        .rx_done_pulse_out(rx_done_pulse_out)
    );
    
    // 클럭 생성
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // 테스트 시나리오
    initial begin
        // 초기화
        rst = 1;
        rx_done_reg_in = 0;
        
        // 파형 출력 시작
        $dumpfile("edge_detection.vcd");
        $dumpvars(0, edge_detection_tb);
        
        // 리셋 해제
        #20 rst = 0;
        
        // 테스트 1: 한 번의 상승 엣지 (정상 케이스)
        #20 rx_done_reg_in = 1;
        #20 rx_done_reg_in = 0;
        
        // 테스트 2: 여러 클럭 동안 high 유지 (버튼 길게 누른 상황)
        #50;
        rx_done_reg_in = 1;
        #100;
        rx_done_reg_in = 0;
        
        // 테스트 3: 여러 번 빠르게 토글 (바운싱 상황)
        #50;
        rx_done_reg_in = 1;
        #15;
        rx_done_reg_in = 0;
        #10;
        rx_done_reg_in = 1;
        #5;
        rx_done_reg_in = 0;
        #8;
        rx_done_reg_in = 1;
        #30;
        rx_done_reg_in = 0;
        
        // 테스트 종료
        #100;
        $display("시뮬레이션 완료");
        $finish;
    end
    
endmodule

// 테스트 대상 엣지 검출 모듈
module edge_detector (
    input clk,
    input rst,
    input rx_done_reg_in,
    output rx_done_pulse_out
);
    // 내부 레지스터
    reg [1:0] rx_done_shift;
    reg rx_done_pulse;
    
    // 상승 엣지 검출 로직
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_done_shift <= 2'b00;
            rx_done_pulse <= 1'b0;
        end else begin
            // 엣지 검출 로직
            rx_done_shift <= {rx_done_shift[0], rx_done_reg_in};
            rx_done_pulse <= rx_done_shift[0] & ~rx_done_shift[1]; // 상승 엣지만 펄스 생성
        end
    end
    
    assign rx_done_pulse_out = rx_done_pulse;
endmodule
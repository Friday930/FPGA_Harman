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


module tb_uart_CU();

    reg             clk;
    reg             rst;
    reg [7:0]       loopback;
    wire [7:0]      inst;
    
    // uart_CU 인스턴스 생성
    uart_CU uut (
        .clk        (clk),
        .rst        (rst),
        .loopback   (loopback),
        .inst       (inst)
    );
    
    // 클럭 생성: 10ns 주기 (5ns 하이, 5ns 로우)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 테스트 시나리오
    initial begin
        // 초기화 및 리셋
        rst = 1;
        loopback = 8'b0;
        #20;  // 20ns 대기
        rst = 0;
        #20;  // 리셋 후 안정화를 위한 대기
        
        // 각 명령 테스트 - 충분한 간격을 두고 실행
        
        // "R" 명령 테스트
        loopback = "r";
        #20;  // 클럭 2개 사이클 유지
        loopback = 8'b0;
        #20;  // 결과 관찰을 위한 대기
        
        // "r" 명령 테스트
        loopback = "r";
        #20;
        loopback = 8'b0;
        #20;
        
        // "C" 명령 테스트
        loopback = "c";
        #20;
        loopback = 8'b0;
        #20;
        
        // "c" 명령 테스트
        loopback = "c";
        #20;
        loopback = 8'b0;
        #20;
        
        // "H" 명령 테스트
        loopback = "h";
        #20;
        loopback = 8'b0;
        #20;
        
        // "h" 명령 테스트
        loopback = "h";
        #20;
        loopback = 8'b0;
        #20;
        
        // "M" 명령 테스트
        loopback = "m";
        #20;
        loopback = 8'b0;
        #20;
        
        // "m" 명령 테스트
        loopback = "M";
        #20;
        loopback = 8'b0;
        #20;
        
        // "S" 명령 테스트
        loopback = "S";
        #20;
        loopback = 8'b0;
        #20;
        
        // "s" 명령 테스트
        loopback = "s";
        #20;
        loopback = 8'b0;
        #20;
        
        // 시뮬레이션 종료
        $finish;
    end
    
    // 신호 모니터링
    initial begin
        $monitor("Time = %0t | rst = %b | loopback = %c(%h) | inst = %c(%h)", 
                 $time, rst, loopback, loopback, inst, inst);
    end

endmodule


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
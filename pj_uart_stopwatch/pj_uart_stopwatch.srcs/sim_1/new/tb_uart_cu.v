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

// `timescale 1ns / 1ps

// module edge_detection_tb;
//     // 테스트 신호 생성용 파라미터
//     parameter CLK_PERIOD = 10; // 10ns = 100MHz
    
//     // 테스트베드 신호
//     reg clk;
//     reg rst;
//     reg rx_done_reg_in;
//     wire rx_done_pulse_out;
    
//     // 엣지 검출 모듈 (DUT)
//     edge_detector dut (
//         .clk(clk),
//         .rst(rst),
//         .rx_done_reg_in(rx_done_reg_in),
//         .rx_done_pulse_out(rx_done_pulse_out)
//     );
    
//     // 클럭 생성
//     initial begin
//         clk = 0;
//         forever #(CLK_PERIOD/2) clk = ~clk;
//     end
    
//     // 테스트 시나리오
//     initial begin
//         // 초기화
//         rst = 1;
//         rx_done_reg_in = 0;
        
//         // 파형 출력 시작
//         $dumpfile("edge_detection.vcd");
//         $dumpvars(0, edge_detection_tb);
        
//         // 리셋 해제
//         #20 rst = 0;
        
//         // 테스트 1: 한 번의 상승 엣지 (정상 케이스)
//         #20 rx_done_reg_in = 1;
//         #20 rx_done_reg_in = 0;
        
//         // 테스트 2: 여러 클럭 동안 high 유지 (버튼 길게 누른 상황)
//         #50;
//         rx_done_reg_in = 1;
//         #100;
//         rx_done_reg_in = 0;
        
//         // 테스트 3: 여러 번 빠르게 토글 (바운싱 상황)
//         #50;
//         rx_done_reg_in = 1;
//         #15;
//         rx_done_reg_in = 0;
//         #10;
//         rx_done_reg_in = 1;
//         #5;
//         rx_done_reg_in = 0;
//         #8;
//         rx_done_reg_in = 1;
//         #30;
//         rx_done_reg_in = 0;
        
//         // 테스트 종료
//         #100;
//         $display("시뮬레이션 완료");
//         $finish;
//     end
    
// endmodule

// // 테스트 대상 엣지 검출 모듈
// module edge_detector (
//     input clk,
//     input rst,
//     input rx_done_reg_in,
//     output rx_done_pulse_out
// );
//     // 내부 레지스터
//     reg [1:0] rx_done_shift;
//     reg rx_done_pulse;
    
//     // 상승 엣지 검출 로직
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             rx_done_shift <= 2'b00;
//             rx_done_pulse <= 1'b0;
//         end else begin
//             // 엣지 검출 로직
//             rx_done_shift <= {rx_done_shift[0], rx_done_reg_in};
//             rx_done_pulse <= rx_done_shift[0] & ~rx_done_shift[1]; // 상승 엣지만 펄스 생성
//         end
//     end
    
//     assign rx_done_pulse_out = rx_done_pulse;
// endmodule

`timescale 1ns / 1ps

module uart_rx_bug_tb;
    // 파라미터 정의
    parameter CLK_PERIOD = 10; // 10ns = 100MHz
    parameter UART_BAUD_RATE = 9600;
    parameter UART_BIT_PERIOD = 1_000_000_000 / UART_BAUD_RATE; // ns 단위
    
    // 내부 신호
    reg clk;
    reg rst;
    reg rx;
    wire rx_done;
    wire [7:0] rx_data;
    wire baud_tick;
    
    // 테스트용 카운터 - 수신된 명령 계수
    reg [3:0] command_count;
    
    // UART 모듈 인스턴스화
    baud_tick_gen U_BAUD_Tick_Gen(
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );
    
    uart_rx U_UART_RX(
        .clk(clk),
        .rst(rst),
        .tick(baud_tick),
        .rx(rx),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );
    
    // 클럭 생성
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // rx_done 신호 모니터링 - 버그 확인용
    always @(posedge clk) begin
        if (rst) begin
            command_count <= 0;
        end else if (rx_done) begin
            command_count <= command_count + 1;
            $display("Command detected at time %t, count = %d, rx_data = %h", $time, command_count, rx_data);
        end
    end
    
    // UART 문자 송신 태스크 정의
    task uart_send_byte;
        input [7:0] data;
        integer i;
        begin
            // 시작 비트 (0)
            rx = 0;
            #(UART_BIT_PERIOD);
            
            // 8비트 데이터 (LSB 먼저)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(UART_BIT_PERIOD);
            end
            
            // 정지 비트 (1)
            rx = 1;
            #(UART_BIT_PERIOD);
            
            // 유휴 상태
            #(UART_BIT_PERIOD);
        end
    endtask
    
    // 테스트 시나리오
    initial begin
        // 초기화
        rst = 1;
        rx = 1;  // UART 유휴 상태
        command_count = 0;
        
        // 리셋 해제
        #100;
        rst = 0;
        #100;
        
        // 버그 시연: 한 번의 문자 송신 후 rx_done이 여러 클럭 동안 HIGH 상태 유지
        $display("=== Test 1: Verifying bug where rx_done stays HIGH for multiple clock cycles ===");
        uart_send_byte(8'h41); // ASCII 'A'
        
        // rx_done 신호가 높은 상태로 얼마나 오래 유지되는지 확인
        #(UART_BIT_PERIOD * 5);
        
        // 다시 명령 전송
        $display("=== Test 2: Sending another command ===");
        uart_send_byte(8'h42); // ASCII 'B'
        #(UART_BIT_PERIOD * 5);
        
        // 여러 번 연속으로 명령 전송 - 같은 명령을 여러 번 전송해도 카운트 증가 확인
        $display("=== Test 3: Sending the same command 3 times in succession ===");
        uart_send_byte(8'h43); // ASCII 'C'
        #(UART_BIT_PERIOD * 2);
        uart_send_byte(8'h43); // ASCII 'C'
        #(UART_BIT_PERIOD * 2);
        uart_send_byte(8'h43); // ASCII 'C'
        #(UART_BIT_PERIOD * 5);
        
        // 테스트 종료
        #1000;
        $display("=== Test Complete: command_count = %d ===", command_count);
        $display("Bug Analysis: rx_done signal remains HIGH for multiple clock cycles instead of being active for just one clock");
        $display("As a result, instead of recognizing the same command multiple times, the signal stays HIGH for too long");
        $display("requiring waiting for rx_done to return LOW before sending the next command");
        $finish;
    end
endmodule
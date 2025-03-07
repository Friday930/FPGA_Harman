`timescale 1ns / 1ps

module mealy_fsm_tb;

    // 테스트벤치에서 사용할 신호 정의
    reg clk;
    reg reset;
    reg din_bit; // 입력 신호
    wire dout_bit; // 출력 신호

    // FSM 모듈 인스턴스화
    mealy_fsm dut (
        .clk(clk),
        .reset(reset),
        .din_bit(din_bit),
        .dout_bit(dout_bit)
    );

    // 클럭 생성 (10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 5ns마다 clk 토글
    end

    // 테스트 시나리오
    initial begin
        // 초기화
        reset = 1; din_bit = 0;
        #10 reset = 0; // 리셋 해제
        
        // 테스트 케이스: 연속된 입력 신호 검증
        #10 din_bit = 0;  // 첫 번째 0 입력 -> rd0_once 상태로 전환
        #10 din_bit = 0;  // 두 번째 0 입력 -> rd0_twice 상태로 전환 (out = 1)
        #10 din_bit = 1;  // 첫 번째 1 입력 -> rd1_once 상태로 전환 (out = 0)
        #10 din_bit = 1;  // 두 번째 1 입력 -> rd1_twice 상태로 전환 (out = 1)
        #10 din_bit = 0;  // 첫 번째 0 입력 -> rd0_once 상태로 전환 (out = 0)
        #10 din_bit = 1;  // 첫 번째 1 입력 -> rd1_once 상태로 전환 (out = 0)
        #10 din_bit = 1;  // 두 번째 1 입력 -> rd1_twice 상태로 전환 (out = 1)
        #5  din_bit = 0;
        #15  din_bit = 1;
        #20;
        
        // 리셋 테스트
        #10 reset = 1; // 리셋 활성화 -> START 상태로 복귀
        #10 reset = 0;

        // 추가 시나리오: 혼합된 입력 신호 검증
        #10 din_bit = 0;
        #10 din_bit = 1;
        #10 din_bit = 1;
        #10 din_bit = 0;
        #10 din_bit = 0;
        
        // 시뮬레이션 종료
        #20 $finish;
    end

    // 출력 모니터링
    initial begin
        $monitor("Time: %t | Reset: %b | Input: %b | Output: %b | Current State: %b", 
                 $time, reset, din_bit, dout_bit, dut.state);
    end

endmodule

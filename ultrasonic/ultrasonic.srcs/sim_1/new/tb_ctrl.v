`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/25 11:42:20
// Design Name: 
// Module Name: tb_ctrl
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


module tb_us_dist_sensor;
    // 테스트벤치 신호
    reg clk;
    reg reset;
    reg btn_start;
    reg echo;
    wire trigger;
    wire [15:0] dist;
    wire done;
    
    // 에코 펄스 시간 시뮬레이션용 변수
    reg [31:0] echo_time_us;
    
    // 피사체 거리 시뮬레이션용 변수 (cm 단위)
    reg [7:0] object_distance_cm;
    
    // 모니터링용 변수
    time echo_start_time;
    time trigger_start_time;
    reg test_done;
    
    // DUT 인스턴스화
    top_ultrasonic DUT(
        .clk(clk),
        .reset(reset),
        .btn_start(btn_start),
        .echo(echo),
        .trigger(trigger),
        .dist(dist),
        .done(done)
    );
    
    // 클럭 생성 (50MHz = 20ns 주기)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // 거리(cm)를 에코 시간(us)으로 변환하는 함수
    function [31:0] cm_to_us;
        input [7:0] cm;
        begin
            cm_to_us = cm * 58; // 시간(us) = 거리(cm) * 58
        end
    endfunction
    
    // 에코 신호 생성 태스크
    task generate_echo;
        input [7:0] distance_cm;
        begin
            echo_time_us = cm_to_us(distance_cm);
            
            @(posedge trigger);      // 트리거 신호 기다림
            @(negedge trigger);      // 트리거 종료 기다림
            #100;                    // 실제 센서의 처리 지연 시뮬레이션
            
            // 에코 펄스 생성 (거리에 비례하는 시간)
            echo = 1;                // 에코 시작
            #(echo_time_us * 1000);  // 에코 시간(us)을 ns로 변환
            echo = 0;                // 에코 종료
        end
    endtask
    
    // 테스트 시나리오
    initial begin
        // 초기화
        reset = 1;
        btn_start = 0;
        echo = 0;
        object_distance_cm = 0;
        echo_time_us = 0;
        test_done = 0;
        
        // 리셋 해제
        #100;
        reset = 0;
        #100;
        
        // 첫 번째 거리 테스트: 10cm
        object_distance_cm = 10;
        $display("\n=== Test 1: %d cm ===", object_distance_cm);
        $display("Expected echo time: %d us", cm_to_us(object_distance_cm));
        
        // 버튼 누름 시뮬레이션 (20ns 동안 버튼 활성화)
        btn_start = 1;
        #20;
        btn_start = 0;
        
        // 에코 생성
        generate_echo(object_distance_cm);
        
        // 측정 완료 대기
        wait(done);
        #20;
        $display("Measured distance: %d cm", dist);
        
        // 다음 측정 전 대기
        #200000;
        
        // 두 번째 거리 테스트: 25cm
        object_distance_cm = 25;
        $display("\n=== Test 2: %d cm ===", object_distance_cm);
        $display("Expected echo time: %d us", cm_to_us(object_distance_cm));
        
        // 버튼 누름 시뮬레이션
        btn_start = 1;
        #20;
        btn_start = 0;
        
        // 에코 생성
        generate_echo(object_distance_cm);
        
        // 측정 완료 대기
        wait(done);
        #20;
        $display("Measured distance: %d cm", dist);
        
        // 다음 측정 전 대기
        #200000;
        
        // 세 번째 거리 테스트: 50cm
        object_distance_cm = 50;
        $display("\n=== Test 3: %d cm ===", object_distance_cm);
        $display("Expected echo time: %d us", cm_to_us(object_distance_cm));
        
        // 버튼 누름 시뮬레이션
        btn_start = 1;
        #20;
        btn_start = 0;
        
        // 디버깅 메시지 추가
        $display("Button pressed for Test 3");
        
        // 에코 생성
        generate_echo(object_distance_cm);
        
        // 디버깅 메시지 추가
        $display("Echo generated for Test 3");
        
        // 측정 완료 대기
        wait(done == 1);
        #20;
        $display("Measured distance: %d cm", dist);
        
        // 테스트 완료 표시
        test_done = 1;
        
        // 테스트 완료
        #5000;
        $display("\n=== Test completed! ===");
        $finish;
    end
    
    // 테스트 타임아웃 처리
    initial begin
        #2000000; // 2ms 타임아웃
        if (!test_done) begin
            $display("\n=== Test timed out! Final test might have failed ===");
            $finish;
        end
    end
    
    // 트리거 신호 모니터링
    initial begin
        forever begin
            @(posedge trigger);
            trigger_start_time = $time;
            $display("Time %0t: Trigger start", $time);
            @(negedge trigger);
            $display("Time %0t: Trigger end, Duration: %0t ns", $time, $time - trigger_start_time);
        end
    end
    
    // 에코 신호 모니터링
    initial begin
        forever begin
            @(posedge echo);
            echo_start_time = $time;
            $display("Time %0t: Echo start", $time);
            @(negedge echo);
            $display("Time %0t: Echo end, Duration: %0t ns", $time, $time - echo_start_time);
        end
    end
    
    // 거리 측정 완료 모니터링
    initial begin
        forever begin
            @(posedge done);
            #1; // 안정화를 위한 짧은 대기
            $display("Time %0t: Distance measurement completed - %d cm", $time, dist);
        end
    end

endmodule
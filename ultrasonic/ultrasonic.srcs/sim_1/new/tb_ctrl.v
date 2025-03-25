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
    
    // 모니터링용 변수들
    time echo_start_time;
    
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
        
        // 리셋 해제
        #100;
        reset = 0;
        #100;
        
        // 첫 번째 거리 테스트: 10cm
        object_distance_cm = 10;
        $display("Test distance: %d cm, Expected echo time: %d us", 
                 object_distance_cm, cm_to_us(object_distance_cm));
        
        btn_start = 1;
        #20;
        btn_start = 0;
        
        generate_echo(object_distance_cm);
        
        // 측정 완료 대기
        @(posedge done);
        #100;
        $display("Measured distance: %d cm", dist);
        
        // 0.5초 대기
        #500000;
        
        // 두 번째 거리 테스트: 25cm
        object_distance_cm = 25;
        $display("Test distance: %d cm, Expected echo time: %d us", 
                 object_distance_cm, cm_to_us(object_distance_cm));
        
        btn_start = 1;
        #20;
        btn_start = 0;
        
        generate_echo(object_distance_cm);
        
        // 측정 완료 대기
        @(posedge done);
        #100;
        $display("Measured distance: %d cm", dist);
        
        // 0.5초 대기
        #500000;
        
        // 세 번째 거리 테스트: 100cm
        object_distance_cm = 100;
        $display("Test distance: %d cm, Expected echo time: %d us", 
                 object_distance_cm, cm_to_us(object_distance_cm));
        
        btn_start = 1;
        #20;
        btn_start = 0;
        
        generate_echo(object_distance_cm);
        
        // 측정 완료 대기
        @(posedge done);
        #100;
        $display("Measured distance: %d cm", dist);
        
        // 테스트 완료
        #5000;
        $display("Test completed!");
        $finish;
    end
    
    // 트리거 모니터링
    initial begin
        forever begin
            @(posedge trigger);
            $display("Time %0t: Trigger start", $time);
            @(negedge trigger);
            $display("Time %0t: Trigger end", $time);
        end
    end
    
    // 에코 모니터링
    initial begin
        forever begin
            @(posedge echo);
            echo_start_time = $time;
            $display("Time %0t: Echo start", $time);
            @(negedge echo);
            $display("Time %0t: Echo end, Duration: %0t ns", $time, $time - echo_start_time);
        end
    end
    
    // 거리 변화 모니터링
    initial begin
        forever begin
            @(posedge done);
            $display("Time %0t: Distance calculated - %d cm", $time, dist);
        end
    end

endmodule

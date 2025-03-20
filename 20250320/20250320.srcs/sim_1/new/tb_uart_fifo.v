`timescale 1ns / 1ps

module tb_uart_fifo;
    // 테스트벤치 신호 선언
    reg         clk;        // 시스템 클럭
    reg         rst;        // 리셋 신호
    reg         rx;         // UART 수신 신호
    wire        tx;         // UART 송신 신호
    
    // 시뮬레이션 파라미터
    parameter   CLK_PERIOD = 10;  // 10ns = 100MHz 클럭
    parameter   BAUD_RATE = 9600; // 통신 속도 9600 보드
    parameter   BIT_TIME = 1_000_000_000 / BAUD_RATE; // 한 비트당 시간 (ns 단위)
    
    // 테스트 데이터
    reg [7:0]   test_data [0:4];  // 테스트할 5개의 데이터 바이트
    integer     i;                // 반복문 변수
    
    // DUT(Design Under Test) 인스턴스화
    uart_fifo DUT (
        .clk    (clk),
        .rst    (rst),
        .rx     (rx),
        .tx     (tx)
    );
    
    // 클럭 생성
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);    // 클럭 반주기 대기
        clk = 1'b1;
        #(CLK_PERIOD/2);    // 클럭 반주기 대기
    end
    
    // UART 바이트 전송 태스크
    task uart_send_byte;
        input [7:0] data;
        begin
            // 시작 비트 (로우)
            rx = 1'b0;
            #BIT_TIME;
            
            // 8개의 데이터 비트 (LSB 먼저)
            rx = data[0]; #BIT_TIME;  // 비트 0 전송
            rx = data[1]; #BIT_TIME;  // 비트 1 전송
            rx = data[2]; #BIT_TIME;  // 비트 2 전송
            rx = data[3]; #BIT_TIME;  // 비트 3 전송
            rx = data[4]; #BIT_TIME;  // 비트 4 전송
            rx = data[5]; #BIT_TIME;  // 비트 5 전송
            rx = data[6]; #BIT_TIME;  // 비트 6 전송
            rx = data[7]; #BIT_TIME;  // 비트 7 전송
            
            // 정지 비트 (하이)
            rx = 1'b1;
            #BIT_TIME;
        end
    endtask
    
    // UART 바이트 수신 태스크
    task uart_receive_byte;
        output [7:0] data;
        begin
            // 시작 비트 (하강 에지) 대기
            @(negedge tx);
            
            // 시작 비트의 중간 지점으로 이동
            #(BIT_TIME/2);
            
            // 시작 비트가 로우인지 확인
            if (tx !== 1'b0) begin
                $display("ERROR: Invalid start bit at time %t", $time);
            end
            
            // 각 데이터 비트의 중간 지점에서 샘플링
            #BIT_TIME;
            data[0] = tx; #BIT_TIME;  // 비트 0 수신
            data[1] = tx; #BIT_TIME;  // 비트 1 수신
            data[2] = tx; #BIT_TIME;  // 비트 2 수신
            data[3] = tx; #BIT_TIME;  // 비트 3 수신
            data[4] = tx; #BIT_TIME;  // 비트 4 수신
            data[5] = tx; #BIT_TIME;  // 비트 5 수신
            data[6] = tx; #BIT_TIME;  // 비트 6 수신
            data[7] = tx; #BIT_TIME;  // 비트 7 수신
            
            // 정지 비트가 하이인지 확인
            if (tx !== 1'b1) begin
                $display("ERROR: Invalid stop bit at time %t", $time);
            end
            
            // 전체 정지 비트 시간 대기
            #BIT_TIME;
        end
    endtask
    
    // 테스트 시나리오
    initial begin
        // 초기화
        clk = 0;
        rst = 1;       // 리셋 활성화
        rx = 1;        // 아이들 상태는 하이
        
        // 테스트 데이터 초기화
        test_data[0] = 8'hA5;  // 테스트 데이터 1: 10100101
        test_data[1] = 8'h3C;  // 테스트 데이터 2: 00111100
        test_data[2] = 8'hF0;  // 테스트 데이터 3: 11110000
        test_data[3] = 8'h55;  // 테스트 데이터 4: 01010101
        test_data[4] = 8'hAA;  // 테스트 데이터 5: 10101010
        
        // 리셋 해제
        #(CLK_PERIOD*10);     // 10 클럭 주기 대기
        rst = 0;              // 리셋 비활성화
        #(CLK_PERIOD*10);     // 10 클럭 주기 대기
        
        // UART 테스트 시작
        $display("=== UART FIFO Test Started === Time: %t", $time);
        
        // 테스트 데이터 하나씩 전송
        for (i = 0; i < 5; i = i + 1) begin
            $display("Sending data: %h at time: %t", test_data[i], $time);
            uart_send_byte(test_data[i]);  // 데이터 전송
            #(BIT_TIME*2);                 // 바이트 간 추가 지연
        end
        
        // FIFO 처리 시간 제공
        #(BIT_TIME*100);
        
        // 시뮬레이션 종료
        $display("=== Simulation Completed === Time: %t", $time);
        $finish;
    end
    
    // TX 모니터링 프로세스
    reg [7:0] received_byte;  // 수신된 바이트 저장
    
    initial begin
        // 리셋 완료 대기
        #(CLK_PERIOD*20);
        
        // TX 라인에서 루프백 데이터 모니터링
        repeat (5) begin
            uart_receive_byte(received_byte);  // 바이트 수신
            $display("Received data: %h at time: %t", received_byte, $time);
            
            // // 수신된 데이터가 테스트 데이터와 일치하는지 확인 (선택적)
            // for (i = 0; i < 5; i = i + 1) begin
            //     if (received_byte == test_data[i]) begin
            //         $display("데이터 일치 확인 (test_data[%0d]과 일치)", i);
            //         break;
            //     end
            // end
            
            // 수신 간 지연 추가
            #(BIT_TIME*2);
        end
    end
endmodule
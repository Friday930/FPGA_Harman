module tb_prj_uart_stopwatch();
    // 테스트벤치 신호 선언
    reg         clk;
    reg         rst;
    reg         fifo_rx;
    wire        fifo_tx;
    reg [1:0]   sw;
    wire [3:0]  fnd_comm;
    wire [7:0]  fnd_font;
    wire [3:0]  led;
    
    // 모니터링용 내부 신호 접근
    wire [7:0]  ctrl;
    wire        r, c, h, m, s;
    
    // UART 전송 관련 파라미터
    parameter   BAUD_RATE = 9600;  // 보드레이트 
    parameter   CLK_PERIOD = 10;   // 클럭 주기(ns)
    parameter   BIT_PERIOD = 1000000000/BAUD_RATE;  // 비트 주기(ns)
    
    // DUT 인스턴스 생성
    prj_uart_stopwatch DUT (
        .clk        (clk),
        .rst        (rst),
        .fifo_rx    (fifo_rx),
        .fifo_tx    (fifo_tx),
        .sw         (sw),
        .fnd_comm   (fnd_comm),
        .fnd_font   (fnd_font),
        .led        (led)
    );
    
    // 내부 신호 할당
    assign ctrl = DUT.ctrl;
    assign r = DUT.r;
    assign c = DUT.c;
    assign h = DUT.h;
    assign m = DUT.m;
    assign s = DUT.s;
    
    // 클럭 생성
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;  // 10ns 주기
    end
    
    // UART 문자 전송 태스크
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // 시작 비트 (로우)
            fifo_rx = 0;
            #BIT_PERIOD;
            
            // 8비트 데이터 전송 (LSB 먼저)
            for(i = 0; i < 8; i = i + 1) begin
                fifo_rx = data[i];
                #BIT_PERIOD;
            end
            
            // 정지 비트 (하이)
            fifo_rx = 1;
            #BIT_PERIOD;
        end
    endtask
    
    // UART 수신 모니터링 태스크
    task monitor_uart_tx;
        reg [7:0] received_byte;
        integer i;
        begin
            // 시작 비트(로우) 감지 대기
            @(negedge fifo_tx);
            #(BIT_PERIOD/2);  // 비트 중앙으로 이동
            
            // 데이터 비트 읽기 (LSB 먼저)
            for(i = 0; i < 8; i = i + 1) begin
                #BIT_PERIOD;
                received_byte[i] = fifo_tx;
            end
            
            // 정지 비트 확인
            #BIT_PERIOD;
            if(fifo_tx !== 1) begin
                $display("Warning: Stop bit not detected at time %0t", $time);
            end
            
            $display("UART TX received: %c (0x%h) at time %0t", received_byte, received_byte, $time);
        end
    endtask
    
    // UART 수신 모니터링 프로세스
    initial begin
        forever begin
            monitor_uart_tx();
        end
    end
    
    // 테스트 시나리오
    initial begin
        // 초기화
        rst = 1;
        fifo_rx = 1;  // UART 아이들 상태는 하이
        sw = 2'b00;
        #100;
        rst = 0;
        #100;
        
        // 각 명령 테스트
        
        // 'R' 명령 전송 (Run)
        $display("Time %0t: Sending 'R' command", $time);
        send_uart_byte("R");
        #(BIT_PERIOD*10);  // 처리 시간 대기 증가
        
        // 'C' 명령 전송 (Clear)
        $display("Time %0t: Sending 'C' command", $time);
        send_uart_byte("C");
        #(BIT_PERIOD*10);
        
        // 'H' 명령 전송 (Hour)
        $display("Time %0t: Sending 'H' command", $time);
        send_uart_byte("H");
        #(BIT_PERIOD*10);
        
        // 'M' 명령 전송 (Minute)
        $display("Time %0t: Sending 'M' command", $time);
        send_uart_byte("M");
        #(BIT_PERIOD*10);
        
        // 'S' 명령 전송 (Second)
        $display("Time %0t: Sending 'S' command", $time);
        send_uart_byte("S");
        #(BIT_PERIOD*10);
        
        // 소문자 명령 테스트
        $display("Time %0t: Sending lowercase commands", $time);
        send_uart_byte("r");
        #(BIT_PERIOD*10);
        send_uart_byte("c");
        #(BIT_PERIOD*10);
        
        // 스위치 변경 테스트
        $display("Time %0t: Testing switch functionality", $time);
        sw = 2'b01;
        #2000;
        sw = 2'b10;
        #2000;
        sw = 2'b11;
        #2000;
        
        // 추가 명령 시퀀스 테스트
        $display("Time %0t: Testing command sequence", $time);
        send_uart_byte("R");  // 스톱워치 시작
        #(BIT_PERIOD*20);
        send_uart_byte("R");  // 스톱워치 정지
        #(BIT_PERIOD*10);
        send_uart_byte("C");  // 스톱워치 초기화
        #(BIT_PERIOD*10);
        
        // 시뮬레이션 종료
        #20000;
        $display("Simulation complete at time %0t", $time);
        $finish;
    end
    
    // 신호 모니터링
    initial begin
        $monitor("Time = %0t | rst = %b | ctrl = %c(%h) | r = %b | c = %b | h = %b | m = %b | s = %b | sw = %b | fnd_comm = %b | led = %b",
                 $time, rst, ctrl, ctrl, r, c, h, m, s, sw, fnd_comm, led);
    end

endmodule
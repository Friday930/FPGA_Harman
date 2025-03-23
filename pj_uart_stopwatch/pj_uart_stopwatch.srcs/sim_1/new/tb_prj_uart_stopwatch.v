// module tb_prj_uart_stopwatch();
//     // 테스트벤치 신호 선언
//     reg         clk;
//     reg         rst;
//     reg         fifo_rx;
//     wire        fifo_tx;
//     reg [1:0]   sw;
//     wire [3:0]  fnd_comm;
//     wire [7:0]  fnd_font;
//     wire [3:0]  led;
    
//     // 모니터링용 내부 신호 접근
//     wire [7:0]  ctrl;
//     wire        r, c, h, m, s;
    
//     // UART 전송 관련 파라미터
//     parameter   BAUD_RATE = 9600;  // 보드레이트 
//     parameter   CLK_PERIOD = 10;   // 클럭 주기(ns)
//     parameter   BIT_PERIOD = 1000000000/BAUD_RATE;  // 비트 주기(ns)
    
//     // DUT 인스턴스 생성
//     prj_uart_stopwatch DUT (
//         .clk        (clk),
//         .rst        (rst),
//         .fifo_rx    (fifo_rx),
//         .fifo_tx    (fifo_tx),
//         .sw         (sw),
//         .fnd_comm   (fnd_comm),
//         .fnd_font   (fnd_font),
//         .led        (led)
//     );
    
//     // 내부 신호 할당
//     assign ctrl = DUT.ctrl;
//     assign r = DUT.r;
//     assign c = DUT.c;
//     assign h = DUT.h;
//     assign m = DUT.m;
//     assign s = DUT.s;
    
//     // 클럭 생성
//     initial begin
//         clk = 0;
//         forever #(CLK_PERIOD/2) clk = ~clk;  // 10ns 주기
//     end
    
//     // UART 문자 전송 태스크
//     task send_uart_byte;
//         input [7:0] data;
//         integer i;
//         begin
//             // 시작 비트 (로우)
//             fifo_rx = 0;
//             #BIT_PERIOD;
            
//             // 8비트 데이터 전송 (LSB 먼저)
//             for(i = 0; i < 8; i = i + 1) begin
//                 fifo_rx = data[i];
//                 #BIT_PERIOD;
//             end
            
//             // 정지 비트 (하이)
//             fifo_rx = 1;
//             #BIT_PERIOD;
//         end
//     endtask
    
//     // UART 수신 모니터링 태스크
//     task monitor_uart_tx;
//         reg [7:0] received_byte;
//         integer i;
//         begin
//             // 시작 비트(로우) 감지 대기
//             @(negedge fifo_tx);
//             #(BIT_PERIOD/2);  // 비트 중앙으로 이동
            
//             // 데이터 비트 읽기 (LSB 먼저)
//             for(i = 0; i < 8; i = i + 1) begin
//                 #BIT_PERIOD;
//                 received_byte[i] = fifo_tx;
//             end
            
//             // 정지 비트 확인
//             #BIT_PERIOD;
//             if(fifo_tx !== 1) begin
//                 $display("Warning: Stop bit not detected at time %0t", $time);
//             end
            
//             $display("UART TX received: %c (0x%h) at time %0t", received_byte, received_byte, $time);
//         end
//     endtask
    
//     // UART 수신 모니터링 프로세스
//     initial begin
//         forever begin
//             monitor_uart_tx();
//         end
//     end
    
//     // 테스트 시나리오
//     initial begin
//         // 초기화
//         rst = 1;
//         fifo_rx = 1;  // UART 아이들 상태는 하이
//         sw = 2'b00;
//         #100;
//         rst = 0;
//         #100;
        
//         // 각 명령 테스트
        
//         // 'R' 명령 전송 (Run)
//         $display("Time %0t: Sending 'R' command", $time);
//         send_uart_byte("R");
//         #(BIT_PERIOD*10);  // 처리 시간 대기 증가
        
//         // 'C' 명령 전송 (Clear)
//         $display("Time %0t: Sending 'C' command", $time);
//         send_uart_byte("C");
//         #(BIT_PERIOD*10);
        
//         // 'H' 명령 전송 (Hour)
//         $display("Time %0t: Sending 'H' command", $time);
//         send_uart_byte("H");
//         #(BIT_PERIOD*10);
        
//         // 'M' 명령 전송 (Minute)
//         $display("Time %0t: Sending 'M' command", $time);
//         send_uart_byte("M");
//         #(BIT_PERIOD*10);
        
//         // 'S' 명령 전송 (Second)
//         $display("Time %0t: Sending 'S' command", $time);
//         send_uart_byte("S");
//         #(BIT_PERIOD*10);
        
//         // 소문자 명령 테스트
//         $display("Time %0t: Sending lowercase commands", $time);
//         send_uart_byte("r");
//         #(BIT_PERIOD*10);
//         send_uart_byte("c");
//         #(BIT_PERIOD*10);
        
//         // 스위치 변경 테스트
//         $display("Time %0t: Testing switch functionality", $time);
//         sw = 2'b01;
//         #2000;
//         sw = 2'b10;
//         #2000;
//         sw = 2'b11;
//         #2000;
        
//         // 추가 명령 시퀀스 테스트
//         $display("Time %0t: Testing command sequence", $time);
//         send_uart_byte("R");  // 스톱워치 시작
//         #(BIT_PERIOD*20);
//         send_uart_byte("R");  // 스톱워치 정지
//         #(BIT_PERIOD*10);
//         send_uart_byte("C");  // 스톱워치 초기화
//         #(BIT_PERIOD*10);
        
//         // 시뮬레이션 종료
//         #20000;
//         $display("Simulation complete at time %0t", $time);
//         $finish;
//     end
    
//     // 신호 모니터링
//     initial begin
//         $monitor("Time = %0t | rst = %b | ctrl = %c(%h) | r = %b | c = %b | h = %b | m = %b | s = %b | sw = %b | fnd_comm = %b | led = %b",
//                  $time, rst, ctrl, ctrl, r, c, h, m, s, sw, fnd_comm, led);
//     end

// endmodule

// `timescale 1ns / 1ps

// module tb_prj_uart_stopwatch();

//     // Clock and reset signals
//     reg clk;
//     reg rst;
    
//     // UART signals
//     reg fifo_rx;
//     wire fifo_tx;
    
//     // Switch and output signals
//     reg [1:0] sw;
//     wire [3:0] fnd_comm;
//     wire [7:0] fnd_font;
//     wire [3:0] led;
    
//     // Additional signals for testing (internal state monitoring)
//     wire [7:0] uart_data;    // UART data
//     wire [7:0] cmd_ctrl;     // Command control signal
//     wire r_cmd, c_cmd, h_cmd, m_cmd, s_cmd;  // Decoded commands
//     wire [5:0] o_sec;        // Seconds value
//     wire [5:0] o_min;        // Minutes value
//     wire [4:0] o_hour;       // Hours value
    
//     // UART transmission constants
//     localparam BAUD_RATE = 9600;
//     localparam BAUD_PERIOD = 1000000000 / BAUD_RATE; // Period in nanoseconds
    
//     // Module instantiation
//     prj_uart_stopwatch UUT (
//         .clk(clk),
//         .rst(rst),
//         .fifo_rx(fifo_rx),
//         .fifo_tx(fifo_tx),
//         .sw(sw),
//         .fnd_comm(fnd_comm),
//         .fnd_font(fnd_font),
//         .led(led)
//     );
    
//     // Connect internal signals (for monitoring)
//     assign uart_data = UUT.U_UART_FIFO.data;
//     assign cmd_ctrl = UUT.ctrl;
//     assign r_cmd = UUT.r;
//     assign c_cmd = UUT.c;
//     assign h_cmd = UUT.h;
//     assign m_cmd = UUT.m;
//     assign s_cmd = UUT.s;
    
//     // Clock generation (100MHz)
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk; // 10ns period (100MHz)
//     end
    
//     // UART character transmission task
//     task send_uart_byte;
//         input [7:0] data;
//         integer i;
//         begin
//             // Start bit (low)
//             fifo_rx = 0;
//             #BAUD_PERIOD;
            
//             // 8 data bits (LSB first)
//             for (i = 0; i < 8; i = i + 1) begin
//                 fifo_rx = data[i];
//                 #BAUD_PERIOD;
//             end
            
//             // Stop bit (high)
//             fifo_rx = 1;
//             #BAUD_PERIOD;
//         end
//     endtask
    
//     // Test scenario
//     initial begin
//         // Initialization
//         rst = 1;
//         fifo_rx = 1; // Idle state is high
//         sw = 2'b00;
//         #100;
//         rst = 0;
//         #100;
        
//         // Test 1: Send hour (h) command
//         $display("Sending hour (h) command");
//         send_uart_byte(8'h68); // ASCII 'h'
//         #(BAUD_PERIOD * 2);
        
//         // Test 2: Send minute (m) command
//         $display("Sending minute (m) command");
//         send_uart_byte(8'h6D); // ASCII 'm'
//         #(BAUD_PERIOD * 2);
        
//         // Test 3: Send second (s) command
//         $display("Sending second (s) command");
//         send_uart_byte(8'h73); // ASCII 's'
//         #(BAUD_PERIOD * 2);
        
//         // Test 4: Send consecutive minute (m) commands (check if this is the problem)
//         $display("Sending consecutive minute (m) commands - START");
//         repeat (65) begin
//             send_uart_byte(8'h6D); // ASCII 'm'
//             #(BAUD_PERIOD);
//         end
//         $display("Sending consecutive minute (m) commands - COMPLETE");
//         #(BAUD_PERIOD * 5);
        
//         // Test 5: Send hour (h) command after consecutive minute commands
//         $display("Sending hour (h) command after consecutive m commands");
//         send_uart_byte(8'h68); // ASCII 'h'
//         #(BAUD_PERIOD * 10);
        
//         // End simulation
//         $display("Simulation complete");
//         #1000;
//         $finish;
//     end
    
//     // Signal monitoring
//     initial begin
//         $monitor("Time: %0t, rst: %b, fifo_rx: %b, uart_data: %h, cmd_ctrl: %h, r: %b, c: %b, h: %b, m: %b, s: %b",
//                  $time, rst, fifo_rx, uart_data, cmd_ctrl, r_cmd, c_cmd, h_cmd, m_cmd, s_cmd);
//     end

// endmodule

`timescale 1ns / 1ps

module tb_prj_uart_stopwatch();

    // Clock and reset signals
    reg clk;
    reg rst;
    
    // UART signals
    reg fifo_rx;
    wire fifo_tx;
    
    // Switch and output signals
    reg [1:0] sw;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;
    wire [3:0] led;
    
    // 모든 중간 신호를 모니터링하기 위한 변수들
    // UART 관련 신호
    wire [7:0] uart_rx_data;   // UART 수신 데이터
    wire uart_rx_valid;        // UART 수신 데이터 유효성
    wire uart_rx_ready;        // UART 수신기 준비 상태
    
    // FIFO 관련 신호
    wire fifo_empty;          // FIFO 비어있음 플래그
    wire fifo_full;           // FIFO 가득참 플래그
    wire fifo_rd_en;          // FIFO 읽기 활성화
    wire fifo_wr_en;          // FIFO 쓰기 활성화
    wire [7:0] fifo_data_out; // FIFO 출력 데이터
    
    // UART_CU 관련 신호
    wire [7:0] loopback_sig;  // UART_CU 입력
    wire [7:0] loopback_reg_sig; // UART_CU 내부 저장 레지스터
    wire [7:0] inst_sig;      // UART_CU 출력
    
    // CMD_DECODER 관련 신호
    wire [7:0] cmd_ctrl;      // CMD_DECODER 입력
    wire r_cmd, c_cmd, h_cmd, m_cmd, s_cmd;  // 디코딩된 명령어
    
    // UART transmission constants
    localparam BAUD_RATE = 9600;
    localparam BAUD_PERIOD = 1000000000 / BAUD_RATE; // Period in nanoseconds
    
    // Module instantiation
    prj_uart_stopwatch UUT (
        .clk(clk),
        .rst(rst),
        .fifo_rx(fifo_rx),
        .fifo_tx(fifo_tx),
        .sw(sw),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font),
        .led(led)
    );
    
    // 내부 신호 연결 (모니터링 목적)
    // 계층 구조를 명확히 하기 위해 주석 처리된 예시를 포함합니다
    // assign uart_rx_data = UUT.uart_rx_module.rx_data;
    // assign uart_rx_valid = UUT.uart_rx_module.rx_valid;
    // assign fifo_empty = UUT.fifo_module.empty;
    // assign fifo_data_out = UUT.fifo_module.data_out;
    
    // 실제 프로젝트 계층 구조에 맞게 수정해야 합니다.
    // 여러 가능한 경로를 제공하여 옳은 것을 찾을 수 있도록 합니다.
    
    // UART_CU 신호 연결 시도
    // 버전 1: 직접 매핑 (가장 표준적인 방법)
    assign loopback_sig = UUT.U_UART_CU.loopback;
    assign loopback_reg_sig = UUT.U_UART_CU.loopback_reg;
    assign inst_sig = UUT.U_UART_CU.inst;
    
    // 버전 2: 대체 경로
    // assign loopback_sig = UUT.uart_control_unit.loopback;
    // assign loopback_reg_sig = UUT.uart_control_unit.loopback_reg;
    // assign inst_sig = UUT.uart_control_unit.inst;
    
    // 버전 3: 또 다른 가능한 경로
    // assign loopback_sig = UUT.UART_CU_INST.loopback;
    // assign loopback_reg_sig = UUT.UART_CU_INST.loopback_reg;
    // assign inst_sig = UUT.UART_CU_INST.inst;
    
    // CMD_DECODER 신호
    assign cmd_ctrl = UUT.ctrl;
    assign r_cmd = UUT.r;
    assign c_cmd = UUT.c;
    assign h_cmd = UUT.h;
    assign m_cmd = UUT.m;
    assign s_cmd = UUT.s;
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period (100MHz)
    end
    
    // UART character transmission task
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit (low)
            fifo_rx = 0;
            #BAUD_PERIOD;
            
            // 8 data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                fifo_rx = data[i];
                #BAUD_PERIOD;
            end
            
            // Stop bit (high)
            fifo_rx = 1;
            #BAUD_PERIOD;
            
            // 추가 안정화 지연
            #(BAUD_PERIOD / 2);
        end
    endtask
    
    // 직접 하드코딩 강제 설정 태스크
    task force_loopback;
        input [7:0] data;
        begin
            $display("Time: %0t - 직접 loopback 강제 설정: %h", $time, data);
            force UUT.U_UART_CU.loopback = data;
            #20;  // 적당한 시간 대기
            release UUT.U_UART_CU.loopback;
            #100; // 결과 관찰 시간
        end
    endtask
    
    // 디버그용 변수
    integer error_count = 0;
    
    // Test scenario
    initial begin
        // Initialization
        rst = 1;
        fifo_rx = 1; // Idle state is high
        sw = 2'b00;
        #500; // 긴 리셋 시간
        rst = 0;
        #500; // 긴 안정화 시간
        
        $display("==== 정상 UART 전송 테스트 ====");
        
        // 테스트 1: 'R' 명령어 전송
        $display("\nTest 1: Sending 'R' command (0x52)");
        send_uart_byte(8'h52); // ASCII 'R'
        #(BAUD_PERIOD * 10);
        if (inst_sig != 8'h52) begin
            $display("오류! inst_sig = %h, 예상값: %h", inst_sig, 8'h52);
            error_count = error_count + 1;
        end
        
        // 테스트 2: 'h' 명령어 전송
        $display("\nTest 2: Sending 'h' command (0x68)");
        send_uart_byte(8'h68); // ASCII 'h'
        #(BAUD_PERIOD * 10);
        if (inst_sig != 8'h48) begin  // 'H'로 변환되어야 함
            $display("오류! inst_sig = %h, 예상값: %h", inst_sig, 8'h48);
            error_count = error_count + 1;
        end
        
        // 테스트 3: 같은 명령 두 번 전송 (변화 감지 테스트)
        $display("\nTest 3: 같은 명령 두 번 전송 - 'm' (0x6D)");
        send_uart_byte(8'h6D); // ASCII 'm'
        #(BAUD_PERIOD * 5);
        send_uart_byte(8'h00); // 0 (중간 값 변경)
        #(BAUD_PERIOD * 5);
        send_uart_byte(8'h6D); // ASCII 'm' 다시
        #(BAUD_PERIOD * 10);
        
        $display("\n==== 직접 loopback 강제 설정 테스트 ====");
        
        // 테스트 4: 직접 loopback 강제 설정
        $display("\nTest 4: 직접 loopback 강제 설정 - 'R' (0x52)");
        force_loopback(8'h52); // 'R'
        if (inst_sig != 8'h52) begin
            $display("오류! inst_sig = %h, 예상값: %h", inst_sig, 8'h52);
            error_count = error_count + 1;
        end
        
        // 테스트 5: 다른 값으로 강제 설정
        $display("\nTest 5: 직접 loopback 강제 설정 - 'C' (0x43)");
        force_loopback(8'h43); // 'C'
        if (inst_sig != 8'h43) begin
            $display("오류! inst_sig = %h, 예상값: %h", inst_sig, 8'h43);
            error_count = error_count + 1;
        end
        
        // 모듈 경로 검증
        $display("\n==== 모듈 경로 검증 ====");
        $display("loopback_sig 경로 확인: %h", loopback_sig);
        $display("loopback_reg_sig 경로 확인: %h", loopback_reg_sig);
        $display("inst_sig 경로 확인: %h", inst_sig);
        
        // 결과 요약
        #500;
        $display("\n==== 테스트 결과 요약 ====");
        if (error_count > 0) begin
            $display("테스트 실패! 총 %d개의 오류 발견", error_count);
        end else begin
            $display("모든 테스트 통과!");
        end
        
        // 추가 디버깅 메시지
        $display("\n문제 진단 힌트:");
        $display("1. loopback과 loopback_reg 값이 다른지 확인하세요 (변화 감지에 필요)");
        $display("2. UART_CU 모듈 내 경로가 올바른지 확인하세요");
        $display("3. 하드코딩 테스트 결과와 UART 테스트 결과를 비교하세요");
        
        // End simulation
        $display("\nSimulation complete");
        $finish;
    end
    
    // Signal monitoring - loopback과 inst 값 변화에 초점을 맞춤
    initial begin
        $monitor("Time: %0t, rst: %b, rx: %b, loopback: %h, loopback_reg: %h, inst: %h, r: %b, c: %b, h: %b, m: %b, s: %b",
                 $time, rst, fifo_rx, loopback_sig, loopback_reg_sig, inst_sig, r_cmd, c_cmd, h_cmd, m_cmd, s_cmd);
    end
    
    
    // 디버깅을 위한 스트로브 모니터링
    // 특정 시간마다 중요 신호들의 변화를 추적
    initial begin
        forever begin
            #(BAUD_PERIOD);
            $display("STROBE - Time: %0t, loopback: %h, loopback_reg: %h, inst: %h",
                     $time, loopback_sig, loopback_reg_sig, inst_sig);
        end
    end

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/27 10:47:17
// Design Name: 
// Module Name: tb_dht11
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


// module tb_dht11();

//     reg             clk;
//     reg             rst;
//     reg             btn_start;

//     reg             dht_sensor_data;
//     reg             en;

//     // wire            led;
//     wire            dht_io;

//     // tb io mode 변환
//     assign          dht_io = (en) ? dht_sensor_data : 1'bz;

//     dht11_controller dut(
//     .clk            (clk),
//     .rst            (rst),
//     .start          (btn_start),
//     // .led_m          (led),
//     .dht_io         (dht_io)
//     );

//     always  #5      clk = ~clk;

//     initial begin
//         clk = 0;
//         rst = 1;
//         en = 0;
//         btn_start = 0;

//         #100;
//         rst = 0;
//         #100;
//         btn_start = 1;
//         #100;
//         btn_start = 0;
//         #10000;
//         wait        (dht_io)
//         #30000;

//         // 입력모드 변환
//         en = 1;
//         dht_sensor_data = 1'b0;
//         #80000;
//         dht_sensor_data = 1'b1;
//         #80000;
//         #50000;
//         $stop;
//     end

// endmodule
module tb_dht11();

    // 테스트벤치 신호 선언
    reg             clk;
    reg             rst;
    reg             btn_start;
    reg             dht_sensor_data;
    reg             en;
    
    // 테스트 데이터 - 모듈 레벨에서 선언
    reg [39:0]      test_data;
    integer         i;
    
    // 디버깅용 카운터
    integer         tick_count;
    
    // 결과 관찰용 신호
    wire [15:0]     humidity;
    wire [15:0]     celcius;
    wire            dht_io;
    
    // 내부 신호 모니터링
    wire            tick;
    
    // DHT11 센서 IO 모델링
    assign          dht_io = (en) ? dht_sensor_data : 1'bz;

    // DUT 인스턴스화
    dht11_controller dut(
        .clk            (clk),
        .rst            (rst),
        .start          (btn_start),
        .humidity       (humidity),
        .celcius        (celcius),
        .dht_io         (dht_io)
    );
    
    // 내부 신호 모니터링을 위한 연결
    assign tick = dut.tick;

    // 클럭 생성
    always  #5      clk = ~clk;  // 100MHz 클럭
    
    // tick 카운팅 (디버깅용)
    always @(posedge tick) begin
        tick_count = tick_count + 1;
        $display("Tick #%d - Time: %t, FSM State: %d, Counter: %d, DHT_IO: %b", 
                 tick_count, $time, dut.fsm_state, dut.cnt_reg, dht_io);
    end

    // 테스트 시퀀스
    initial begin
        // 초기화
        clk = 0;
        rst = 1;
        en = 0;
        btn_start = 0;
        dht_sensor_data = 1;
        tick_count = 0;
        
        // 테스트 데이터 초기화: 45.2% 습도, 25.6°C 온도, 체크섬 4E (120)
        test_data = 40'h2D02_1906_4E;

        // 리셋 해제
        #100;
        rst = 0;
        #100;
        
        $display("Starting DHT11 communication at time: %t", $time);
        
        // DHT11 시작 신호 전송
        btn_start = 1;
        #100;
        btn_start = 0;
        
        // 컨트롤러가 18ms 동안 LOW 신호 보내는 동안 대기
        #20000;
        $display("Waiting for dht_io to be released at time: %t", $time);
        
        // DHT11 센서 응답 시작 - LOW 상태 80us 유지
        @(posedge dht_io);  // 컨트롤러가 dht_io 라인을 해제할 때까지 대기
        
        $display("Controller released dht_io at time: %t", $time);
        $display("Starting sensor response sequence");
        
        // 센서 응답 시퀀스 - 정확한 타이밍으로 구현
        #30;  // 약간의 지연
        
        // 1. 센서가 LOW로 응답
        en = 1;
        dht_sensor_data = 0;
        $display("Sensor pulled LOW at time: %t", $time);
        #800;  // 80us
        
        // 2. 센서가 HIGH로 전환
        dht_sensor_data = 1;
        $display("Sensor pulled HIGH at time: %t", $time);
        #800;  // 80us
        
        $display("Starting data transmission at time: %t", $time);
        $display("FSM State before data: %d", dut.fsm_state);
        
        // 40비트 데이터 전송 - 비트별 출력 추가
        for(i=39; i>=0; i=i-1) begin
            // 데이터 비트 값 출력
            $display("Sending bit[%d] = %b", i, test_data[i]);
            
            // 각 비트 시작은 50us LOW
            dht_sensor_data = 0;
            #500;  // 50us
            
            // 데이터 비트 값에 따라 HIGH 길이 결정
            dht_sensor_data = 1;
            
            if(test_data[i] == 1) begin
                #700;  // 1 비트 (70us)
            end else begin
                #300;  // 0 비트 (30us)
            end
            
            // 비트 전송 후 현재 상태 출력
            $display("After bit[%d], FSM State: %d, Data Reg: %h", 
                     i, dut.fsm_state, dut.data_reg);
        end
        
        // 전송 종료
        $display("Ending data transmission at time: %t", $time);
        dht_sensor_data = 0;
        #500;
        dht_sensor_data = 1;  // 라인 해제
        en = 0;  // 센서 모드 해제
        
        // 결과 확인 대기
        #10000;
        
        // 결과 출력
        $display("===== FINAL RESULTS =====");
        $display("Expected: Humidity 45.2%%, Temperature 25.6°C");
        $display("Received: Humidity %d.%d%%, Temperature %d.%d°C", 
                 humidity[15:8], humidity[7:0], celcius[15:8], celcius[7:0]);
        
        // 디버깅을 위한 FSM 상태 추적 추가
        $display("Controller State: %d", dut.fsm_state);
        $display("Data Register: %h", dut.data_reg);
        
        // 내부 레지스터 값 확인
        if (dut.data_valid_reg) 
            $display("Internal data_valid_reg: TRUE");
        else
            $display("Internal data_valid_reg: FALSE");
        
        // en_reg, out_reg 확인
        $display("en_reg: %b, out_reg: %b", dut.en_reg, dut.out_reg);
        
        $stop;
    end

endmodule
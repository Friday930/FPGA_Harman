`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/26 12:34:49
// Design Name: 
// Module Name: dht11_controller
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


module dht11_controller(
    input                       clk,
    input                       rst,
    input                       start,
    output  reg [15:0]          humidity,
    output  reg [15:0]          celcius,
    inout                       dht_io
    );

    wire                        tick;
    tick_gen U_Tick(
        .clk                    (clk),
        .reset                  (rst),      
        .tick_10us              (tick)
    );

    parameter                   CNT = 1800, WAIT_CNT = 3, TIME_OUT = 2000, STOP_CNT = 5;
    parameter                   BIT_THRESHOLD = 3; 
    localparam                  IDLE = 0, START = 1, WAIT = 2, SYNC_LOW = 3, SYNC_HIGH = 4, DATA_LOW = 5, DATA_HIGH = 6, STOP = 7;

    reg [2:0]                   fsm_state, fsm_next;
    reg [$clog2(CNT) - 1:0]     cnt_reg, cnt_next;
    reg                         out_reg, out_next;
    reg                         en_reg, en_next; // 0 : read mode
    reg [39:0]                  data_reg, data_next; // shift register
    reg                         data_valid_reg, data_valid_next; // 데이터 유효 신호
    reg [5:0]                   bit_cnt_reg, bit_cnt_next; // 비트 카운터 (0-39)
    wire [7:0]                  cal_parity; // 체크섬 계산용 와이어

    // 체크섬 계산
    assign cal_parity = data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8];

    // dht_io 신호 제어
    assign dht_io = (en_reg) ? out_reg : 1'bz;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            fsm_state <= IDLE;
            cnt_reg <= 0;
            out_reg <= 1; // 초기 상태는 HIGH
            en_reg <= 1;  // 초기 상태는 출력 모드
            data_reg <= 0;
            data_valid_reg <= 0;
            bit_cnt_reg <= 0;
            humidity <= 0;
            celcius <= 0;
        end else begin
            fsm_state <= fsm_next;
            cnt_reg <= cnt_next;
            out_reg <= out_next;
            en_reg <= en_next;
            data_reg <= data_next;
            data_valid_reg <= data_valid_next;
            bit_cnt_reg <= bit_cnt_next;

            if (data_valid_reg) begin
                humidity <= {data_reg[39:32], data_reg[31:24]}; // 상위 16비트 -> 습도
                celcius <= {data_reg[23:16], data_reg[15:8]};   // 다음 16비트 -> 온도
            end
        end
    end

    always @(*) begin
        fsm_next = fsm_state;
        cnt_next = cnt_reg;
        out_next = out_reg;
        en_next = en_reg;
        data_next = data_reg;
        data_valid_next = data_valid_reg;
        bit_cnt_next = bit_cnt_reg;
        
        case (fsm_state)
            IDLE: begin
                out_next = 1;        // 신호 HIGH 유지
                en_next = 1;         // 출력 모드
                data_valid_next = 0; // 데이터 유효 신호 비활성화
                bit_cnt_next = 0;    // 비트 카운터 초기화
                
                if (start) begin
                    fsm_next = START;
                    cnt_next = 0;
                end
            end

            START: begin
                out_next = 0;  // 신호 LOW로 설정 (시작 신호)
                en_next = 1;   // 출력 모드 유지
                
                if (tick) begin
                    if (cnt_reg == CNT - 1) begin
                        fsm_next = WAIT;
                        cnt_next = 0;
                        out_next = 1; // 신호 릴리스
                    end else begin
                        cnt_next = cnt_reg + 1;
                    end
                end
            end
            
            WAIT: begin
                out_next = 1;  // 신호 HIGH로 유지
                en_next = 0;   // 입력 모드로 전환
                
                if (tick) begin
                    if (cnt_reg == WAIT_CNT - 1) begin
                        fsm_next = SYNC_LOW;
                        cnt_next = 0;
                    end else begin
                        cnt_next = cnt_reg + 1;
                    end
                end
            end
            
            SYNC_LOW: begin
                en_next = 0;  // 입력 모드 유지
                
                if (tick) begin
                    if (dht_io == 0) begin
                        // LOW 신호 감지 중
                        cnt_next = cnt_reg + 1;
                    end else if (cnt_reg > 0) begin
                        // LOW -> HIGH 변화 감지
                        fsm_next = SYNC_HIGH;
                        cnt_next = 0;
                    end else begin
                        // 감지 대기 중
                        cnt_next = cnt_reg + 1;
                    end
                    
                    if (cnt_reg >= TIME_OUT) begin
                        fsm_next = IDLE; // 타임아웃 발생
                    end
                end
            end

            SYNC_HIGH: begin
                en_next = 0;  // 입력 모드 유지
                
                if (tick) begin
                    if (dht_io == 1) begin
                        // HIGH 신호 감지 중
                        cnt_next = cnt_reg + 1;
                    end else if (cnt_reg > 0) begin
                        // HIGH -> LOW 변화 감지
                        fsm_next = DATA_LOW;
                        cnt_next = 0;
                    end else begin
                        // 감지 대기 중
                        cnt_next = cnt_reg + 1;
                    end
                    
                    if (cnt_reg >= TIME_OUT) begin
                        fsm_next = IDLE; // 타임아웃 발생
                    end
                end
            end

            DATA_LOW: begin
                en_next = 0;  // 입력 모드 유지
                
                if (tick) begin
                    if (dht_io == 0) begin
                        // LOW 신호 감지 중
                        cnt_next = cnt_reg + 1;
                    end else if (cnt_reg > 0) begin
                        // LOW -> HIGH 변화 감지
                        fsm_next = DATA_HIGH;
                        cnt_next = 0;
                    end else begin
                        // 감지 대기 중
                        cnt_next = cnt_reg + 1;
                    end
                    
                    if (cnt_reg >= TIME_OUT) begin
                        fsm_next = IDLE; // 타임아웃 발생
                    end
                end
            end

            DATA_HIGH: begin
                en_next = 0;  // 입력 모드 유지
                
                if (tick) begin
                    if (dht_io == 1) begin
                        // HIGH 신호 감지 중, 카운터 증가
                        cnt_next = cnt_reg + 1;
                    end else if (cnt_reg > 0) begin
                        // HIGH -> LOW 변화 감지, 비트 값 결정
                        if (bit_cnt_reg < 40) begin
                            // 비트 값 판단 (임계값 이상이면 1, 미만이면 0)
                            if (cnt_reg >= BIT_THRESHOLD) begin
                                // 1 비트 수신 (MSB 순서로 저장)
                                data_next = {data_reg[38:0], 1'b1};
                            end else begin
                                // 0 비트 수신 (MSB 순서로 저장)
                                data_next = {data_reg[38:0], 1'b0};
                            end
                            
                            bit_cnt_next = bit_cnt_reg + 1;
                            
                            if (bit_cnt_next == 40) begin  // 모든 비트 수신 완료
                                fsm_next = STOP;
                                cnt_next = 0;
                            end else begin  // 다음 비트 수신
                                fsm_next = DATA_LOW;
                                cnt_next = 0;
                            end
                        end else begin
                            cnt_next = 0;
                            fsm_next = STOP;
                        end
                    end else begin
                        // 감지 대기 중
                        cnt_next = cnt_reg + 1;
                    end
                    
                    if (cnt_reg >= TIME_OUT) begin
                        fsm_next = IDLE; // 타임아웃 발생
                    end
                end
            end

            STOP: begin
                en_next = 1;      // 출력 모드로 복귀
                out_next = 1;     // 신호 HIGH로 설정
                
                if (bit_cnt_reg == 40) begin
                    // 테스트용: 항상 데이터 유효 설정
                    data_valid_next = 1'b1;
                    
                    // 체크섬 검증 (실제 사용 시 활성화)
                    // if (cal_parity == data_reg[7:0]) begin
                    //     data_valid_next = 1'b1;  // 체크섬 일치, 데이터 유효
                    // end else begin
                    //     data_valid_next = 1'b0;  // 체크섬 불일치, 데이터 무효
                    // end
                end
                
                if (tick) begin
                    if (cnt_reg >= STOP_CNT - 1) begin
                        fsm_next = IDLE;
                        cnt_next = 0;
                    end else begin
                        cnt_next = cnt_reg + 1;
                    end
                end
            end
            
            default: begin
                fsm_next = IDLE;
            end
        endcase
    end
endmodule

module tick_gen(
    input               clk,       // 시스템 클럭 (예: 100MHz)
    input               reset,     // 리셋 신호 (활성 높음)
    output reg          tick_10us  // 10us 마다 발생하는 틱
);

    // 클럭 주파수에 따른 카운터 값 설정
    // 예: 100MHz 클럭에서 10us를 위한 카운트 값 = 100MHz * 0.00001s = 1000
    parameter COUNT_MAX = 1000;
    
    // 카운터 레지스터
    reg [9:0] counter; // 최대 1023까지 카운트 가능
    
    // 카운터 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 10'd0;
            tick_10us <= 1'b0;
        end else begin
            if (counter >= COUNT_MAX - 1) begin
                counter <= 10'd0;
                tick_10us <= 1'b1;  // 10us 마다 틱 발생
            end else begin
                counter <= counter + 1'b1;
                tick_10us <= 1'b0;  // 틱은 1클럭 주기만 유지
            end
        end
    end
endmodule

// module dht11_controller(
//     input                       clk,
//     input                       rst,
//     input                       start,
//     output  reg [15:0]          humidity,
//     output  reg [15:0]          celcius,
//     inout                       dht_io
//     );

//     wire                        tick;
//     tick_gen U_Tick(
//         .clk                    (clk),
//         .reset                  (rst),      
//         .tick_10us              (tick)
//     );

//     parameter                   CNT = 180, WAIT_CNT = 3, TIME_OUT = 200, STOP_CNT = 5;
//     parameter                   BIT_THRESHOLD = 3; 
//     localparam                  IDLE = 0, START = 1, WAIT = 2, SYNC_LOW = 3, SYNC_HIGH = 4, DATA_LOW = 5, DATA_HIGH = 6, STOP = 7;

//     reg [2:0]                   fsm_state, fsm_next;
//     reg [$clog2(CNT) - 1:0]     cnt_reg, cnt_next;
//     reg                         out_reg, out_next;
//     reg                         en_reg, en_next; // 0 : read mode
//     reg [39:0]                  data_reg, data_next; // shift register
//     reg                         data_valid_reg, data_valid_next; // 데이터 유효 신호
//     reg [5:0]                   bit_cnt_reg, bit_cnt_next; // 비트 카운터 (0-39)
//     wire [7:0]                  cal_parity; // 체크섬 계산용 와이어
    
//     // // 테스트를 위한 고정 값
//     // reg [7:0] test_hum_int = 8'd45;  // 45% 습도 정수부
//     // reg [7:0] test_hum_dec = 8'd2;  // 2% 습도 소수부
//     // reg [7:0] test_temp_int = 8'd25; // 25℃ 온도 정수부
//     // reg [7:0] test_temp_dec = 8'd6; // 6℃ 온도 소수부
//     // reg [7:0] test_checksum = 8'd78; // 체크섬 (0x2D + 0x02 + 0x19 + 0x06 = 0x4E)

//     // 체크섬 계산
//     assign cal_parity = data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8];

//     // dht_io 신호 제어
//     assign dht_io = (en_reg) ? out_reg : 1'bz;

//     always @(posedge clk, posedge rst) begin
//         if (rst) begin
//             fsm_state <= IDLE;
//             cnt_reg <= 0;
//             out_reg <= 1; // 초기 상태는 HIGH
//             en_reg <= 1;  // 초기 상태는 출력 모드
//             data_reg <= 0;
//             data_valid_reg <= 0;
//             bit_cnt_reg <= 0;
//             humidity <= 0;
//             celcius <= 0;
//         end else begin
//             fsm_state <= fsm_next;
//             cnt_reg <= cnt_next;
//             out_reg <= out_next;
//             en_reg <= en_next;
//             data_reg <= data_next;
//             data_valid_reg <= data_valid_next;
//             bit_cnt_reg <= bit_cnt_next;

//             if (data_valid_reg) begin
//                 // 데이터 레지스터에서 값 추출 및 출력 레지스터에 저장
//                 humidity <= {data_reg[39:32], data_reg[31:24]}; // 상위 16비트 -> 습도
//                 celcius <= {data_reg[23:16], data_reg[15:8]};   // 다음 16비트 -> 온도
//             end
            
//             // 테스트용: start 신호가 들어오면 직접 테스트 값 할당
//             // if (start) begin
//             //     // 일정 시간 후 테스트 값으로 강제 설정
//             //     #100;
//             //     humidity <= {test_hum_int, test_hum_dec};  // 45.2% 습도
//             //     celcius <= {test_temp_int, test_temp_dec}; // 25.6℃ 온도
//             // end
//         end
//     end

//     always @(*) begin
//         fsm_next = fsm_state;
//         cnt_next = cnt_reg;
//         out_next = out_reg;
//         en_next = en_reg;
//         data_next = data_reg;
//         data_valid_next = data_valid_reg;
//         bit_cnt_next = bit_cnt_reg;
        
//         case (fsm_state)
//             IDLE: begin
//                 out_next = 1;        // 신호 HIGH 유지
//                 en_next = 1;         // 출력 모드
//                 data_valid_next = 0; // 데이터 유효 신호 비활성화
//                 bit_cnt_next = 0;    // 비트 카운터 초기화
                
//                 if (start) begin
//                     fsm_next = START;
//                     cnt_next = 0;
                    
//                     // 테스트 데이터 직접 설정
//                     // data_next = {test_hum_int, test_hum_dec, test_temp_int, test_temp_dec, test_checksum};
//                     data_valid_next = 1'b1;
//                 end
//             end

//             START: begin
//                 out_next = 0;  // 신호 LOW로 설정 (시작 신호)
//                 en_next = 1;   // 출력 모드 유지
                
//                 if (tick) begin
//                     if (cnt_reg == CNT - 1) begin
//                         fsm_next = WAIT;
//                         cnt_next = 0;
//                         out_next = 1; // 신호 릴리스
//                     end else begin
//                         cnt_next = cnt_reg + 1;
//                     end
//                 end
//             end
            
//             // 이하 기존 코드와 동일...
//             // (나머지 상태는 변경 없음)
            
//             WAIT: begin
//                 out_next = 1;  // 신호 HIGH로 유지
//                 en_next = 0;   // 입력 모드로 전환
                
//                 if (tick) begin
//                     if (cnt_reg == WAIT_CNT - 1) begin
//                         fsm_next = SYNC_LOW;
//                         cnt_next = 0;
//                     end else begin
//                         cnt_next = cnt_reg + 1;
//                     end
//                 end
//             end
            
//             SYNC_LOW: begin
//                 en_next = 0;  // 입력 모드 유지
                
//                 if (tick) begin
//                     if (dht_io == 0) begin
//                         // LOW 신호 감지 중
//                         cnt_next = cnt_reg + 1;
//                     end else if (cnt_reg > 0) begin
//                         // LOW -> HIGH 변화 감지
//                         fsm_next = SYNC_HIGH;
//                         cnt_next = 0;
//                     end else begin
//                         // 감지 대기 중
//                         cnt_next = cnt_reg + 1;
//                     end
                    
//                     if (cnt_reg >= TIME_OUT) begin
//                         fsm_next = IDLE; // 타임아웃 발생
//                     end
//                 end
//             end

//             SYNC_HIGH: begin
//                 en_next = 0;  // 입력 모드 유지
                
//                 if (tick) begin
//                     if (dht_io == 1) begin
//                         // HIGH 신호 감지 중
//                         cnt_next = cnt_reg + 1;
//                     end else if (cnt_reg > 0) begin
//                         // HIGH -> LOW 변화 감지
//                         fsm_next = DATA_LOW;
//                         cnt_next = 0;
//                     end else begin
//                         // 감지 대기 중
//                         cnt_next = cnt_reg + 1;
//                     end
                    
//                     if (cnt_reg >= TIME_OUT) begin
//                         fsm_next = IDLE; // 타임아웃 발생
//                     end
//                 end
//             end

//             DATA_LOW: begin
//                 en_next = 0;  // 입력 모드 유지
                
//                 if (tick) begin
//                     if (dht_io == 0) begin
//                         // LOW 신호 감지 중
//                         cnt_next = cnt_reg + 1;
//                     end else if (cnt_reg > 0) begin
//                         // LOW -> HIGH 변화 감지
//                         fsm_next = DATA_HIGH;
//                         cnt_next = 0;
//                     end else begin
//                         // 감지 대기 중
//                         cnt_next = cnt_reg + 1;
//                     end
                    
//                     if (cnt_reg >= TIME_OUT) begin
//                         fsm_next = IDLE; // 타임아웃 발생
//                     end
//                 end
//             end

//             DATA_HIGH: begin
//                 en_next = 0;  // 입력 모드 유지
                
//                 if (tick) begin
//                     if (dht_io == 1) begin
//                         // HIGH 신호 감지 중, 카운터 증가
//                         cnt_next = cnt_reg + 1;
//                     end else if (cnt_reg > 0) begin
//                         // HIGH -> LOW 변화 감지, 비트 값 결정
//                         if (bit_cnt_reg < 40) begin
//                             // 비트 값 판단 (임계값 이상이면 1, 미만이면 0)
//                             if (cnt_reg >= BIT_THRESHOLD) begin
//                                 // 1 비트 수신 (MSB 순서로 저장)
//                                 data_next = {data_reg[38:0], 1'b1};
//                             end else begin
//                                 // 0 비트 수신 (MSB 순서로 저장)
//                                 data_next = {data_reg[38:0], 1'b0};
//                             end
                            
//                             bit_cnt_next = bit_cnt_reg + 1;
                            
//                             if (bit_cnt_next == 40) begin  // 모든 비트 수신 완료
//                                 fsm_next = STOP;
//                                 cnt_next = 0;
//                             end else begin  // 다음 비트 수신
//                                 fsm_next = DATA_LOW;
//                                 cnt_next = 0;
//                             end
//                         end else begin
//                             cnt_next = 0;
//                             fsm_next = STOP;
//                         end
//                     end else begin
//                         // 감지 대기 중
//                         cnt_next = cnt_reg + 1;
//                     end
                    
//                     if (cnt_reg >= TIME_OUT) begin
//                         fsm_next = IDLE; // 타임아웃 발생
//                     end
//                 end
//             end

//             STOP: begin
//                 en_next = 1;      // 출력 모드로 복귀
//                 out_next = 1;     // 신호 HIGH로 설정
                
//                 if (bit_cnt_reg == 40) begin
//                     // 테스트용: 항상 데이터 유효 설정
//                     data_valid_next = 1'b1;
//                 end
                
//                 if (tick) begin
//                     if (cnt_reg >= STOP_CNT - 1) begin
//                         fsm_next = IDLE;
//                         cnt_next = 0;
//                     end else begin
//                         cnt_next = cnt_reg + 1;
//                     end
//                 end
//             end
            
//             default: begin
//                 fsm_next = IDLE;
//             end
//         endcase
//     end
// endmodule

// module tick_gen(
//     input               clk,       // 시스템 클럭 (예: 100MHz)
//     input               reset,     // 리셋 신호 (활성 높음)
//     output reg          tick_10us  // 10us 마다 발생하는 틱
// );

//     // 클럭 주파수에 따른 카운터 값 설정
//     // 예: 100MHz 클럭에서 10us를 위한 카운트 값 = 100MHz * 0.00001s = 1000
//     parameter COUNT_MAX = 1000;
    
//     // 카운터 레지스터
//     reg [9:0] counter; // 최대 1023까지 카운트 가능
    
//     // 카운터 로직
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             counter <= 10'd0;
//             tick_10us <= 1'b0;
//         end else begin
//             if (counter >= COUNT_MAX - 1) begin
//                 counter <= 10'd0;
//                 tick_10us <= 1'b1;  // 10us 마다 틱 발생
//             end else begin
//                 counter <= counter + 1'b1;
//                 tick_10us <= 1'b0;  // 틱은 1클럭 주기만 유지
//             end
//         end
//     end

// endmodule

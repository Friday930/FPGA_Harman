`timescale 1ns / 1ps

module clock_module(
    input           clk, reset,
    input           [7:0] uart_data,     // UART로부터 받은 ASCII 데이터
    input           uart_data_valid,     // UART 데이터 유효 신호
    output   reg    [5:0] o_sec,         // 초 (0-59)
    output   reg    [5:0] o_min,         // 분 (0-59)
    output   reg    [4:0] o_hour         // 시 (0-23)
);

    // 내부 신호
    reg         [$clog2(100_000_000)-1:0] counter;    // 100MHz -> 1Hz 변환 카운터
    
    // 1Hz 클럭 생성 (1초에 한 번 펄스)
    reg         r_1Hz_tick;
    
    // 100MHz -> 1Hz 변환 로직
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
            r_1Hz_tick <= 0;
        end else begin
            if (counter >= 100_000_000 - 1) begin  // 100MHz 클럭 기준 1초
                counter <= 0;
                r_1Hz_tick <= 1'b1;
            end else begin
                counter <= counter + 1;
                r_1Hz_tick <= 1'b0;
            end
        end
    end
    
    // UART 명령 디코더와 시계 동작 로직
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            o_sec <= 0;
            o_min <= 0;
            o_hour <= 0;
        end else begin
            // UART 데이터가 유효할 때 ASCII 명령 처리
            if (uart_data_valid) begin
                case (uart_data)
                    8'h48, 8'h68: begin  // 'H' 또는 'h' - 시간 증가
                        if (o_hour == 23)
                            o_hour <= 0;
                        else
                            o_hour <= o_hour + 1;
                    end
                    
                    8'h4D, 8'h6D: begin  // 'M' 또는 'm' - 분 증가
                        if (o_min == 59)
                            o_min <= 0;
                        else
                            o_min <= o_min + 1;
                    end
                    
                    8'h53, 8'h73: begin  // 'S' 또는 's' - 초 증가
                        if (o_sec == 59)
                            o_sec <= 0;
                        else
                            o_sec <= o_sec + 1;
                    end
                    
                    8'h52, 8'h72: begin  // 'R' 또는 'r' - 리셋
                        o_sec <= 0;
                        o_min <= 0;
                        o_hour <= 0;
                    end
                    
                    // 추가 명령을 여기에 넣을 수 있음
                    default: ;  // 다른 문자는 무시
                endcase
            end
            // 정상 시계 동작 (UART 명령이 없을 때)
            else if (r_1Hz_tick) begin
                // 초 증가
                if (o_sec == 59) begin
                    o_sec <= 0;
                    // 분 증가
                    if (o_min == 59) begin
                        o_min <= 0;
                        // 시 증가
                        if (o_hour == 23) begin
                            o_hour <= 0;
                        end else begin
                            o_hour <= o_hour + 1;
                        end
                    end else begin
                        o_min <= o_min + 1;
                    end
                end else begin
                    o_sec <= o_sec + 1;
                end
            end
        end
    end
endmodule

// UART 데이터를 받아 clock_module에 전달하는 최상위 모듈
module uart_clock_top(
    input           clk, reset,
    input           uart_rx,          // UART 수신
    output          uart_tx,          // UART 송신 (피드백용, 선택적)
    output   [5:0]  sec,              // 초
    output   [5:0]  min,              // 분
    output   [4:0]  hour              // 시
);

    // UART 수신 데이터와 유효 신호
    wire [7:0] rx_data;
    wire rx_data_valid;
    
    // UART 수신 모듈 (예시, 실제 구현은 UART 모듈에 따라 다름)
    uart_receiver uart_rx_inst(
        .clk(clk),
        .reset(reset),
        .rx(uart_rx),
        .rx_data(rx_data),
        .rx_data_valid(rx_data_valid)
    );
    
    // 시계 모듈 인스턴스
    clock_module clock_inst(
        .clk(clk),
        .reset(reset),
        .uart_data(rx_data),
        .uart_data_valid(rx_data_valid),
        .o_sec(sec),
        .o_min(min),
        .o_hour(hour)
    );
    
    // 선택적: UART 송신 로직 (수신된 명령을 에코백)
    // uart_transmitter uart_tx_inst(
    //     .clk(clk),
    //     .reset(reset),
    //     .tx_data(rx_data),
    //     .tx_start(rx_data_valid),
    //     .tx(uart_tx),
    //     .tx_busy() // 필요시 연결
    // );
    
    // 명령어를 송신 버퍼에 저장할 경우:
    assign uart_tx = uart_rx; // 단순 루프백 (임시)

endmodule

// UART 수신기 모듈 (기본 예시, 실제 구현에 맞게 수정 필요)
module uart_receiver(
    input           clk, reset,
    input           rx,
    output reg      [7:0] rx_data,
    output reg      rx_data_valid
);
    // UART 관련 파라미터
    parameter CLK_FREQ = 100_000_000;  // 100MHz
    parameter BAUD_RATE = 9600;        // 9600 baud
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    
    // 상태 정의
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    
    // 내부 신호
    reg [1:0] state;
    reg [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    reg [2:0] bit_index;
    reg rx_d1, rx_d2;  // 메타안정성 방지용 레지스터
    
    // 메타안정성 방지
    always @(posedge clk) begin
        if (reset) begin
            rx_d1 <= 1'b1;
            rx_d2 <= 1'b1;
        end else begin
            rx_d1 <= rx;
            rx_d2 <= rx_d1;
        end
    end
    
    // UART 수신 로직
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            rx_data <= 0;
            rx_data_valid <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rx_data_valid <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    
                    if (rx_d2 == 1'b0) begin  // 시작 비트 감지
                        state <= START;
                    end
                end
                
                START: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        if (rx_d2 == 1'b0) begin  // 시작 비트 확인
                            clk_count <= 0;
                            state <= DATA;
                        end else begin
                            state <= IDLE;  // 잘못된 시작 비트
                        end
                    end
                end
                
                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_data[bit_index] <= rx_d2;  // LSB부터 비트 수신
                        
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end
                
                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        rx_data_valid <= 1'b1;  // 데이터 수신 완료
                        clk_count <= 0;
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule

// `timescale 1ns / 1ps

// module clock_module(
//     input           clk, reset,
//     input           i_btn_hour,     // 시간 설정 버튼 (아래 버튼)
//     input           i_btn_min,      // 분 설정 버튼 (왼쪽 버튼)
//     input           i_btn_sec,      // 초 설정 버튼 (위 버튼)
//     output   reg    [5:0] o_sec,    // 초 (0-59)
//     output   reg    [5:0] o_min,    // 분 (0-59)
//     output   reg    [4:0] o_hour    // 시 (0-23)
// );

//     // 내부 신호
//     reg         [$clog2(100_000_000)-1:0] counter;    // 100MHz -> 1Hz 변환 카운터
//     wire        w_btn_hour;                          // 디바운싱된 시간 버튼 신호
//     wire        w_btn_min;                           // 디바운싱된 분 버튼 신호
//     wire        w_btn_sec;                           // 디바운싱된 초 버튼 신호
    
//     // 1Hz 클럭 생성 (1초에 한 번 펄스)
//     reg         r_1Hz_tick;
    
//     // 100MHz -> 1Hz 변환 로직
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             counter <= 0;
//             r_1Hz_tick <= 0;
//         end else begin
//             if (counter >= 100_000_000 - 1) begin  // 100MHz 클럭 기준 1초
//                 counter <= 0;
//                 r_1Hz_tick <= 1'b1;
//             end else begin
//                 counter <= counter + 1;
//                 r_1Hz_tick <= 1'b0;
//             end
//         end
//     end
    
//     // 버튼 디바운싱 모듈 인스턴스 - 각 버튼별로 인스턴스 생성
//     btn_clock U_BTN_HOUR(
//         .i_btn(i_btn_hour),
//         .clk(clk),
//         .reset(reset),
//         .o_btn(w_btn_hour)
//     );
    
//     btn_clock U_BTN_MIN(
//         .i_btn(i_btn_min),
//         .clk(clk),
//         .reset(reset),
//         .o_btn(w_btn_min)
//     );
    
//     btn_clock U_BTN_SEC(
//         .i_btn(i_btn_sec),
//         .clk(clk),
//         .reset(reset),
//         .o_btn(w_btn_sec)
//     );
    
//     // 시계 동작 로직
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             o_sec <= 0;
//             o_min <= 0;
//             o_hour <= 0;
//         end else begin
//             // 버튼 입력에 따라 각각 시/분/초 설정
//             if (w_btn_hour) begin  // 시간 설정 버튼 (아래 버튼)
//                 if (o_hour == 23) begin
//                     o_hour <= 0;
//                 end else begin
//                     o_hour <= o_hour + 1;
//                 end
//             end else if (w_btn_min) begin  // 분 설정 버튼 (왼쪽 버튼)
//                 if (o_min == 59) begin
//                     o_min <= 0;
//                 end else begin
//                     o_min <= o_min + 1;
//                 end
//             end else if (w_btn_sec) begin  // 초 설정 버튼 (위 버튼)
//                 if (o_sec == 59) begin
//                     o_sec <= 0;
//                 end else begin
//                     o_sec <= o_sec + 1;
//                 end
//             end else if (r_1Hz_tick) begin  // 정상 동작 (버튼이 눌리지 않았을 때)
//                 // 초 증가
//                 if (o_sec == 59) begin
//                     o_sec <= 0;
//                     // 분 증가
//                     if (o_min == 59) begin
//                         o_min <= 0;
//                         // 시 증가
//                         if (o_hour == 23) begin
//                             o_hour <= 0;
//                         end else begin
//                             o_hour <= o_hour + 1;
//                         end
//                     end else begin
//                         o_min <= o_min + 1;
//                     end
//                 end else begin
//                     o_sec <= o_sec + 1;
//                 end
//             end
//         end
//     end
// endmodule

// // 기존 버튼 디바운싱 모듈 유지
// module btn_clock(
//     input       i_btn, clk, reset,
//     output      o_btn
// );
    
//     // state
//     //         state, next;
//     reg         [7:0] q_reg, q_next; // shift register
//     reg         edge_detect;
//     wire        btn_debounce;
    
//     // 1kHz clk, state
//     reg         [$clog2(100_000)-1:0] counter;
//     reg         r_1kHz;
    
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             counter <= 0;
//             r_1kHz <= 0;
//         end else begin
//             if (counter == 100_000 - 1) begin
//                 counter <= 0;
//                 r_1kHz <= 1'b1;
//             end else begin // 1kHz 1thick
//                 counter <= counter + 1;
//                 r_1kHz <= 1'b0;
//             end
//         end
//     end
    
//     // state logic, shift register
//     always @(posedge r_1kHz, posedge reset) begin
//         if (reset) begin
//             q_reg <= 0;
//         end else q_reg <= q_next;
//     end
    
//     // next logic
//     always @(i_btn, r_1kHz) begin // event i_btn, r_1kHz
//         // q_reg 현재의 상위 7비트를 다음 하위 7비트에 넣고 최상위에는 i_btn을 넣어라
//         q_next = {i_btn,q_reg[7:1]}; // 8shift 동작 
//     end
    
//     // 8 input AND gate
//     assign btn_debounce = &q_reg;
    
//     // edge_detector, 100MHz -> F/F 추가
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             edge_detect <= 1'b0;
//         end else edge_detect <= btn_debounce;
//     end
    
//     // 최종 출력
//     assign o_btn = btn_debounce & (~edge_detect);
// endmodule

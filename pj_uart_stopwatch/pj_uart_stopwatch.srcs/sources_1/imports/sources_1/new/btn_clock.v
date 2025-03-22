`timescale 1ns / 1ps
module clock_module(
    input           clk, reset,
    input           uart_rx_valid,
    input           [7:0] uart_rx_data,
    output   reg    [5:0] o_sec,    // 초 (0-59)
    output   reg    [5:0] o_min,    // 분 (0-59)
    output   reg    [4:0] o_hour    // 시 (0-23)
);

    // 내부 신호
    reg [26:0] counter;  // 100MHz -> 1Hz 변환 카운터
    
    // ASCII 상수 정의
    localparam H_CMD = 8'h68; // 'h'
    localparam M_CMD = 8'h6D; // 'm'
    localparam S_CMD = 8'h73; // 's'
    
    // 시계 값 제한 (최대값)
    localparam HOUR_MAX = 23;
    localparam MIN_MAX = 59;
    localparam SEC_MAX = 59;
    
    // 1Hz 펄스 생성
    wire tick_1Hz = (counter == 100_000_000 - 1);
    
    // 명령어 카운터
    reg [3:0] cmd_counter;
    reg [7:0] prev_cmd;
    
    // 시계 동작 및 카운터 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            o_sec <= 0;
            o_min <= 0;
            o_hour <= 0;
            cmd_counter <= 0;
            prev_cmd <= 0;
        end else begin
            // 카운터 증가 (100MHz -> 1Hz)
            if (tick_1Hz)
                counter <= 0;
            else
                counter <= counter + 1;
            
            // 명령어 수신 및 처리
            if (uart_rx_valid) begin
                if (uart_rx_data != prev_cmd) begin
                    // 새로운 명령어 처리
                    prev_cmd <= uart_rx_data;
                    cmd_counter <= 0;  // 카운터 초기화
                    
                    case (uart_rx_data)
                        H_CMD: begin
                            // 시간 증가
                            if (o_hour >= HOUR_MAX)
                                o_hour <= 0;
                            else
                                o_hour <= o_hour + 1;
                        end
                        
                        M_CMD: begin
                            // 분 증가
                            if (o_min >= MIN_MAX)
                                o_min <= 0;
                            else
                                o_min <= o_min + 1;
                        end
                        
                        S_CMD: begin
                            // 초 증가
                            if (o_sec >= SEC_MAX)
                                o_sec <= 0;
                            else
                                o_sec <= o_sec + 1;
                        end
                    endcase
                end else if (cmd_counter < 4'hF) begin
                    // 같은 명령이 반복되는 경우, 카운터 증가
                    cmd_counter <= cmd_counter + 1;
                    
                    // 일정 간격으로만 처리 (4클럭마다)
                    if (cmd_counter == 4'h8) begin
                        case (uart_rx_data)
                            H_CMD: begin
                                if (o_hour >= HOUR_MAX)
                                    o_hour <= 0;
                                else
                                    o_hour <= o_hour + 1;
                            end
                            
                            M_CMD: begin
                                if (o_min >= MIN_MAX)
                                    o_min <= 0;
                                else
                                    o_min <= o_min + 1;
                            end
                            
                            S_CMD: begin
                                if (o_sec >= SEC_MAX)
                                    o_sec <= 0;
                                else
                                    o_sec <= o_sec + 1;
                            end
                        endcase
                    end
                end
            end else begin
                // UART 신호가 없으면 명령어 처리 상태 초기화
                prev_cmd <= 0;
                cmd_counter <= 0;
            end
            
            // 정상 시계 동작 (1초마다)
            if (tick_1Hz) begin
                // 초 증가
                if (o_sec >= SEC_MAX) begin
                    o_sec <= 0;
                    // 분 증가
                    if (o_min >= MIN_MAX) begin
                        o_min <= 0;
                        // 시 증가
                        if (o_hour >= HOUR_MAX)
                            o_hour <= 0;
                        else
                            o_hour <= o_hour + 1;
                    end else
                        o_min <= o_min + 1;
                end else
                    o_sec <= o_sec + 1;
            end
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

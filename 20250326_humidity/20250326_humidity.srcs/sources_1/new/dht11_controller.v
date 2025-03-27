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
    // input                       tick,
    input                       start,
    // input   [3:0]               led_m,
    output  reg [15:0]          humidity,
    output  reg [15:0]          celcius,
    inout                       dht_io
    );

    wire                        tick;
    tick_gen U_Tick(
        .clk                    (clk),
        .reset                  (rst),      
        .tick_10us              (tick) // tick 넣어줘야함
    );

    parameter                   CNT = 1800, WAIT_CNT = 3, TIME_OUT = 2000, STOP_CNT = 5;
    parameter                   BIT_THRESHOLD = 3; 
    localparam                  IDLE = 0, START = 1, WAIT = 2, SYNC_LOW = 3, SYNC_HIGH = 4, DATA_LOW = 5, DATA_HIGH = 6, STOP = 7;

    reg [2:0]                   fsm_state, fsm_next;
    reg [$clog2(CNT) - 1:0]     cnt_reg, cnt_next;
    reg                         out_reg, out_next;
    reg                         en_reg, en_next; // 0 : read mode
    // reg                         led_reg, led_next;
    reg [39:0]                  data_reg, data_next; // shift register
    reg                         data_valid_reg, data_valid_next; // 데이터 유효 신호
    reg [5:0]                   bit_cnt_reg, bit_cnt_next; // 비트 카운터 (0-39)
    // reg [7:0]                   parity_reg, parity_next; // parity bit 위한 register
    reg [7:0]                   cal_parity;


    assign                      dht_io = (en_reg) ? out_reg : 1'bz;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            fsm_state <= IDLE;
            cnt_reg <= 0;
            out_reg <= 0;
            en_reg <= 0;
            // led_reg <= 0;
            data_reg <= 0;
            data_valid_reg <= 0;
            // parity_reg <= 0;
            bit_cnt_reg <= 0;
            humidity <= 0;
            celcius <= 0;
        end else begin
            fsm_state <= fsm_next;
            cnt_reg <= cnt_next;
            out_reg <= out_next;
            en_reg <= en_next;
            // led_reg <= led_next;
            data_reg <= data_next;
            data_valid_reg <= data_valid_next;
            // parity_reg <= parity_next;
            bit_cnt_reg <= bit_cnt_next;

            if (data_valid_next) begin
                humidity <= {data_reg[39:32], data_reg[31:24]}; // 상위 16비트 -> 습도
                celcius <= {data_reg[23:16], data_reg[15:8]}; // 다음 16비트 -> 온도
                // parity_reg <= data_reg[7:0]; // 나머지 -> parity bit
            end
        end
    end

    always @(*) begin
        fsm_next = fsm_state;
        cnt_next = cnt_reg;
        out_next = out_reg;
        en_next = en_reg;
        // led_next = led_reg;
        data_next = data_reg;
        data_valid_next = data_valid_reg;
        // parity_next = parity_reg;
        bit_cnt_next = bit_cnt_reg;
        case (fsm_state)
            IDLE: begin
                out_next = 1;
                en_next = 1;
                data_valid_next = 0;
                bit_cnt_next = 0;
                if (start) begin
                    fsm_next = START;
                    cnt_next = 0;
                end
            end

            START: begin
                out_next = 0;
                en_next = 1;
                if (tick) begin
                    if (cnt_reg == CNT - 1) begin
                        fsm_next = WAIT;
                        cnt_next = 0;
                        out_next = 1; // release signal 
                    end cnt_next = cnt_reg + 1;
                end
            end
            
            WAIT: begin
                en_next = 0; // change input mode
                if (tick) begin
                    if (cnt_reg == WAIT_CNT - 1) begin
                        fsm_next = SYNC_LOW;
                        cnt_next = 0;
                    end cnt_next = cnt_reg + 1;
                end
            end
            
            // SYNC, DATA_LOW는 데이터 넘겨주기만
            SYNC_LOW: begin
                en_next = 0;
                if (tick) begin
                    if (dht_io == 0) begin
                        // LOW 신호 감지
                        cnt_next = 0;
                    end else if (cnt_reg > 0) begin
                        // sensing LOW to HIGH
                        fsm_next = SYNC_HIGH;
                        cnt_next = 0;
                    end

                    if (cnt_reg < TIME_OUT) begin
                        cnt_next = cnt_reg + 1;
                    end else begin
                        // occured timeout
                        fsm_next = IDLE;
                    end
                end
            end

            SYNC_HIGH: begin
                en_next = 0;
                if (tick) begin
                    if (dht_io == 1) begin
                        cnt_next = 0;
                    end else if (cnt_reg > 0) begin
                        fsm_next = DATA_LOW;
                        cnt_next = 0;
                    end

                    if (cnt_reg < TIME_OUT) begin
                        cnt_next = cnt_reg + 1;
                    end else fsm_next = IDLE;
                end
            end

            // stand-by data bit
            DATA_LOW: begin
                en_next = 0;
                if (tick) begin
                    if (dht_io == 0) begin
                        cnt_next = 0;
                    end else if (cnt_reg > 0) begin
                        fsm_next = DATA_HIGH;
                        cnt_next = 0;
                    end

                    if (cnt_reg < TIME_OUT) begin
                        cnt_next = cnt_reg + 1;
                    end else fsm_next = IDLE;
                end
            end

            // 데이터 판별 부분 -> DATA_0이 40보다 작으면 0, 크면 1
            DATA_HIGH: begin
                en_next = 0;
                
                if (tick) begin
                    if (dht_io == 1) begin
                        // HIGH 신호 감지, 카운터 증가
                        cnt_next = cnt_reg + 1;
                    end else begin
                        // HIGH에서 LOW로 전환 감지, 비트값 결정
                        if (bit_cnt_reg < 40) begin
                            // 카운터 값으로 비트 값 판단 (임계값 이상이면 1, 미만이면 0)
                            if (cnt_reg >= BIT_THRESHOLD) begin
                                data_next = {data_reg[38:0], 1'b1}; // 1 비트 수신
                            end else begin
                                data_next = {data_reg[38:0], 1'b0}; // 0 비트 수신
                            end
                            
                            bit_cnt_next = bit_cnt_reg + 1;
                            
                            if (bit_cnt_reg == 39) begin
                                // 모든 비트 수신 완료
                                fsm_next = STOP;
                            end else begin
                                // 다음 비트 수신
                                fsm_next = SYNC_LOW;
                            end
                        end
                        cnt_next = 0;
                    end
                    
                    if (cnt_reg >= TIME_OUT) begin
                        // 타임아웃 발생
                        fsm_next = IDLE;
                    end
                end
            end

            // recieve data complete
            STOP: begin
                en_next = 1;
                out_next = 1;
                
                if (bit_cnt_reg == 40) begin
                    // 페리티(체크섬) 계산: 각 바이트의 합이 마지막 바이트와 일치하는지 확인
                    cal_parity = data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8];
                    
                    // 계산된 체크섬과 수신된 체크섬 비교
                    if (cal_parity == data_reg[7:0]) begin
                        data_valid_next = 1'b1; // 체크섬 일치, 데이터 유효
                    end else begin
                        data_valid_next = 1'b0; // 체크섬 불일치, 데이터 무효
                    end
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

                // if (dht_io == 0) begin
                //     led_next = 1;
                // end else led_next = 0;
        endcase
    end
endmodule

module tick_gen(
    input               clk,        // 시스템 클럭 (예: 100MHz)
    input               reset,      // 리셋 신호 (활성 높음)
    output reg          tick_10us    // 1us 마다 발생하는 틱
);

    // 클럭 주파수에 따른 카운터 값 설정
    // 예: 100MHz 클럭에서 1us를 위한 카운트 값 = 100MHz * 0.000001s = 100
    parameter COUNT_MAX = 1000;
    
    // 카운터 레지스터
    reg [9:0] counter; // 최대 63까지 카운트 가능
    
    // 카운터 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 10'd0;
            tick_10us <= 1'b0;
        end else begin
            if (counter >= COUNT_MAX - 1) begin
                counter <= 10'd0;
                tick_10us <= 1'b1;  // 1us 마다 틱 발생
            end else begin
                counter <= counter + 1'b1;
                tick_10us <= 1'b0;  // 틱은 1클럭 주기만 유지
            end
        end
    end

endmodule

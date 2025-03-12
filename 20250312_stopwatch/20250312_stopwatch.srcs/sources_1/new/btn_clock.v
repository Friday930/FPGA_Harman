`timescale 1ns / 1ps

module clock_module(
    input           clk, reset,
    input           i_btn_hour,     // 시간 설정 버튼 (아래 버튼)
    input           i_btn_min,      // 분 설정 버튼 (왼쪽 버튼)
    input           i_btn_sec,      // 초 설정 버튼 (위 버튼)
    output   reg    [5:0] o_sec,    // 초 (0-59)
    output   reg    [5:0] o_min,    // 분 (0-59)
    output   reg    [4:0] o_hour    // 시 (0-23)
);

    // 내부 신호
    reg         [$clog2(100_000_000)-1:0] counter;    // 100MHz -> 1Hz 변환 카운터
    wire        w_btn_hour;                          // 디바운싱된 시간 버튼 신호
    wire        w_btn_min;                           // 디바운싱된 분 버튼 신호
    wire        w_btn_sec;                           // 디바운싱된 초 버튼 신호
    
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
    
    // 버튼 디바운싱 모듈 인스턴스 - 각 버튼별로 인스턴스 생성
    btn_clock U_BTN_HOUR(
        .i_btn(i_btn_hour),
        .clk(clk),
        .reset(reset),
        .o_btn(w_btn_hour)
    );
    
    btn_clock U_BTN_MIN(
        .i_btn(i_btn_min),
        .clk(clk),
        .reset(reset),
        .o_btn(w_btn_min)
    );
    
    btn_clock U_BTN_SEC(
        .i_btn(i_btn_sec),
        .clk(clk),
        .reset(reset),
        .o_btn(w_btn_sec)
    );
    
    // 시계 동작 로직
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            o_sec <= 0;
            o_min <= 0;
            o_hour <= 0;
        end else begin
            // 버튼 입력에 따라 각각 시/분/초 설정
            if (w_btn_hour) begin  // 시간 설정 버튼 (아래 버튼)
                if (o_hour == 23) begin
                    o_hour <= 0;
                end else begin
                    o_hour <= o_hour + 1;
                end
            end else if (w_btn_min) begin  // 분 설정 버튼 (왼쪽 버튼)
                if (o_min == 59) begin
                    o_min <= 0;
                end else begin
                    o_min <= o_min + 1;
                end
            end else if (w_btn_sec) begin  // 초 설정 버튼 (위 버튼)
                if (o_sec == 59) begin
                    o_sec <= 0;
                end else begin
                    o_sec <= o_sec + 1;
                end
            end else if (r_1Hz_tick) begin  // 정상 동작 (버튼이 눌리지 않았을 때)
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

// 기존 버튼 디바운싱 모듈 유지
module btn_clock(
    input       i_btn, clk, reset,
    output      o_btn
);
    
    // state
    //         state, next;
    reg         [7:0] q_reg, q_next; // shift register
    reg         edge_detect;
    wire        btn_debounce;
    
    // 1kHz clk, state
    reg         [$clog2(100_000)-1:0] counter;
    reg         r_1kHz;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
            r_1kHz <= 0;
        end else begin
            if (counter == 100_000 - 1) begin
                counter <= 0;
                r_1kHz <= 1'b1;
            end else begin // 1kHz 1thick
                counter <= counter + 1;
                r_1kHz <= 1'b0;
            end
        end
    end
    
    // state logic, shift register
    always @(posedge r_1kHz, posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end else q_reg <= q_next;
    end
    
    // next logic
    always @(i_btn, r_1kHz) begin // event i_btn, r_1kHz
        // q_reg 현재의 상위 7비트를 다음 하위 7비트에 넣고 최상위에는 i_btn을 넣어라
        q_next = {i_btn,q_reg[7:1]}; // 8shift 동작 
    end
    
    // 8 input AND gate
    assign btn_debounce = &q_reg;
    
    // edge_detector, 100MHz -> F/F 추가
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_detect <= 1'b0;
        end else edge_detect <= btn_debounce;
    end
    
    // 최종 출력
    assign o_btn = btn_debounce & (~edge_detect);
endmodule
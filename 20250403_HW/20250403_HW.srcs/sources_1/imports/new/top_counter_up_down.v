`timescale 1ns / 1ps

//--------------------------------------------
// 최상위 모듈
//--------------------------------------------
module top_system (
    input        clk,
    input        reset,
    input        rx,
    input        mode_sel_btn,  // 모드 선택 버튼 입력
    input        run_btn,       // Run/Stop 버튼
    input        clear_btn,     // Clear 버튼
    input        up_down_btn,   // Up/Down 버튼
    output       tx,
    output [3:0] fndCom,
    output [7:0] fndFont
);
    // 공유 신호
    wire [7:0] rx_data;
    wire rx_done;
    wire tx_busy;
    wire tx_done;
    
    // 모드 선택 상태 저장
    reg mode_sel;
    
    // 버튼 디바운스
    wire mode_sel_debounced;
    wire run_debounced;
    wire clear_debounced;
    wire up_down_debounced;
    
    // 버튼 상태 저장 (run 버튼용 토글 상태)
    reg run_state_normal;  // 일반 카운터 모드의 런 상태
    reg run_state_stopwatch;  // 스톱워치 모드의 런 상태
    
    // 디바운스 모듈 인스턴스들
    btn_debounce U_Mode_Sel_Debounce (
        .clk(clk),
        .reset(reset),
        .i_btn(mode_sel_btn),
        .o_btn(mode_sel_debounced)
    );
    
    btn_debounce U_Run_Debounce (
        .clk(clk),
        .reset(reset),
        .i_btn(run_btn),
        .o_btn(run_debounced)
    );
    
    btn_debounce U_Clear_Debounce (
        .clk(clk),
        .reset(reset),
        .i_btn(clear_btn),
        .o_btn(clear_debounced)
    );
    
    btn_debounce U_UpDown_Debounce (
        .clk(clk),
        .reset(reset),
        .i_btn(up_down_btn),
        .o_btn(up_down_debounced)
    );
    
    // 모드 전환 로직 - 버튼 한 번 누르면 모드 전환
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            mode_sel <= 0;
        end else if (mode_sel_debounced) begin
            mode_sel <= ~mode_sel; // 버튼 누를 때마다 모드 전환
        end
    end
    
    // Run 버튼 토글 로직 - 일반 카운터 모드
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            run_state_normal <= 0;
        end else if (clear_debounced && !mode_sel) begin
            run_state_normal <= 0;  // Clear 버튼 누르면 Run 상태 리셋
        end else if (run_debounced && !mode_sel) begin
            run_state_normal <= ~run_state_normal;  // Run 버튼 누를 때마다 상태 토글
        end
    end
    
    // Run 버튼 토글 로직 - 스톱워치 모드
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            run_state_stopwatch <= 0;
        end else if (clear_debounced && mode_sel) begin
            run_state_stopwatch <= 0;  // Clear 버튼 누르면 Run 상태 리셋
        end else if (run_debounced && mode_sel) begin
            run_state_stopwatch <= ~run_state_stopwatch;  // Run 버튼 누를 때마다 상태 토글
        end
    end
    
    // 일반 카운터 모드용 신호
    wire [13:0] count_normal;
    wire [3:0] dot_normal;
    wire en_normal, clear_normal, mode_normal;
    wire [7:0] tx_data_normal;
    wire tx_start_normal;
    
    // 스톱워치 모드용 신호
    wire [13:0] count_stopwatch;
    wire [3:0] dot_stopwatch;
    wire en_stopwatch, clear_stopwatch, mode_stopwatch;
    
    // 최종 출력 신호 (MUX로 선택)
    wire [13:0] final_count;
    wire [3:0] final_dot;
    
    // 시스템 선택 MUX
    assign final_count = mode_sel ? count_stopwatch : count_normal;
    assign final_dot = mode_sel ? dot_stopwatch : dot_normal;
    
    // UART 모듈 (공통)
    uart U_UART(
        .clk        (clk),
        .reset      (reset),
        .tx_data    (tx_data_normal),
        .tx_start   (tx_start_normal),
        .rx         (rx),
        .rx_data    (rx_data),
        .rx_done    (rx_done),
        .tx_busy    (tx_busy),
        .tx_done    (tx_done),
        .tx         (tx)
    );
    
    // 일반 카운터 모드 컨트롤 유닛
    control_unit U_ControlUnit_Normal (
        .clk        (clk),
        .reset      (reset),
        .tx_data    (tx_data_normal),
        .tx_start   (tx_start_normal),
        .rx_data    (rx_data),
        .rx_done    (rx_done),
        .tx_busy    (tx_busy),
        .tx_done    (tx_done),
        .en         (en_normal),
        .clear      (clear_normal),
        .mode       (mode_normal)
    );
    
    // 일반 카운터 모드
    counter_up_down U_Counter_Normal (
        .clk        (clk),
        .reset      (reset),
        .en         (en_normal || (run_state_normal && !mode_sel)),  // 버튼 상태 사용
        .clear      (clear_normal || (clear_debounced && !mode_sel)),
        .mode       (mode_normal || (up_down_debounced && !mode_sel)),
        .count      (count_normal),
        .dot_data   (dot_normal)
    );
    
    // 스톱워치 모드 컨트롤 유닛
    control_unit_2 U_ControlUnit_Stopwatch (
        .clk        (clk),
        .reset      (reset),
        .rx_data    (rx_data),
        .rx_done    (rx_done),
        .run        (en_stopwatch),
        .clear      (clear_stopwatch),
        .mode       (mode_stopwatch)
    );
    
    // 스톱워치 모드 (기존 카운터 활용)
    counter_up_down U_Counter_Stopwatch (
        .clk        (clk),
        .reset      (reset),
        .en         (en_stopwatch || (run_state_stopwatch && mode_sel)),  // 버튼 상태 사용
        .clear      (clear_stopwatch || (clear_debounced && mode_sel)),
        .mode       (1'b0),  // 항상 업 카운트 모드
        .count      (count_stopwatch),
        .dot_data   ()  // 스톱워치는 도트 패턴 하드 코딩
    );
    
    // 스톱워치 도트 패턴 설정 (8.88.8 형식)
    assign dot_stopwatch = 4'b0101;
    
    // FND 컨트롤러 (공통)
    fndController U_FndController (
        .clk        (clk),
        .reset      (reset),
        .fndData    (final_count),
        .fndDot     (final_dot),
        .fndCom     (fndCom),
        .fndFont    (fndFont)
    );
endmodule

//--------------------------------------------
// 카운터 컨트롤 유닛
//--------------------------------------------
module control_unit (
    input      clk,
    input      reset,
    output reg en,
    output reg clear,
    output reg mode,
    output reg [7:0] tx_data,
    output reg         tx_start,
    input       tx_busy,
    input       tx_done,
    input   [7:0]   rx_data,
    input           rx_done

);
    localparam STOP = 0, RUN = 1, CLEAR = 2;
    localparam  UP = 0, DOWN = 1;
    localparam  IDLE = 0, ECHO = 1;

    reg [1:0] state, state_next;
    reg         mode_state, mode_next;
    reg         echo_state, echo_next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
            mode_state <= UP;
            echo_state <= IDLE;
        end else begin
            state <= state_next;
            mode_state <= mode_next;
            echo_state <= echo_next;
        end
    end

    always @(*) begin
        echo_next = echo_state;
        tx_start = 0;
        tx_data = 0;
        case (echo_state)
            IDLE: begin
                tx_data = 0;
                tx_start = 0;
               if (rx_done == 1) begin
                    echo_next = ECHO;
               end 
            end 
            ECHO: begin
                if (tx_done) begin
                    echo_next = IDLE;
                end else begin
                    tx_data = rx_data;
                    tx_start = 1;    
                end
            end 
        endcase
    end

    always @(*) begin
        mode_next = mode_state;
        mode = 0;
        case (mode_state)
            UP: begin
                mode = 0;
                if (rx_done) begin
                    if (rx_data == 8'h4d || rx_data == 8'h6d) mode_next = DOWN;
                end
            end
            DOWN: begin
                mode = 1;
                if (rx_done) begin
                    if (rx_data == 8'h4d || rx_data == 8'h6d) mode_next = UP;
                end
            end
        endcase
    end

    always @(*) begin
        state_next = state;
        en         = 1'b0;
        clear      = 1'b0;

        case (state)
            STOP: begin
                en = 1'b0;
                clear = 1'b0;
                if (rx_done) begin
                    if (rx_data == 8'h52 || rx_data == 8'h72) state_next = RUN;
                    else if (rx_data == 8'h43 || rx_data == 8'h63) state_next = CLEAR;
                end
            end
            RUN: begin
                en = 1'b1;
                clear = 1'b0;
                if (rx_done) begin
                    if (rx_data == 8'h53 || rx_data == 8'h73) state_next = STOP;
                end
            end
            CLEAR: begin
                en = 1'b0;
                clear = 1'b1;
                state_next = STOP;
            end
        endcase
    end
endmodule

//--------------------------------------------
// 스톱워치 컨트롤 유닛
//--------------------------------------------
module control_unit_2 (
    input         clk,
    input         reset,
    output reg    run,
    output reg    clear,
    output reg    mode,
    input  [7:0]  rx_data,
    input         rx_done
);
    localparam  STOP_MODE = 0, RUN_MODE = 1, CLEAR_MODE = 2;
    localparam  UP = 0, DOWN = 1;
    
    reg [1:0] state, state_next;
    reg       mode_state, mode_next;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP_MODE;
            mode_state <= UP;
        end else begin
            state <= state_next;
            mode_state <= mode_next;
        end
    end
    
    always @(*) begin
        mode_next = mode_state;
        mode = 0;
        case (mode_state)
            UP: begin
                mode = 0;
                if (rx_done) begin
                    if (rx_data == 8'h55 || rx_data == 8'h75) mode_next = DOWN; // 'U' or 'u'
                end
            end
            DOWN: begin
                mode = 1;
                if (rx_done) begin
                    if (rx_data == 8'h44 || rx_data == 8'h64) mode_next = UP; // 'D' or 'd'
                end
            end
        endcase
    end
    
    always @(*) begin
        state_next = state;
        run = 1'b0;
        clear = 1'b0;
        
        case (state)
            STOP_MODE: begin
                if (rx_done) begin
                    if (rx_data == 8'h50 || rx_data == 8'h70) begin // 'P' or 'p' for play/run
                        state_next = RUN_MODE;
                    end else if (rx_data == 8'h43 || rx_data == 8'h63) begin // 'C' or 'c' for clear
                        state_next = CLEAR_MODE;
                    end
                end
            end
            RUN_MODE: begin
                run = 1'b1;
                if (rx_done) begin
                    if (rx_data == 8'h53 || rx_data == 8'h73) begin // 'S' or 's' for stop
                        state_next = STOP_MODE;
                    end
                end
            end
            CLEAR_MODE: begin
                clear = 1'b1;
                state_next = STOP_MODE;
            end
        endcase
    end
endmodule

//--------------------------------------------
// 업/다운 카운터 모듈
//--------------------------------------------
module counter_up_down (
    input         clk,
    input         reset,
    input         en,
    input         clear,
    input         mode,
    output [13:0] count,
    output [ 3:0] dot_data
);
    wire tick;

    clk_div_10hz U_Clk_Div_10Hz (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .en   (en),
        .clear(clear)
    );

    counter U_Counter_Up_Down (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .mode (mode),
        .en   (en),
        .clear(clear),
        .count(count)
    );

    comp_dot U_Comp_Dot (
        .count(count),
        .dot_data(dot_data)
    );
endmodule

//--------------------------------------------
// 도트 데이터 계산 모듈
//--------------------------------------------
module comp_dot (
    input  [13:0] count,
    output [ 3:0] dot_data
);
    assign dot_data = ((count % 10) < 5) ? 4'b1101 : 4'b1111;
endmodule

//--------------------------------------------
// 일반 카운터 모듈
//--------------------------------------------
module counter (
    input         clk,
    input         reset,
    input         tick,
    input         mode,
    input         en,
    input         clear,
    output [13:0] count
);
    reg [$clog2(10000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if (clear) begin
                counter <= 0;
            end else begin
                if (en) begin
                    if (mode == 1'b0) begin
                        if (tick) begin
                            if (counter == 9999) begin
                                counter <= 0;
                            end else begin
                                counter <= counter + 1;
                            end
                        end
                    end else begin
                        if (tick) begin
                            if (counter == 0) begin
                                counter <= 9999;
                            end else begin
                                counter <= counter - 1;
                            end
                        end
                    end
                end
            end
        end
    end
endmodule

//--------------------------------------------
// 10Hz 클럭 분주기
//--------------------------------------------
module clk_div_10hz (
    input  wire clk,
    input  wire reset,
    input  wire en,
    input  wire clear,
    output reg  tick
);
    reg [$clog2(10_000_000)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (clear) begin
                div_counter <= 0;
                tick <= 1'b0;
            end else if (en) begin
                if (div_counter == 10_000_000 - 1) begin
                    div_counter <= 0;
                    tick <= 1'b1;
                end else begin
                    div_counter <= div_counter + 1;
                    tick <= 1'b0;
                end
            end else begin
                tick <= 1'b0;
            end
        end
    end
endmodule

//--------------------------------------------
// 버튼 디바운스 모듈
//--------------------------------------------
module btn_debounce(
    input       i_btn, clk, reset,
    output      o_btn
    );

    // state
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

//--------------------------------------------
// 7-세그먼트 디스플레이 컨트롤러
//--------------------------------------------
module fndController (
    input         clk,
    input         reset,
    input  [13:0] fndData,
    input  [ 3:0] fndDot,
    output [ 3:0] fndCom,
    output [ 7:0] fndFont
);

    wire tick, fndDp;
    wire [1:0] digit_sel;
    wire [3:0] digit_1, digit_10, digit_100, digit_1000, digit;
    wire [7:0] fndSegData;

    assign fndFont = {fndDp, fndSegData[6:0]};

    clk_div_1khz U_Clk_Div_1Khz (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    counter_2bit U_Conter_2big (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .count(digit_sel)
    );

    decoder_2x4 U_Dec_2x4 (
        .x(digit_sel),
        .y(fndCom)
    );

    digitSplitter U_Digit_Splitter (
        .fndData(fndData),
        .digit_1(digit_1),
        .digit_10(digit_10),
        .digit_100(digit_100),
        .digit_1000(digit_1000)
    );

    mux_4x1 U_Mux_4x1 (
        .sel(digit_sel),
        .x0 (digit_1),
        .x1 (digit_10),
        .x2 (digit_100),
        .x3 (digit_1000),
        .y  (digit)
    );

    BCDtoSEG_decoder U_BCDtoSEG (
        .bcd(digit),
        .seg(fndSegData)
    );

    mux_4x1_1bit U_Mux_4x1_1bit (
        .sel(digit_sel),
        .x  (fndDot),
        .y  (fndDp)
    );
endmodule

//--------------------------------------------
// 1비트 4:1 멀티플렉서
//--------------------------------------------
module mux_4x1_1bit (
    input      [1:0] sel,
    input      [3:0] x,
    output reg       y
);

    always @(*) begin
        y = 1'b1;
        case (sel)
            2'b00: y = x[0];
            2'b01: y = x[1];
            2'b10: y = x[2];
            2'b11: y = x[3];
        endcase
    end
endmodule

//--------------------------------------------
// 1kHz 클럭 분주기
//--------------------------------------------
module clk_div_1khz (
    input clk,
    input reset,
    output reg tick
);
    reg [$clog2(100_000)-1 : 0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (div_counter == 100_000 - 1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule

//--------------------------------------------
// 2비트 카운터
//--------------------------------------------
module counter_2bit (
    input            clk,
    input            reset,
    input            tick,
    output reg [1:0] count
);
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            if (tick) begin
                count <= count + 1;
            end
        end
    end
endmodule

//--------------------------------------------
// 2:4 디코더
//--------------------------------------------
module decoder_2x4 (
    input      [1:0] x,
    output reg [3:0] y
);
    always @(*) begin
        y = 4'b1111;
        case (x)
            2'b00: y = 4'b1110;
            2'b01: y = 4'b1101;
            2'b10: y = 4'b1011;
            2'b11: y = 4'b0111;
        endcase
    end
endmodule

//--------------------------------------------
// 숫자 분할기
//--------------------------------------------
module digitSplitter (
    input  [13:0] fndData,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10,
    output [ 3:0] digit_100,
    output [ 3:0] digit_1000
);
    assign digit_1    = fndData % 10;
    assign digit_10   = fndData / 10 % 10;
    assign digit_100  = fndData / 100 % 10;
    assign digit_1000 = fndData / 1000 % 10;
endmodule

//--------------------------------------------
// 4:1 멀티플렉서
//--------------------------------------------
module mux_4x1 (
    input      [1:0] sel,
    input      [3:0] x0,
    input      [3:0] x1,
    input      [3:0] x2,
    input      [3:0] x3,
    output reg [3:0] y
);
    always @(*) begin
        y = 4'b0000;
        case (sel)
            2'b00: y = x0;
            2'b01: y = x1;
            2'b10: y = x2;
            2'b11: y = x3;
        endcase
    end
endmodule

//--------------------------------------------
// BCD to 7-세그먼트 디코더
//--------------------------------------------
module BCDtoSEG_decoder (
    input      [3:0] bcd,
    output reg [7:0] seg
);
    always @(bcd) begin
        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hf9;
            4'h2: seg = 8'ha4;
            4'h3: seg = 8'hb0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'ha: seg = 8'h88;
            4'hb: seg = 8'h83;
            4'hc: seg = 8'hc6;
            4'hd: seg = 8'ha1;
            4'he: seg = 8'h86;
            4'hf: seg = 8'h8e;
            default: seg = 8'hff;
        endcase
    end
endmodule

//--------------------------------------------
// UART 통신 모듈
//--------------------------------------------
module uart(
    input           clk,
    input           reset,
    input   [7:0]   tx_data,
    input           tx_start,
    input           rx,
    output  [7:0]   rx_data,
    output          rx_done,
    output          tx_busy,
    output          tx_done,
    output          tx
    );

    wire br_tick;

    baudrate_gen U_BaudRate_Gen(
    .clk            (clk),
    .reset          (reset),
    .br_tick        (br_tick)
    );

    transmitter U_Transmitter(
        .clk        (clk),
        .reset      (reset),
        .tx_data    (tx_data),
        .tx_start   (tx_start),
        .br_tick    (br_tick),
        .tx_busy    (tx_busy),
        .tx_done    (tx_done),
        .tx         (tx)
    );

    receiver U_Receiver(
        .clk(clk),
        .reset(reset),
        .br_tick(br_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );
endmodule

//--------------------------------------------
// 보드레이트 생성기
//--------------------------------------------
module baudrate_gen (
    input           clk,
    input           reset,
    output  reg     br_tick
);

    reg  [9:0]      br_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            br_counter <= 0;
            br_tick <= 0;
        end else begin
            if (br_counter == (100_000_000/9600/16) - 1) begin
                br_counter <= 0;
                br_tick <= 1'b1;
            end else begin
                br_counter <= br_counter + 1;
                br_tick <= 0;
            end
        end
    end
endmodule

//--------------------------------------------
// UART 송신기
//--------------------------------------------
module transmitter (
    input           clk,
    input           reset,
    input   [7:0]   tx_data,
    input           tx_start,
    input           br_tick,
    output          tx_busy,
    output          tx_done,
    output  reg     tx
);

    localparam      IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0]       state, next; // 상태 레지스터
    reg [7:0]       temp_data_reg, temp_data_next;
    reg [2:0]       bit_counter_reg, bit_counter_next;
    reg [3:0]       tick_counter_reg, tick_counter_next;
    reg             tx_busy_reg, tx_busy_next, tx_done_reg, tx_done_next;

    assign          tx_busy = tx_busy_reg;
    assign          tx_done = tx_done_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            temp_data_reg <= 0;
            bit_counter_reg <= 0;
            tick_counter_reg <= 0;
            tx_busy_reg <= 0;
            tx_done_reg <= 0;
        end else begin
            state <= next;
            temp_data_reg <= temp_data_next;
            bit_counter_reg <= bit_counter_next;
            tick_counter_reg <= tick_counter_next;
            tx_busy_reg <= tx_busy_next;
            tx_done_reg <= tx_done_next;
        end
    end

    always @(*) begin
        next = state;
        temp_data_next = temp_data_reg;
        bit_counter_next = bit_counter_reg;
        tick_counter_next = tick_counter_reg;
        tx_busy_next = tx_busy_reg;
        tx_done_next = tx_done_reg;
        case (state)
            IDLE: begin
                tx = 1;
                tx_busy_next = 0;
                tx_done_next = 0;
                if (tx_start) begin
                    next = START;
                    temp_data_next = tx_data;
                    tx_busy_next = 1;
                end
            end

            START: begin
                tx = 0;
                if (br_tick) begin
                    if (tick_counter_reg == 15) begin
                        next = DATA;
                        tick_counter_next = 0;
                        bit_counter_next = 0;
                    end else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end

            DATA: begin
                tx = temp_data_reg[0];
                if (br_tick) begin
                    if (tick_counter_reg == 15) begin
                        tick_counter_next = 0;
                        if (bit_counter_reg == 7) begin
                            next = STOP;
                        end else begin
                            bit_counter_next = bit_counter_reg + 1;
                            temp_data_next = {1'b0, temp_data_reg[7:1]}; // shift register
                        end
                    end else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end

            STOP: begin
                tx = 1;
                if (br_tick) begin
                    if (tick_counter_reg == 15) begin
                        next = IDLE;
                        tick_counter_next = 0;
                        tx_done_next = 1;
                    end else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule

//--------------------------------------------
// UART 수신기
//--------------------------------------------
module receiver (
    input           clk,
    input           reset,
    input           br_tick,
    input           rx,
    output  [7:0]   rx_data,
    output          rx_done
);

    localparam      IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0]       state, next; // 상태 레지스터
    reg             rx_done_reg, rx_done_next;
    reg [2:0]       bit_counter_reg, bit_counter_next;
    reg [3:0]       tick_counter_reg, tick_counter_next;
    reg [7:0]       temp_data_reg, temp_data_next; // 임시 값 저장

    assign          rx_data = temp_data_reg;
    assign          rx_done = rx_done_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            rx_done_reg <= 0;
            bit_counter_reg <= 0;
            tick_counter_reg <= 0;
            temp_data_reg <= 0;
        end else begin
            state <= next;
            rx_done_reg <= rx_done_next;
            bit_counter_reg <= bit_counter_next;
            tick_counter_reg <= tick_counter_next;
            temp_data_reg <= temp_data_next;
        end
    end

    always @(*) begin
        next = state;
        rx_done_next = rx_done_reg;
        bit_counter_next = bit_counter_reg;
        tick_counter_next = tick_counter_reg;
        temp_data_next = temp_data_reg;
        case (state)
            IDLE: begin
                rx_done_next = 0;
                if (rx == 0) begin
                    next = START;
                    bit_counter_next = 0;
                    tick_counter_next = 0;
                    temp_data_next = 0;
                end
            end

            START: begin
                if (br_tick) begin
                    if (tick_counter_reg == 7) begin
                        next = DATA;
                        tick_counter_next = 0;
                    end else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end

            DATA: begin
                if (br_tick) begin
                    if (tick_counter_reg == 15) begin
                        tick_counter_next = 0;
                        temp_data_next = {rx,temp_data_reg[7:1]};
                        if (bit_counter_reg == 7) begin
                            next = STOP;
                            bit_counter_next = 0;
                        end else begin
                            bit_counter_next = bit_counter_reg + 1;
                        end
                    end else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end

            STOP: begin
                if (br_tick) begin
                    if (tick_counter_reg == 15) begin
                        rx_done_next = 1;
                        next = IDLE;
                    end else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule
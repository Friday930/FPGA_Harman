`timescale 1ns / 1ps

module TOP_UART (
    input               clk,
    input               rst,
    input               rx,
    output              tx,
    output              [7:0] fnd_font
);    
    wire                w_rx_done;
    wire                [7:0] w_rx_data;

    uart U_UART(
        .clk            (clk),
        .rst            (rst),
        .btn_start      (w_rx_done),
        .tx_data_in     (w_rx_data),
        .tx_done        (),
        .tx             (tx),   
        .rx             (rx),
        .rx_done        (w_rx_done),
        .rx_data        (w_rx_data)
    );  


    simple_fnd_controller U_FND_CTR (
        .clk(clk),
        .reset(rst),
        .data_in(w_rx_data),   // 포트 이름 매칭
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

endmodule

module simple_fnd_controller (
    input clk, 
    input reset,
    input [7:0] data_in,
    // input rx_done,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);


    wire[3:0] w_bcd;//TEST
    reg [3:0] value_hex;

    always @(*) begin
        if (data_in >= 8'h30 && data_in <= 8'h39)  // ASCII '0'-'9'
            value_hex = data_in - 8'h30;
        else if (data_in >= 8'h41 && data_in <= 8'h46)  // ASCII 'A'-'F'
            value_hex = data_in - 8'h41 + 4'hA;
        else if (data_in >= 8'h61 && data_in <= 8'h66)  // ASCII 'a'-'f'
            value_hex = data_in - 8'h61 + 4'hA;
        else 
            value_hex = 4'h0;  // 기본값
    end
    
    assign w_bcd = value_hex;

     bcdtoseg U_BCDTOSEG(
        .bcd(w_bcd),
        .seg(fnd_font)

    );
    assign fnd_comm = 4'b1110;

endmodule

module bcdtoseg (
    input           [3:0] bcd, // [3:0] sum 값
    output          reg [7:0] seg
);
    // always 구문 출력으로 reg type를 가져야 한다
    always @(bcd) begin // 항상 대상(bcd)의 이벤트를 감시
        
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
            4'he: seg = 8'h7f; // dot
            // 4'hf: seg = 8'h8e;
            4'hf: seg = 8'hff;
            default: seg = 8'hff;
        endcase
    end
endmodule

module uart(
    input               clk,
    input               rst,

    input               btn_start,
    input               [7:0] tx_data_in,
    output              tx_done,
    output              tx,

    input               rx,
    output              rx_done,
    output              [7:0] rx_data
);  
    wire                w_tick;

    uart_tx U_UART_TX(
        .clk            (clk),
        .rst            (rst),
        .tick           (w_tick),
        .start_trigger  (btn_start),
        .data_in        (tx_data_in), // ASCII
        .o_tx_done      (tx_done),
        .o_tx           (tx)
    );

    baud_tick_gen U_BAUD_Tick_Gen(
        .clk            (clk),
        .rst            (rst),
        .baud_tick      (w_tick)
    );

    uart_rx U_UART_RX(
        .clk            (clk),
        .rst            (rst),
        .tick           (w_tick),
        .rx             (rx),
        .rx_done        (rx_done),
        .rx_data        (rx_data)
    );



endmodule

module uart_tx (
    input               clk,
    input               rst,
    input               tick,
    input               start_trigger,
    input               [7:0] data_in, 
    output              o_tx,
    output              o_tx_done
);

    // fsm state
    parameter           IDLE = 0, SEND = 1, START = 2, DATA = 3, STOP = 4;

    reg                 [3:0] state, next;
    reg                 tx_reg, tx_next;
    reg                 tx_done_reg;
    reg                 tx_done_next;
    reg                 [2:0] bit_count_reg;
    reg                 [2:0] bit_count_next;
    reg                 [3:0] tick_count_reg;
    reg                 [3:0] tick_count_next;

    assign              o_tx = tx_reg;
    assign              o_tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            tx_reg <= 1'b1; // UART tx line을 초기에 항상 1로 만들기 위함
            tx_done_reg <= 0;
            bit_count_reg <= 0;
            tick_count_reg <= 0;
        end else begin
            state <= next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
            bit_count_reg <= bit_count_next;
            tick_count_reg <= tick_count_next;
        end
    end

    // next
    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        bit_count_next = bit_count_reg;
        tick_count_next = tick_count_reg;
        case (state)
            IDLE: begin
                // tx_done_next = 1'b1; // high
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                tick_count_next = 0;
                if (start_trigger) begin
                    // 1번 자리
                    next = SEND;
                end
            end

            SEND: begin
                if (tick == 1'b1) begin
                    next = START;
                end
            end

            START: begin
                tx_done_next = 1'b1;
                tx_next = 1'b0; // 출력을 0으로 유지
                if (tick == 1'b1) begin
                    if (tick_count_reg == 15) begin
                        next = DATA;
                        bit_count_next = 0; // bit_count 초기화 (안하면 DATA bit_count에 잘못된 값 들어갈 가능성 O)
                        tick_count_next = 0;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = data_in[bit_count_reg]; // UART LSB first
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        tick_count_next = 0; // 다음 상태 가기 전 초기화
                        if (bit_count_reg == 7) begin
                            next = STOP; 
                        end else begin
                            next = DATA;
                            bit_count_next = bit_count_reg + 1; //bit count 증가
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;
                if (tick == 1'b1) begin
                    if (tick_count_reg == 15) begin
                        next = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule

// UART RX
module uart_rx (
    input               clk,
    input               rst,
    input               tick,
    input               rx,
    output              rx_done,
    output              [7:0] rx_data
);

    localparam          IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg                 [1:0] state, next;
    reg                 rx_done_reg, rx_done_next;
    reg                 [2:0] bit_count_reg_rx, bit_count_next_rx;
    reg                 [4:0] tick_count_reg_rx, tick_count_next_rx; // rx tick count 24
    reg                 [7:0] rx_data_reg, rx_data_next;

    // output
    assign              rx_done = rx_done_reg;
    assign              rx_data = rx_data_reg;

    // state
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            rx_done_reg <= 0;
            rx_data_reg <= 0;
            bit_count_reg_rx <= 0;
            tick_count_reg_rx <= 0;
        end else begin
            state <= next;
            rx_done_reg <= rx_done_next;
            rx_data_reg <= rx_data_next;
            bit_count_reg_rx <= bit_count_next_rx;
            tick_count_reg_rx <= tick_count_next_rx;
        end
    end

    // next
    always @(*) begin
        next = state;
        rx_data_next = rx_data_reg;
        tick_count_next_rx = tick_count_reg_rx;
        bit_count_next_rx = bit_count_reg_rx;
        rx_done_next = 1'b0;
        case (state)
            IDLE: begin
                tick_count_next_rx = 0;
                bit_count_next_rx = 0;
                rx_done_next = 1'b0;
                if (rx == 0) begin
                    next = START;
                end 
            end
            START: begin
                if (tick == 1'b1) begin    
                    if (tick_count_reg_rx == 7) begin // 8번 반복
                        next = DATA;
                        tick_count_next_rx = 0; // init tick count
                    end else begin
                        tick_count_next_rx = tick_count_reg_rx + 1;
                    end
                end
            end
            DATA: begin
                if (tick == 1'b1) begin
                    if (tick_count_reg_rx == 15) begin
                        // read data
                        rx_data_next [bit_count_reg_rx] = rx; 
                        if (bit_count_reg_rx == 7) begin
                            next = STOP;
                            tick_count_next_rx = 0; // tick count 초기화
                        end else begin
                            next = DATA;
                            bit_count_next_rx = bit_count_reg_rx + 1;
                            tick_count_next_rx = 0; // tick count 초기화, 다음 state로 갈땐 초기화
                        end
                    end else begin
                        tick_count_next_rx = tick_count_reg_rx + 1;
                    end
                end
            end
            STOP: begin
                if (tick == 1'b1) begin
                    if (tick_count_reg_rx == 23) begin
                        rx_done_next = 1'b1;
                        next = IDLE;
                    end else begin
                        tick_count_next_rx = tick_count_reg_rx + 1;
                    end
                end
            end
        endcase
    end

endmodule

module baud_tick_gen (
    input               clk,
    input               rst,
    output              baud_tick
);  
    parameter           BAUD_RATE = 9600; // BAUD_RATE = 19200;
    
    localparam          BAUD_COUNT = (100_000_000 / BAUD_RATE) / 16;
    reg                 [$clog2(BAUD_COUNT) - 1:0] count_reg;
    reg                 [$clog2(BAUD_COUNT) - 1:0] count_next;
    reg                 tick_reg, tick_next;
    assign              baud_tick = tick_reg; // output

    always @(posedge clk, posedge rst) begin
        if (rst == 1) begin
            count_reg <= 0;
            tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    //next
    always @(*) begin
        count_next = count_reg;
        tick_next = tick_reg;

        if (count_reg == BAUD_COUNT - 1) begin
            count_next = 0;
            tick_next = 1'b1;
        end else begin
            count_next = count_reg + 1;
            tick_next = 1'b0;
        end
    end
    
endmodule
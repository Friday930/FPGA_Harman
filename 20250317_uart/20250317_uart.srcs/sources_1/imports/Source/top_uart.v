`timescale 1ns / 1ps

module top_uart(
    input               clk,
    input               rst,
    input               btn_start,
    input               [7:0] tx_data_in,
    output              tx_done,
    output              tx
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
    reg                 bit_count_reg;
    reg                 bit_count_next;

    assign              o_tx = tx_reg;
    assign              o_tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            tx_reg <= 1'b1; // UART tx line을 초기에 항상 1로 만들기 위함
            tx_done_reg <= 0;
            bit_count_reg <= 0;
        end else begin
            state <= next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
            bit_count_reg <= bit_count_next;

        end
    end

    // next
    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        bit_count_reg = bit_count_next;

        case (state)
            IDLE: begin
                // tx_done_next = 1'b1; // high
                tx_next = 1'b1;
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
                if (tick == 1'b1) begin
                    tx_done_next = 1'b1;// 2번 자리
                    tx_next = 1'b0; // 출력
                    next = DATA;
                    bit_count_next = 0; // bit_count 초기화 (안하면 DATA bit_count에 잘못된 값 들어갈 가능성 O)
                end
            end

            DATA: begin
                if (bit_count_reg == 7) begin
                    next = STOP;
                end else begin
                   next = DATA;
                   tx_next = data_in[bit_count_reg]; // UART LSB first
                end
            end

            STOP: begin
                if (tick == 1'b1) begin
                    tx_done_next = 1'b0; // 3번 자리
                    tx_next = 1'b1;
                    next = IDLE;
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
    
    localparam          BAUD_COUNT = 100_100_100 / BAUD_RATE;
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
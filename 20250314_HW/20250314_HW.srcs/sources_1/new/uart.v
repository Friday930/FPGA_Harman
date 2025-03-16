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
    parameter           IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;

    reg                 [1:0] state, next;
    reg                 tx_reg, tx_next;
    reg                 tx_done_reg;
    reg                 tx_done_next;
    reg                 [2:0] bit_count, bit_count_next;  // To count 0 to 7 (8 bits)
    reg                 [7:0] data_reg, data_reg_next;    // To store data_in

    assign              o_tx = tx_reg;
    assign              o_tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx_reg <= 1'b1;        // UART tx line을 초기에 항상 1로 만들기 위함
            tx_done_reg <= 0;
            bit_count <= 0;
            data_reg <= 0;
        end else begin
            state <= next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
            bit_count <= bit_count_next;
            data_reg <= data_reg_next;
        end
    end

    // next
    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        bit_count_next = bit_count;
        data_reg_next = data_reg;

        case (state)
            IDLE: begin
                tx_next = 1'b1;
                bit_count_next = 3'b000;
                if (start_trigger) begin
                    next = START;
                    data_reg_next = data_in;  // Store data_in when start trigger is received
                end
            end

            START: begin
                if (tick == 1'b1) begin
                    tx_done_next = 1'b1;
                    tx_next = 1'b0;           // Start bit is 0
                    next = DATA;
                end
            end

            DATA: begin
                if (tick == 1'b1) begin
                    tx_next = data_reg[bit_count];  // Send data bit-by-bit
                    bit_count_next = bit_count + 1; // Increment bit counter
                    
                    if (bit_count == 3'b111) begin  // If all 8 bits are sent
                        next = STOP;
                    end
                end
            end

            STOP: begin
                if (tick == 1'b1) begin
                    tx_done_next = 1'b0;
                    tx_next = 1'b1;           // Stop bit is 1
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
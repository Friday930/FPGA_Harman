`timescale 1ns / 1ps

module top_uart(
    input               clk,
    input               rst,
    input               btn_start,
    input               tx
);  
    wire                w_tick;

    uart_tx U_UART_TX(
        .clk            (clk),
        .rst            (rst),
        .tick           (w_tick),
        .start_trigger  (btn_start),
        .data_in        (8'h30), // ASCII
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
    output              o_tx
);

    // fsm state
    parameter           IDLE = 4'h0, START = 4'h1, D0 = 4'h2, D1 = 4'h3, D2 = 4'h4, D3 = 4'h5,
                        D4 = 4'h6, D5 = 4'h7, D6 = 4'h8, D7 = 4'h9, STOP = 4'ha;

    reg                 [3:0] state, next;
    reg                 tx_reg, tx_next;

    assign              o_tx = tx_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            tx_reg <= 0;
        end else begin
            state <= next;
            tx_reg = tx_next;
        end
    end

    // next
    always @(*) begin
        next = state;
        tx_next = tx_reg;

        case (state)
            IDLE: begin
                tx_next = 1'b1; // high
                if (start_trigger) begin
                    next = START;
                end
            end

            START: begin
                if (tick == 1'b1) begin
                    tx_next = 1'b0; // 출력
                    next = D0;
                end
            end

            D0: begin
                if (tick == 1'b1) begin
                    tx_next = data_in[0];
                    next = D1;
                end
            end

            D1: begin
                if (tick == 1'b1) begin
                    tx_next = data_in[1];
                    next = D2;
                end
            end

            D2: begin
                if (tick == 1'b1) begin
                    tx_next = data_in[2];
                    next = D3;
                end
            end            

            D3: begin
                if (tick == 1'b1) begin
                    tx_next = data_in[3];
                    next = D4;
                end
            end

            D4: begin
                if (tick == 1'b1) begin
                    tx_next = data_in[4];
                    next = D5;
                end
            end
            
            D5: begin
                if (tick == 1'b1) begin
                    tx_next = data_in[5];
                    next = D6;
                end
            end

            D6: begin
                if (tick == 1'b1) begin
                    tx_next = data_in[6];
                    next = D7;
                end
            end
            
            D7: begin
                if (tick == 1'b1) begin
                    tx_next = data_in[7];
                    next = STOP;
                end
            end

            STOP: begin
                if (tick == 1'b1) begin
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
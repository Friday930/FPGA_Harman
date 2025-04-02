`timescale 1ns / 1ps

module UART(
    input           clk,
    input           reset,
    input           rx,
    output          rx_done,
    output          run,
    output          clear,
    output          mode
    );

    wire            tick;
    wire    [7:0]   rx_data, inst;

    tick_gen U_Tick_Gen(
        .clk(clk),
        .reset(reset),
        .baud_tick(tick)
    );

    UART_rx U_UART_RX(
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .rx(rx),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

    UART_cu U_UART_CU(
        .clk(clk),
        .reset(reset),
        .data(rx_data),
        .inst(inst)
    );

    cmd_decoder U_CMD(
        .ctrl(inst),
        .r(run),
        .c(clear),
        .m(mode)
    );

endmodule

module UART_rx (
    input           clk,
    input           reset,
    input           tick,
    input           rx,
    output          rx_done,
    output  [7:0]   rx_data
);

    parameter       IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0]       state, next;
    reg             rx_done_reg, rx_done_next;
    reg [2:0]       bit_count_reg, bit_count_next;
    reg [4:0]       tick_count_reg, tick_count_next;
    reg [7:0]       rx_data_reg, rx_data_next;

    assign          rx_data = rx_data_reg;
    assign          rx_done = rx_done_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
            bit_count_reg <= 0;
            tick_count_reg <= 0;
            rx_data_reg <= 0;
            rx_done_reg <= 0;
        end else begin
            state <= next;
            bit_count_reg <= bit_count_next;
            tick_count_reg <= tick_count_next;
            rx_data_reg <= rx_data_next;
            rx_done_reg <= rx_done_next;            
        end
    end

    always @(*) begin
        rx_done_next = 0;
        rx_data_next = rx_data_reg;
        next = state;
        bit_count_next = bit_count_reg;
        tick_count_next = tick_count_reg;

        case (state)
            IDLE: begin
                tick_count_next = 0;
                bit_count_next = 0;
                rx_done_next = 0;
                if (rx == 0) begin
                    next = START;
                end
            end 

            START: begin
                if (tick == 1) begin
                    if (tick_count_reg == 7) begin
                        next = DATA;
                        tick_count_next = 0;
                    end else tick_count_next = tick_count_reg + 1;
                end
            end

            DATA: begin
                if (tick == 1) begin
                    if (tick_count_reg == 15) begin
                        rx_data_next[bit_count_next] = rx;
                        if (bit_count_next == 7) begin
                            next = STOP;
                            tick_count_next = 0;
                        end else begin
                            next = DATA;
                            bit_count_next = bit_count_reg + 1;
                            tick_count_next = 0;
                        end
                    end tick_count_next = tick_count_reg + 1;
                end
            end

            STOP: begin
                if (tick == 1) begin
                    if (tick_count_reg == 23) begin
                        rx_done_next = 1;
                        next = IDLE;
                    end else tick_count_next = tick_count_reg + 1;
                end
            end
        endcase
    end
endmodule

module tick_gen (
    input           clk,
    input           reset,
    output          baud_tick
);
    
    parameter       BAUD_RATE = 9600;
    localparam      BAUD_COUNT = (100_000_000 / BAUD_RATE) / 16;

    reg             [$clog2(BAUD_COUNT)-1:0] count_reg, count_next;
    reg             tick_reg, tick_next;
    assign          baud_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next = tick_reg;

        if (count_reg == BAUD_COUNT - 1) begin
            count_next = 0;
            tick_next = 1;
        end else begin
            count_next = count_reg + 1;
            tick_next = 0;
        end
    end

endmodule

module UART_cu (
    input       clk,
    input       reset,
    input   [7:0]   data,
    output  reg [7:0]   inst
);
    reg     [7:0]   data_reg;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            inst <= 0;
            data_reg <= 0;
        end else begin
            if (data != data_reg) begin
                // 유효한 명령인 경우 출력에 반영
                if (data == "R" || data == "r")
                    inst <= "R";
                else if (data == "C" || data == "c")
                    inst <= "C";
                else if (data == "M" || data == "m")
                    inst <= "M";
                else 
                    inst <= 8'b0;
            end
            else if (data == 8'b0) begin
                inst <= 8'b0;
            end
            
            data_reg <= data;
        end
    end

endmodule

module cmd_decoder(
    input [7:0] ctrl,
    output reg r,
    output reg c,
    output reg m
);

    always @(ctrl) begin
        // 기본값: 모두 0
        r = 0;
        c = 0;
        m = 0;
        
        case(ctrl)
            8'h52, 8'h72: r = 1;
            8'h43, 8'h63: c = 1;
            8'h4D, 8'h6D: m = 1;
            default: ;          // 모두 0 유지
        endcase
    end
endmodule
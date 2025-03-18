`timescale 1ns / 1ps

module send_tx_btn(
    input               clk,
    input               rst,
    input               btn_start,
    output              tx
    );
    
    wire                w_start, w_tx_done;

    parameter           IDLE = 0, START = 1, SEND = 2;
    reg                 [1:0] state, next; // send char fsm state
    // wire                [7:0] w_tx_data;
    reg                 [7:0] send_tx_data_reg, send_tx_data_next;
    reg                 send_reg, send_next; // start trigger
    reg                 [3:0] send_count_reg, send_count_next; // send data count

    btn_debounce U_Start_btn(
        .i_btn          (btn_start), 
        .clk            (clk), 
        .reset          (rst),
        .o_btn          (w_start)
    );

    top_uart U_UART(
        .clk            (clk),
        .rst            (rst),
        .btn_start      (send_reg),
        .tx_data_in     (send_tx_data_reg),
        .o_tx_done      (w_tx_done), // UART tx 상태 체크
        .o_tx           (tx)
    );  

    // send tx ascii to PC
    always @(posedge clk, posedge rst) begin
       if (rst) begin
            send_tx_data_reg <= 8'h30; // "0"; 둘다 가능
            state <= IDLE;
            send_reg <= 1'b0;
            send_count_reg <= 4'b0;
       end else begin
            send_tx_data_reg <= send_tx_data_next;
            state <= next;
            send_reg <= send_next;
            send_count_reg <= send_count_next;
       end
    end

    always @(*) begin
        send_tx_data_next = send_tx_data_reg;
        next = state;
        send_next = 0; // for 1 tick (길게 만들때는 send_reg로 초기화)
        send_count_next = send_count_reg;
        case (state)
            IDLE: begin
                send_next = 0;
                send_count_next = 0;
                if (w_start == 1'b1) begin
                    next = START;
                    send_next = 1;
                end
            end
            START: begin
                send_next = 0;
                if (w_tx_done == 1'b1) begin
                    next = SEND;
                end
            end
            SEND: begin
                if (w_tx_done == 1'b0) begin
                    send_next = 1'b1; // send 1 tick
                    send_count_next = send_count_reg + 1;
                    if (send_count_reg == 15) begin
                        next = IDLE;
                    end else next = START;
                    // w_tx_done이 0으로 떨어진 다음에 1번만 증가시키기 위함.
                    
                    if (w_start == 1'b1) begin // from debounce
                        if (send_tx_data_reg == "z") begin
                            send_tx_data_next = "0";
                        end else send_tx_data_next = send_tx_data_reg + 1; // ASCII code value increase 1 
                    end
                end
            end
        endcase
    end

endmodule

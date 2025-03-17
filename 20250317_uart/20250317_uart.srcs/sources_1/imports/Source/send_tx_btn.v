`timescale 1ns / 1ps

module send_tx_btn(
    input               clk,
    input               rst,
    input               btn_start,
    output              tx
    );

    wire                w_start, w_tx_done;
    wire                [7:0] w_tx_data;
    // send tx ascii to PC
    reg                 [7:0] send_tx_data_reg, send_tx_data_next;

    btn_debounce U_Start_btn(
        .i_btn          (btn_start), 
        .clk            (clk), 
        .reset          (rset),
        .o_btn          (w_start)
    );

    top_uart U_UART(
        .clk            (clk),
        .rst            (rst),
        .btn_start      (w_start),
        .tx_data_in     (send_tx_data_reg),
        .tx             (tx),
        .tx_done        (w_tx_done)
    );  

    always @(posedge clk, posedge rst) begin
       if (rst) begin
            send_tx_data_reg <= 8'h30; // "0"; 둘다 가능
       end else begin
            send_tx_data_reg <= send_tx_data_next;
       end
    end

    always @(*) begin
        send_tx_data_next = send_tx_data_reg;
        if (w_start == 1'b1) begin // from debounce
            if (send_tx_data_reg == "z") begin
                send_tx_data_next = "0";
            end else send_tx_data_next = send_tx_data_reg + 1; // ASCII code value increase 1 
        end
    end

endmodule

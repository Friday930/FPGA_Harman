`timescale 1ns / 1ps

module top_counter_up_down (
    input           clk,
    input           reset,
    input           rx,
    input           start,
    output          tx,
    // input           mode,
    // input           run_stop,
    // input           clear,
    output  [3:0]   fndCom,
    output  [7:0]   fndFont
);
    wire    [13:0]  fndData;
    wire    [3:0]   fndDot;
    wire            w_run, w_clear;
    wire            run_stop, clear, mode;

    counter_up_down U_Counter (
        .clk        (clk),
        .reset      (reset),
        .mode       (mode),
        .run        (w_run),
        .clear      (w_clear),
        .count      (fndData),
        .dot_data   (fndDot)
    );

    fndController U_FndController (
        .clk        (clk),
        .reset      (reset),
        .fndData    (fndData),
        .fndDot     (fndDot),
        .fndCom     (fndCom),
        .fndFont    (fndFont)
    );

    UART U_UART(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .rx_done(rx_done),
        .run(run_stop),
        .clear(clear),
        .start(start),
        .mode(mode),
        .tx(tx)
    );

    control_unit U_CU(
        .clk        (clk),
        .reset      (reset),
        .sw1        (run_stop),
        .sw2        (clear),
        .run_stop   (w_run),
        .clear      (w_clear),
        .echo       (start)
    );

    
endmodule

module comp_dot (
    input   [13:0]  count,
    output  [3:0]   dot_data
);
    assign          dot_data = ((count % 10) < 5) ? 4'b1101 : 4'b1111;
    
endmodule

module counter_up_down (
    input           clk,
    input           reset,
    input           mode,
    // input           en,
    input           run,
    input           clear,
    output  [13:0]  count,
    output  [3:0]   dot_data
);
    wire            tick;

    clk_div_10hz U_Clk_Div_10Hz (
        .clk        (clk),
        .reset      (reset),
        .run        (run),
        .clear      (clear),
        .tick       (tick)
        // .en       (en)
    );

    counter U_Counter_Up_Down (
        .clk        (clk),
        .reset      (reset),
        .tick       (tick),
        .mode       (mode),
        .clear      (clear),
        .count      (count)
    );

    comp_dot U_Comp_Dot(
        .count      (count),
        .dot_data   (dot_data)
    );

endmodule


// module counter (
//     input           clk,
//     input           reset,
//     input           tick,
//     input           mode,
//     input           clear,
//     output  [13:0]  count
// );
//     reg [$clog2(10000)-1:0] counter;

//     assign count = counter;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             counter <= 0;
//         end else begin
//             if (clear) begin
//                 counter <= 0;
//             end else begin
//                 if (mode == 1'b0) begin
//                     if (tick) begin
//                         if (counter == 9999) begin
//                             counter <= 0;
//                         end else begin
//                             counter <= counter + 1;
//                         end
//                     end
//                 end else begin
//                     if (tick) begin
//                         if (counter == 0) begin
//                             counter <= 9999;
//                         end else begin
//                             counter <= counter - 1;
//                         end
//                     end
//                 end
//             end
//         end
//     end
// endmodule

module counter (
    input           clk,
    input           reset,
    input           tick,
    input           clear,
    input           mode,
    output  [13:0]  count
);
    reg [$clog2(10000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset | clear) begin
            counter <= 0;
        end else begin
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
endmodule

// module clk_div_10hz (
//     input  wire clk,
//     input  wire reset,
//     output reg  tick
// );
//     reg [$clog2(10_000_000)-1:0] div_counter;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             div_counter <= 0;
//             tick <= 1'b0;
//         end else begin
//             if (div_counter == 10_000_000 - 1) begin
//                 div_counter <= 0;
//                 tick <= 1'b1;
//             end else begin
//                 div_counter <= div_counter + 1;
//                 tick <= 1'b0;
//             end
//         end
//     end
// endmodule
module clk_div_10hz (
    input  wire clk,
    input  wire reset,
    input  wire run,
    input  wire clear,
    output   tick
);
    parameter COUNT = 10_000_000;
    reg [$clog2(COUNT)-1:0] div_counter_reg, div_counter_next;
    reg tick_reg, tick_next;

    assign tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter_reg <= 0;
            tick_reg <= 1'b0;
        end else begin
            if (div_counter_reg == COUNT - 1) begin
                div_counter_reg <= 0;
                tick_reg <= 1'b1;
            end else begin
                div_counter_reg <= div_counter_next + 1;
                tick_reg <= 1'b0;
            end
        end
    end

    always @(*) begin
        div_counter_next = div_counter_reg;
        tick_next = tick_reg;

        if (run == 1) begin
            if (div_counter_reg == COUNT - 1) begin
                div_counter_next = 0;
                tick_next = 1;
            end else begin
                div_counter_next = div_counter_reg + 1;
                tick_next = 0;
            end
        end else if (clear == 1) begin
            div_counter_next = 0;
            tick_next = 0;
        end
    end
endmodule
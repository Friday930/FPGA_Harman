`timescale 1ns / 1ps

module Top_Upcounter (
    input       clk, reset,
    input       [2:0] sw,
    output      [3:0] seg_comm,
    output      [7:0] seg
);
    wire        [13:0] w_count;
    wire        w_clk_10, w_run_stop, w_clear;
    wire        w_tick_100Hz;

    tick_100hz U_Tick_100hz(
        .clk        (clk),
        .reset      (reset),
        .run_stop   (w_run_stop),
        .o_tick_100hz (w_tick_100Hz)
    );

    counter_10000 U_Counter_10000(
        .clk        (w_clk_10),
        .reset      (reset),
        .clear      (w_clear),
        .count      (w_count)
    );

    fnd_controller U_fnd_cntl(
        .clk        (clk),
        .reset      (reset),
        // .bcd        (w_count),
        .seg        (seg),
        .seg_comm   (seg_comm)
    );

    control_unit U_Control_Unit(
        .clk        (clk),
        .reset      (reset),
        .i_run_stop (sw[0]),
        .i_clear    (sw[1]),
        .o_run_stop (w_run_stop),
        .o_clear    (w_clear)
    );
endmodule

// tick generator
module tick_100hz ( 
    input       clk, reset, run_stop, // clk = 100MHz
    output      o_tick_100Hz
);

    reg         [$clog2(1_000_000) - 1:0] r_counter;
    reg         r_tick_100Hz;

    assign      o_tick_100Hz = r_tick_100Hz;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
        end else begin
            if(run_stop == 1'b1) begin
                if(r_counter == 1_000_000 - 1) begin
                    r_counter <= 0;
                    r_tick_100Hz <= 1'b1;
                end else begin
                    r_counter <= r_counter + 1;
                    r_tick_100Hz <= 1'b0;
                end
            end
        end
    end
    
endmodule

module counter_10000 (
    input       clk, reset, clear,
    output      [13:0] count
);
    reg         [13:0] r_counter;
    assign      count = r_counter;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
        end else begin
            if(r_counter == 10000 - 1) begin
                r_counter <= 0;
            end else if (clear == 1'b1) begin
                r_counter <= 0;
            end else begin
                r_counter <= r_counter + 1;
            end
        end
    end
    
endmodule
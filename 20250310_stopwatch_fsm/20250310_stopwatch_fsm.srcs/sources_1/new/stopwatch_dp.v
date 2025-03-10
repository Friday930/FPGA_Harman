`timescale 1ns / 1ps

module stopwatch_dp(
    input       clk, reset, run, clear,
    output      [6:0] msec, sec, minute, 
    output      [4:0] hour
    );

    time_counter #(.TICK_COUNT(100) /*.BIT_WIDTH(7)*/) U_Time_mSec(
        .clk            (clk),
        .reset          (reset),
        .tick           (w_clk_100Hz),
        .o_time         (msec),
        .o_tick         (w_msec_tick)
    );

    time_counter #(.TICK_COUNT(60) /*.BIT_WIDTH(7)*/) U_Time_Sec(
        .clk            (clk),
        .reset          (reset),
        .tick           (w_msec_tick),
        .o_time         (sec),
        .o_tick         (w_sec_tick)
    );

    time_counter #(.TICK_COUNT(60) /*.BIT_WIDTH(7)*/) U_Time_Min(
        .clk            (clk),
        .reset          (reset),
        .tick           (w_sec_tick),
        .o_time         (minute),
        .o_tick         (w_minute_tick)
    );

    time_counter #(.TICK_COUNT(24) /*.BIT_WIDTH(7)*/) U_Time_Hour(
        .clk            (clk),
        .reset          (reset),
        .tick           (w_minute_tick),
        .o_time         (hour),
        .o_tick         ()
    );

    clk_div_100 U_Clk_Div(
        .clk            (clk),
        .reset          (reset),
        .run            (run),
        .clear          (clear),
        .o_clk          (w_clk_100Hz)
    );
endmodule




module time_counter #(parameter TICK_COUNT = 100 /*BIT_WIDTH = 7*/)(
    input       clk, reset, tick,
    output      [6:0] o_time, 
    output      o_tick
);
    reg         [$clog2(TICK_COUNT) - 1:0] count_reg, count_next;
    reg         tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

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
        if (tick == 1'b1) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next = 1'b0;
                tick_next = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next = 1'b0;
            end
        end
    end
endmodule

module clk_div_100 (
    input       clk, reset, run, clear,
    output      o_clk
);
    // parameter   FCOUNT = 1_000_000;
    parameter   FCOUNT = 10;
    reg         [$clog2(FCOUNT) - 1:0] count_reg, count_next;
    reg         clk_reg, clk_next; // 출력을 f/f로 내보내기 위함

    assign      o_clk = clk_reg; // 최종 출력

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg   <= 1'b0;
            clk_reg     <= 1'b0;
        end else begin
            count_reg   <= count_next;
            clk_reg     <= clk_next;
        end
    end
    // next
    always @(*) begin
        count_next  = count_reg;
        // clk_next    = clk_reg;
        clk_next    = 0;
        if (run == 1'b1) begin
            if(count_reg == FCOUNT - 1)begin
                count_next = 0;
                clk_next = 1'b1;
            end else begin
                count_next = count_reg + 1;
                clk_next = 1'b0;
            end
        end else if (clear == 1'b1) begin
            count_next = 0;
            clk_next = 0;
        end
    end 

endmodule
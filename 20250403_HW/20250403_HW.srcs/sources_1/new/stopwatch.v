`timescale 1ns / 1ps

// module stopwatch(
//     input                   clk,
//     input                   reset,
//     input                   run,
//     input                   clear,
//     input                   up_down
//     );


//     // stopwatch_cu U_Stopwatch_CU(
//     //     .clk(clk),
//     //     .reset(reset),
//     //     .run(run),
//     //     .clear(clear),
//     //     .run_inst(),
//     //     .clear_inst()
//     // );

//     stopwatch_dp U_StopWatch_DP(
//         .clk(),
//         .reset(),
//         .run(),
//         .clear(),
//         .msec(),
//         .sec(),
//         .min()
//     );

// endmodule

// module stopwatch_cu (
//     input                       clk,
//     input                       reset,
//     input                       run,
//     input                       clear,
//     output                      run_inst,
//     output                      clear_inst
// );

//     parameter                   STOP = 0, RUN = 1, CLEAR = 2;
//     reg [1:0]                   state, next;
//     reg                         run_reg, clear_reg;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             state <= 0;
//         end else begin
//             state <= next;
//         end
//     end

//     always @(*) begin
//         next = state;
//         case (state)
//             STOP: begin
//                 if (run == 1) begin
//                     next = RUN;
//                 end else if (clear == 1) begin
//                     next = CLEAR;
//                 end
//             end
//             RUN: begin
//                 if (run == 1) begin
//                     next = STOP;
//                 end
//             end 
//             CLEAR: begin
//                 if (clear == 1) begin
//                     next = STOP;
//                 end
//             end
//         endcase
//     end
    
// endmodule

module stopwatch_dp (
    input                       clk,
    input                       reset,
    input                       run,
    input                       clear,
    output  [$clog2(10)-1:0]    msec,
    output  [$clog2(60)-1:0]    sec,
    output  [$clog2(10)-1:0]    min
);
    wire                        tick_10Hz;
    wire                        w_msec_tick, w_sec_tick;

    clk_div_10 U_Tick_100Hz(
        .clk                    (clk),
        .reset                  (reset),
        .run                    (run),
        .clear                  (clear),
        .clk_10Hz               (tick_10Hz)
    );
    
    timecounter #(.TICK(10), .BIT($clog2(10))) U_Time_mSec (
        .clk(clk),
        .reset(reset),
        .i_tick(tick_10Hz),
        .clear(clear),
        .o_time(msec),
        .o_tick(w_msec_tick)
    );

    timecounter #(.TICK(60), .BIT($clog2(60))) U_Time_Sec (
        .clk(clk),
        .reset(reset),
        .i_tick(w_msec_tick),
        .clear(clear),
        .o_time(sec),
        .o_tick(w_sec_tick)
    );

    timecounter #(.TICK(10), .BIT($clog2(10))) U_Time_Minute (
        .clk(clk),
        .reset(reset),
        .i_tick(w_sec_tick),
        .clear(clear),
        .o_time(minute),
        .o_tick()
    );

endmodule

module timecounter #(parameter TICK = 100, BIT = 7) (
    input                       clk,
    input                       reset,
    input                       i_tick,
    input                       clear,
    output  [BIT-1:0]           o_time,
    output                      o_tick
);
    reg [$clog2(TICK)-1:0]      count_reg, count_next;
    reg                         tick_reg, tick_next;

    assign                      o_time = count_reg;
    assign                      o_tick = tick_reg;

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
        tick_next = 0;
        if (clear == 1) begin
            count_next = 0;
        end else if (i_tick == 1) begin
            if (count_reg == TICK - 1) begin
                count_next = 0;
                tick_next = 1;
            end else begin
                count_next = count_reg + 1;
                tick_next = 0;
            end
        end
    end
    
    
endmodule

module clk_div_10 (
    input           clk,
    input           reset,
    input           run,
    input           clear,
    output          clk_10Hz
);

    parameter       COUNT = 10_000_000;
    reg             clk_reg, clk_next;
    reg [$clog2(COUNT)-1:0]     count_reg, count_next;

    assign          clk_10Hz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            clk_reg <= 0;
            count_reg <= 0;
        end else begin
            clk_reg <= clk_next;
            count_reg <= count_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        clk_next = 0;

        if (run == 1) begin
            if (count_reg == COUNT - 1) begin
                count_next = 0;
                clk_next = 1;
            end else begin
                count_next = count_reg + 1;
                clk_next = 0;
            end
        end else if (clear == 1) begin
            count_next = 0;
            clk_next = 0;
        end
    end
    
endmodule

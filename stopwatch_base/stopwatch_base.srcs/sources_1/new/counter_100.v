`timescale 1ns / 1ps

module counter_100(
    input       clk, reset,
    // input       [2:0] sw,
    input       btn_run_stop,
    input       btn_clear,
    output      [3:0] seg_comm,
    output      [7:0] seg
);
    wire        [13:0] w_count_msec;
    wire        w_clk_10, w_run_stop, w_clear;
    wire        w_tick_100Hz, o_btn_run_stop, o_btn_clear, w_tick_msec;

    tick_100hz U_Tick_100hz(
        .clk            (clk),
        .reset          (reset),
        .run_stop       (w_run_stop),
        .o_tick_100Hz   (w_tick_100Hz)
    );

    counter_tick #(
        .TICK_COUNT()
    )U_Counter_Tick_msec(  // msec
        .clk            (clk),
        .reset          (reset),
        .clear          (w_clear),
        .tick           (w_tick_100Hz),
        .counter        (w_count_msec),
        .o_tick         (w_tick_msec)
    );

    wire    w_count_sec;
    counter_tick #(
        .TICK_COUNT   ()
    ) U_Counter_Tick_sec(  // sec
        .clk            (clk),
        .reset          (reset),
        .clear          (w_clear),
        .tick           (w_tick_100Hz),
        .counter        (w_count_sec),
        .o_tick         ()
    );

    btn_debounce U_BTN_Debounce_RUNSTOP(
        .clk            (clk),
        .reset          (reset),
        .i_btn          (btn_run_stop), // from btn
        .o_btn          (o_btn_run_stop) // to control unit
    );

    btn_debounce U_BTN_Debounce_CLEAR(
        .clk            (clk),
        .reset          (reset),
        .i_btn          (btn_clear), // from btn
        .o_btn          (o_btn_clear) // to control unit
    );



    fnd_controller U_fnd_cntl(
        .clk            (clk),
        .reset          (reset),
        .sec            (w_count_sec),
        .msec           (w_count_msec),
        .seg            (seg),
        .seg_comm       (seg_comm)
    );

    control_unit U_Control_Unit(
        .clk            (clk),
        .reset          (reset),
        .i_run_stop     (o_btn_run_stop),
        .i_clear        (o_btn_clear),
        .o_run_stop     (w_run_stop),
        .o_clear        (w_clear)
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
            r_tick_100Hz <= 0;
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

module counter_tick #(parameter TICK_COUNT = 10_000)(
    input       clk, reset, tick, clear,
    output      [$clog2(TICK_COUNT) - 1:0] counter,
    output      o_tick
);

    //                                state        next
    reg         [$clog2(TICK_COUNT) - 1:0] counter_reg, counter_next;
    reg         r_tick;
    assign      counter = counter_reg;
    assign      o_tick = r_tick;

    // state
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else counter_reg <= counter_next;
    end

    // next
    always @(*) begin
        counter_next = counter_reg; // 초기화 하면 latch 제거됨
        r_tick = 1'b0;
        if (clear == 1'b1) begin
            counter_next = 0;
        end else if (tick == 1'b1) begin // tick count
            if (counter_reg == TICK_COUNT - 1) begin
                counter_next = 0;
                r_tick = 1'b1;
            end else begin
                counter_next = counter_reg + 1;
                r_tick = 1'b0;
            end
        end
    end
endmodule

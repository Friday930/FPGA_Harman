`timescale 1ns / 1ps

module Top_Upcounter (
    input       clk, reset,
    input       [2:0] sw,
    output      [3:0] seg_comm,
    output      [7:0] seg
);
    wire        [13:0] w_count;
    wire        w_clk_10, w_run_stop, w_clear;
    // assign      w_run_stop = clk & sw[0];
    // assign      w_clear = reset | sw[1];

    clk_div_10hz U_clk_div_10hz(
        .clk(clk),
        .reset(reset),
        .run_stop(w_run_stop),
        .o_clk_10hz(w_clk_10)
    );

    counter_10000 U_Counter_10000(
        .clk(w_clk_10),
        .reset(reset),
        .clear(w_clear),
        .count(w_count)
    );

    fnd_controller U_fnd_cntl(
        .clk(clk),
        .reset(reset),
        // .bcd(w_count),
        .seg(seg),
        .seg_comm(seg_comm)
    );

    control_unit U_Control_Unit(
        .clk(clk),
        .reset(reset),
        .i_run_stop(sw[0]),
        .i_clear(sw[1]),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );
endmodule

module clk_div_10hz (
    input       clk, reset, run_stop,
    output      o_clk_10hz
);

    reg         [$clog2(10_000_000) - 1:0] r_counter;
    reg         r_clk_10hz;

    assign      o_clk_10hz = r_clk_10hz;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            if(run_stop == 1'b1) begin
                if(r_counter == 10_000_000 - 1) begin
                    r_counter <= 0;
                    r_clk_10hz <= 1'b1;
                end else if(r_counter == (10_000_000/2)-1)begin // duty ratio 50%
                    r_clk_10hz <= 1'b0;
                    r_counter <= r_counter + 1;
                end else begin
                    r_counter <= r_counter + 1;
                end
            end else r_counter <= r_counter;
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

module control_unit (
    input       clk, reset,
    input       i_run_stop, i_clear,
    output      reg o_run_stop, o_clear
);

    parameter   STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;

    // state 관리
    reg         [2:0] state, next;

    // state sequencial logic (<=)
    always @(posedge clk, posedge reset) begin
        if(reset) state <= STOP;
        else state <= next;
    end

    // next combination logic (=)
    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (i_run_stop == 1'b1) begin
                    next = RUN;
                end else if (i_clear == 1'b1) begin
                    next = CLEAR;
                end else next = state;
            end

            RUN: begin
                if (i_run_stop == 1'b0) begin
                    next = STOP;
                end else next = state;
            end

            CLEAR: begin
                if (i_clear == 1'b0) begin
                    next = STOP;
                end else next = state;
            end
            default: next = state;
        endcase
    end
    
    // combinational output logic
    always @(*) begin
        case (state)
            STOP:   begin
                o_run_stop = 1'b1;
                o_clear = 1'b0;
            end
            RUN:    begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
            CLEAR:  begin
                o_run_stop = 1'b0;
                o_clear = 1'b1;
            end
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end
endmodule

module fsm (
    input       clk, reset, run_stop,
    output      o_clk
);
    
    
endmodule
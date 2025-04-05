`timescale 1ns / 1ps

interface accumulator_if;
    logic                       clk;
    logic                       rst;
    logic   [$clog2(55)-1:0]    out;
endinterface //accumulator_if

class transaction;
    rand    bit                 rst;
    bit     [$clog2(55)-1:0]    out;
endclass //transaction

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;

    function new(mailbox#(transaction) gen2drv_mbox);
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction //new()

    task run(int run_count);
        repeat  (run_count) begin
            tr = new();
            gen2drv_mbox.put(tr);
            #10;
        end
    endtask //
endclass //generator

class driver;
    transaction tr;
    virtual accumulator_if acc;
    mailbox #(transaction) gen2drv_mbox;

    function new(mailbox#(transaction) gen2drv_mbox, virtual accumulator_if acc);
        this.gen2drv_mbox = gen2drv_mbox;
        this.acc = acc;
    endfunction //new()

    task rst();
        acc.rst = 1;
        repeat(5) @(posedge acc.clk);
        acc.rst = 0;
    endtask 

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            acc.rst = tr.rst;
            @(posedge acc.clk);
            tr.out = acc.out;
        end
    endtask //
endclass //driver

class environment;
    generator gen;
    driver drv;
    mailbox #(transaction) gen2drv_mbox;

    function new(virtual accumulator_if acc);
        gen2drv_mbox = new();
        gen = new(gen2drv_mbox);
        drv = new(gen2drv_mbox, acc);
    endfunction //new()

    task run();
        drv.rst();
        fork
            gen.run(10);
            drv.run();
        join_any
        #10 $finish;
    endtask //

endclass //environment

module tb_dedicated_Processor();
    bit clk;
    always #5 clk = ~clk;

    environment env;
    accumulator_if acc();
    assign acc.clk = clk;

    top_Dedicated_Processor dut(
        .clk(acc.clk),
        .rst(acc.rst),
        .out(acc.out)
    );

    initial begin
        env = new(acc);
        env.run();
    end

endmodule



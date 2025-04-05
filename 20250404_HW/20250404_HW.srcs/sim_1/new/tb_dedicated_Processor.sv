`timescale 1ns / 1ps

interface accumulator;
    logic   [$clog2(10)-1:0]    a;
    logic   [$clog2(10)-1:0]    b;
    logic   [$clog2(55)-1:0]    sum;
    logic                       carry;
endinterface //accumulator

class transaction;
    bit     [$clog2(10)-1:0]    a;
    bit     [$clog2(10)-1:0]    b;
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
    virtual accumulator acc;
    mailbox #(transaction) gen2drv_mbox;

    function new(mailbox#(transaction) gen2drv_mbox, virtual accumulator acc);
        this.gen2drv_mbox = gen2drv_mbox;
        this.acc = acc;
    endfunction //new()

    task reset();
        acc.a = 0;
        acc.b = 0;
    endtask 

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            acc.a = tr.a;
            acc.b = tr.b;
        end
    endtask //
endclass //driver

module tb_dedicated_Processor(

    );
endmodule



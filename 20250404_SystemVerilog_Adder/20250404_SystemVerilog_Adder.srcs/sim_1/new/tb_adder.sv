`timescale 1ns / 1ps

interface adder_intf;
    logic   [7:0]       a; // logic type -> wire type + reg type
    logic   [7:0]       b;
    logic   [7:0]       sum;
    logic               carry;
endinterface //adder_intf

class transaction; // 집어넣고 싶은 값
    rand bit [7:0]       a; // bit -> X, Z가 없음 , rand -> 값 랜덤
    rand bit [7:0]       b;
endclass //transaction

class generator; // transaction에 넣을 값 생성
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;

    function new(mailbox#(transaction) gen2drv_mbox);
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction //new()

    task run(int run_count);
        repeat (run_count) begin
            tr = new();
            tr.randomize();
            gen2drv_mbox.put(tr);
            #10;
        end
    endtask //automatic
endclass //generator

class driver;
    transaction tr;
    virtual adder_intf adder_if; // adder_if -> 멤버 변수
    mailbox #(transaction) gen2drv_mbox;

    function new(mailbox#(transaction) gen2drv_mbox, virtual adder_intf adder_if); // adder_if -> 매개 변수
        this.gen2drv_mbox = gen2drv_mbox;
        this.adder_if = adder_if;
    endfunction //new()

    task reset();
        adder_if.a = 0;
        adder_if.b = 0;
    endtask //

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            adder_if.a = tr.a;
            adder_if.b = tr.b;
            #10;
        end
    endtask //

endclass //driver

class environment;
    generator gen;
    driver drv;
    mailbox #(transaction) gen2drv_mbox;

    function new(virtual adder_intf adder_if);
        gen2drv_mbox = new();
        gen = new(gen2drv_mbox);
        drv = new(gen2drv_mbox, adder_if);
    endfunction //new()

    task run();
        fork
            gen.run(10000); // 10000개 결과 출력됨
            drv.run();
        join_any
        #10 $finish;
    endtask //
endclass //environment


module tb_adder();

    environment env;
    adder_intf adder_if(); // real hardware

    adder dut(
        .a              (adder_if.a),
        .b              (adder_if.b),
        .sum            (adder_if.sum),
        .carry          (adder_if.carry)
    );

    initial begin
        env = new(adder_if);
        env.run();
    end

endmodule

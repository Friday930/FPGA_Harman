`timescale 1ns / 1ps

module mealy_tb;
    reg clk, reset, din_bit;
    wire dout_bit;

    // Mealy FSM 인스턴스화
    mealy uut (
        .clk(clk),
        .reset(reset),
        .din_bit(din_bit),
        .dout_bit(dout_bit)
    );

    // 클럭 생성 (주기 10ns)
    always #5 clk = ~clk;

    initial begin
        // 초기화
        clk = 0;
        reset = 1;
        din_bit = 0;
        #15 reset = 0; // 15ns 후 리셋 비활성화

        // 입력 시퀀스 (0110 패턴 포함)
        #10 din_bit = 0;
        #10 din_bit = 1;
        #10 din_bit = 1;
        #10 din_bit = 0; // "0110" -> detect_out이 1이어야 함
        #10 din_bit = 1;
        #10 din_bit = 0;
        #10 din_bit = 0;
        #10 din_bit = 1;
        #10 din_bit = 1;
        #10 din_bit = 0; // 다시 "0110" 입력
        #10 din_bit = 1;
        #10 din_bit = 1;
        #10 din_bit = 0;

        // 시뮬레이션 종료
        // #20 $finish;
    end

    // VCD 파일 생성 (파형 분석용)
    // initial begin
    //     $dumpfile("mealy_tb.vcd");
    //     $dumpvars(0, mealy_tb);
    // end
endmodule


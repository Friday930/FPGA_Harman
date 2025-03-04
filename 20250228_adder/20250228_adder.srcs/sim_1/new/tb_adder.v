`timescale 1ns / 1ps

module tb_adder();

    reg [3:0] a, b;
    wire [3:0] s;
    wire c;

    // uut, dut -> unit or design under test
    fa_4 dut(
        .a(a),
        .b(b),
        .s(s),
        .c(c)
    );

    integer i;
    initial begin
        a = 4'h0; b = 4'h0;
        #10;
        for(i = 0; i < 16; i = i + 1) begin
            a = i;
            #10;
        end
        #10;
        $stop;
    end

endmodule

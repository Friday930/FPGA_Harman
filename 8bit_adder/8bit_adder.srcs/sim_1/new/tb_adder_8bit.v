`timescale 1ns / 1ps


module tb_adder_8bit();

    reg [7:0] a, b;
    wire [7:0] s;
    wire c;

    // uut, dut -> unit or design under test
    fa_8 dut(
        .a(a),
        .b(b),
        .s(s),
        .c(c)
    );

    integer i;
    integer j;
    initial begin
        a = 8'h0; b = 8'h0;
        #10;
        for(i = 0; i < 256; i = i + 1) begin
            
            for(j = 0; j < 256; j = j + 1) begin
                a=i;
                b=j;
                #10;
            end
            #10;
        end
        #10;
        $stop;
    end

endmodule

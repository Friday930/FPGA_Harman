`timescale 1ns / 1ps

module tb_4bit_adder();
    reg [3:0] a;
    reg [3:0] b;
    reg cin;
    wire [3:0] s;
    wire [3:0] c; // wire 연결용
    
    full_adder_4bit u_full_adder_4bit( // module 인스턴스 화(실체화)
        .a(a),
        .b(b),
        .cin(cin), // input carry
        .s(s),
        .c(c)
    );
    
    initial
    begin
        #10;    a = 4'b0000; b = 4'b0000; cin = 0;
        #10;    a = 4'b0000; b = 4'b0010; cin = 1;
        #10;    a = 4'b1000; b = 4'b1010; cin = 0;
        
        
    end

endmodule

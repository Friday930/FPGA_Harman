`timescale 1ns / 1ps
module tb_adder();

    reg a, b, cin; // reg 저장하다
    wire s, c; // wire 연결용
    
    full_adder u_full_adder( // module 인스턴스 화(실체화)
        .a(a),
        .b(b),
        .cin(cin), // input carry
        .s(s),
        .c(c)
    );
    
    initial
    begin
        #10;    a = 0; b = 0; cin = 0;
        #10;    a = 0; b = 1; cin = 0;
        #10;    a = 1; b = 0; cin = 0;
        #10;    a = 1; b = 1; cin = 0;
        #10;    a = 0; b = 0; cin = 1;
        #10;    a = 0; b = 1; cin = 1;
        #10;    a = 1; b = 0; cin = 1;
        #10;    a = 1; b = 1; cin = 1;
    end
    

endmodule

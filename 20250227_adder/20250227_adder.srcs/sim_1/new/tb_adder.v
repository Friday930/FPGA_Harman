`timescale 1ns / 1ps
module tb_adder();

    reg a, b, cin; // reg �����ϴ�
    wire s, c; // wire �����
    
    full_adder u_full_adder( // module �ν��Ͻ� ȭ(��üȭ)
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

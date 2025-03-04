`timescale 1ns / 1ps
module half_adder(
    input a,
    input b,
    output s,
    output c
);
    
    // 1bit half adder
    assign s = a ^ b;
    assign c = a & b;

endmodule

// 1bit Full adder
module full_adder(
    input a,
    input b, 
    input cin,
    output s, 
    output c
);
    wire w_s; // wiring U_HA1 out s to U_HA2 in a
    wire w_c1, w_c2;
    assign c = w_c1 | w_c2;
    
    half_adder U_HA1(
        .a(a),
        .b(b),
        .s(w_s),
        .c(w_c1)
    );
    
    half_adder U_HA2(
        .a(w_s), // from U_HA1 of s
        .b(cin),
        .s(s),
        .c(w_c2)
    );
    
endmodule

module full_adder_4bit(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] s,
    output [3:0] c,
    output cout
    );
    
    wire c1, c2, c3;
    
    
    full_adder U_FA1(
        .a(a[0]),
        .b(b[0]),
        .s(s[0]),
        .cin(cin),
        .c(c[0])
    );
    full_adder U_FA2(
        .a(a[1]),
        .b(b[1]),
        .s(s[1]),
        .c(c[1]),
        .cin(c[0])
    );
    full_adder U_FA3(
        .a(a[2]),
        .b(b[2]),
        .s(s[2]),
        .c(c[2]),
        .cin(c[1])
    );
    full_adder U_FA4(
        .a(a[3]),
        .b(b[3]),
        .s(s[3]),
        .c(c[3]),
        .cin(c[2])
    );
    
    
endmodule

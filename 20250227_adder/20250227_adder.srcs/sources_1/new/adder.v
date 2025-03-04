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
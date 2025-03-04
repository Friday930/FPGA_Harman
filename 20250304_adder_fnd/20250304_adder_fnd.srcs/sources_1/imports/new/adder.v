`timescale 1ns / 1ps

// module adder(

//     );
// endmodule

module half_adder (
    input a, b, // 1bit wire
    output sum, c
);
    // assign sum = a ^ b;
    // assign c = a & b;

    // 게이트 프리미티브 -> 기본 Verilog lib
    xor (sum, a, b); // (output, input 0 , input 1, input 2, ...)
    and (c, a, b);
endmodule

module full_adder (
    input a, b, cin,
    output sum, c
);
    wire w_s, w_c1, w_c2;
    assign c = w_c1 | w_c2;

    half_adder U_ha1(
        .a(a),
        .b(b),
        .sum(w_s),
        .c(w_c1)
    );
    half_adder U_ha2(
        .a(w_s),
        .b(cin),
        .sum(sum),
        .c(w_c2)
    );
endmodule

module fa_4 (
    input [3:0] a, // 4bit vector
    input [3:0] b,
    // input cin,
    output [3:0] s,
    output c
);

    wire [3:0] w_c;
    

    full_adder U_fa0(
        .a(a[0]),
        .b(b[0]),
        .cin(1'b0),
        .sum(s[0]),
        .c(w_c[0])
    );
    full_adder U_fa1(
        .a(a[1]),
        .b(b[1]),
        .cin(w_c[0]),
        .sum(s[1]),
        .c(w_c[1])
    );
    full_adder U_fa2(
        .a(a[2]),
        .b(b[2]),
        .cin(w_c[1]),
        .sum(s[2]),
        .c(w_c[2])
    );
    full_adder U_fa3(
        .a(a[3]),
        .b(b[3]),
        .cin(w_c[2]),
        .sum(s[3]),
        .c(c)
    );
endmodule

module adder_8 (
    input [7:0] a, b,
    output [7:0] sum,
    output carry
);
    wire w_c;
    fa_4 U_fa_4_lower(
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .s(sum[3:0]),
        .c(w_c)
    );
    fa_4 U_fa_4_upper(
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(w_c),
        .s(sum[7:4]),
        .c(carry)
    );
    
endmodule

module calculator (
    input [3:0] a, b,
    input [1:0] btn,
    output [7:0] seg,
    output [3:0] seg_comm,
    output c_led
);
    wire [3:0] w_sum;
    fnd_controller U_fnd_ctrl(
        .bcd(w_sum),
        .seg_sel(btn),
        .seg(seg),
        .seg_comm(seg_comm)
    );
    fa_4 U_fa4(
        .a(a),
        .b(b),
        .s(w_sum),
        .c(c_led)
    );
    
endmodule
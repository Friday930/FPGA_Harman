`timescale 1ns / 1ps

// module fndController(
//     input               clk,
//     input               reset,
//     input   [13:0]      fndData,
//     output  [3:0]       fndCom,
//     output  [7:0]       fndFont
//     );

//     wire                tick;
//     wire    [1:0]       digit_sel;
//     wire    [3:0]       digit_1, digit_10, digit_100, digit_1000, digit;
//     wire                w_dot_tick, w_dot_state;
//     clk_div_1khz U_Clk_Div_1kHz(
//         .clk            (clk),
//         .reset          (reset),
//         .tick           (tick)
//     );

//     counter_2bit U_Counter_2bit(
//         .clk            (clk),
//         .reset          (reset),
//         .tick           (tick),
//         .count          (digit_sel)
//     );

//     decoder_2x4 U_Dec_2x4(
//         .x              (digit_sel),
//         .y              (fndCom)
//     );

//     digitSplitter U_Digit_Splitter(
//         .fndData        (fndData),
//         .digit_1        (digit_1),
//         .digit_10       (digit_10),
//         .digit_100      (digit_100),
//         .digit_1000     (digit_1000)
//     );

//     mux_4x1 U_Mux_4x1(
//         .sel            (digit_sel),
//         .x0             (digit_1),
//         .x1             (digit_10),
//         .x2             (digit_100),
//         .x3             (digit_1000),
//         .y              (digit)
//     );  

//     clk_div_dot U_Clk_dot(
//         .clk(clk),
//         .reset(reset),
//         .dot_tick(w_dot_tick),
//         .dot_state(w_dot_state)
//     );

//     bcdtoseg U_BCDtoSEG(
//         .bcd            (digit),
//         .dot_state            (w_dot_state),
//         .digit_sel            (digit_sel),
//         .segment            (fndFont)
//     );

// endmodule

// module clk_div_1khz (
//     input   wire        clk,
//     input   wire        reset,
//     output  reg         tick
// );
//     reg [$clog2(100_000)-1:0]    div_counter;   
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             div_counter <= 0;
//             tick <= 1'b0;
//         end else begin
//             if (div_counter == 100_000 - 1) begin
//                 div_counter <= 0;
//                 tick <= 1'b1;
//             end else begin
//                 div_counter <= div_counter + 1;
//                 tick <= 0;
//             end
//         end
//     end
// endmodule

// module clk_div_dot (
//     input   wire        clk,
//     input   wire        reset,
//     output  reg         dot_tick,
//     output  reg         dot_state
// );
//     // 100MHz 기준, 50,000,000 카운트하면 0.5초
//     reg [24:0]          dot_counter;   
    
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             dot_counter <= 0;
//             dot_tick <= 1'b0;
//             dot_state <= 1'b0;
//         end else begin
//             if (dot_counter == 50_000_000 - 1) begin
//                 dot_counter <= 0;
//                 dot_tick <= 1'b1;
//                 dot_state <= ~dot_state; // 0.5초마다 상태 반전
//             end else begin
//                 dot_counter <= dot_counter + 1;
//                 dot_tick <= 1'b0;
//             end
//         end
//     end
// endmodule

// module counter_2bit (
//     input               clk,
//     input               reset,
//     input               tick,
//     output  reg [1:0]   count
// );
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             count <= 0;
//         end else begin
//             if (tick) begin
//                 count <= count + 1;
//             end
//         end
//     end
// endmodule

// module decoder_2x4 (
//     input   [1:0]           x,
//     output  reg [3:0]       y
// );

//     always @(*) begin
//         y = 4'b1111;
//         case (x)
//             3'b000 : y = 4'b1110;
//             3'b001 : y = 4'b1101;
//             3'b010 : y = 4'b1011;
//             3'b011 : y = 4'b0111;
//             3'b100 : y = 4'b1110;
//             3'b101 : y = 4'b1101;
//             3'b110 : y = 4'b1011;
//             3'b111 : y = 4'b0111; 
//         endcase
//     end
    
// endmodule

// module digitSplitter (
//     input   [13:0]          fndData,
//     output  [3:0]           digit_1,
//     output  [3:0]           digit_10,
//     output  [3:0]           digit_100,
//     output  [3:0]           digit_1000
// );  
//     assign                  digit_1 = fndData % 10;
//     assign                  digit_10 = fndData / 10 % 10;
//     assign                  digit_100 = fndData / 100 % 10;
//     assign                  digit_1000 = fndData / 1000 % 10;
// endmodule

// module mux_4x1 (
//     input       [1:0]       sel,
//     input       [3:0]       x0,
//     input       [3:0]       x1,
//     input       [3:0]       x2,
//     input       [3:0]       x3,
//     output  reg [3:0]       y
// );
//     always @(*) begin
//         y = 4'b0000;
//         case (sel)
//             2'b000: y = x0; 
//             2'b001: y = x1;
//             2'b010: y = x2;
//             2'b011: y = x3;
//         endcase
//     end
// endmodule

// module bcdtoseg (
//     input           [3:0] bcd,
//     input                 dot_state,  // 0.5초마다 변경되는 점 상태
//     input           [1:0] digit_sel,  // 현재 표시 중인 자리
//     output          reg [7:0] segment
// );
//     reg [7:0] seg;
    
//     // 7-segment 디코딩 (dot 제외)
//     always @(*) begin
//         case (bcd)
//             4'h0: seg = 8'hc0;
//             4'h1: seg = 8'hf9;
//             4'h2: seg = 8'ha4;
//             4'h3: seg = 8'hb0;
//             4'h4: seg = 8'h99;
//             4'h5: seg = 8'h92;
//             4'h6: seg = 8'h82;
//             4'h7: seg = 8'hf8;
//             4'h8: seg = 8'h80;
//             4'h9: seg = 8'h90;
//             4'ha: seg = 8'h88;
//             4'hb: seg = 8'h83;
//             4'hc: seg = 8'hc6;
//             4'hd: seg = 8'ha1;
//             4'he: seg = 8'h7f; // dot
//             // 4'hf: seg = 8'h8e;
//             4'hf: seg = 8'hff;
//             default: seg = 8'hff;
//         endcase
        

//         if (digit_sel == 2'b01 && dot_state)
//             segment = {1'b0, seg}; // 점 켜기
//         else
//             segment = {1'b1, seg}; // 점 끄기
//     end
// endmodule
module fndController(
    input               clk,
    input               reset,
    input   [13:0]      fndData,
    output  [3:0]       fndCom,
    output  [7:0]       fndFont
    );

    wire                tick;          // 1kHz tick
    wire                dot_tick;      // 0.5초 주기 tick (2Hz)
    wire    [1:0]       digit_sel;
    wire    [3:0]       digit_1, digit_10, digit_100, digit_1000, digit;
    wire                dot_state;     // 현재 점의 상태 (켜짐/꺼짐)
   
    
    // 1kHz 클럭 생성
    clk_div_1khz U_Clk_Div_1kHz(
        .clk            (clk),
        .reset          (reset),
        .tick           (tick)
    );
    
    // 0.5초 주기(2Hz) 생성기 추가
    // clk_div_dot U_Clk_Div_Dot(
    //     .clk            (clk),
    //     .reset          (reset),
    //     .dot_tick       (dot_tick),
    //     .dot_state      (dot_state)
    // );

    counter_2bit U_Counter_2bit(
        .clk            (clk),
        .reset          (reset),
        .tick           (tick),
        .count          (digit_sel)
    );

    decoder_2x4 U_Dec_2x4(
        .x              (digit_sel), 
        .y              (fndCom)
    );

    digitSplitter U_Digit_Splitter(
        .fndData        (fndData),
        .digit_1        (digit_1),
        .digit_10       (digit_10),
        .digit_100      (digit_100),
        .digit_1000     (digit_1000)
    );

    mux_4x1 U_Mux_4x1(
        .sel            (digit_sel),
        .x0             (digit_1),
        .x1             (digit_10),
        .x2             (digit_100),
        .x3             (digit_1000),
        .y              (digit)
    );  

    bcdtoseg U_BCDtoSEG(
        .bcd            (digit),
        .digit_1        (digit_1), 
        .digit_sel      (digit_sel),   // 현재 선택된 자릿수
        .seg            (fndFont)
    );

endmodule

module clk_div_1khz (
    input   wire        clk,
    input   wire        reset,
    output  reg         tick
);
    reg [$clog2(100_000)-1:0]    div_counter;   
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (div_counter == 100_000 - 1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                tick <= 0;
            end
        end
    end
endmodule

// 0.5초 주기(2Hz)의 클럭 분주기 추가
module clk_div_dot (
    input   wire        clk,
    input   wire        reset,
    output  reg         dot_tick,
    output  reg         dot_state
);
    // 50MHz 기준, 25,000,000 카운트하면 0.5초
    reg [24:0]          dot_counter;   
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            dot_counter <= 0;
            dot_tick <= 1'b0;
            dot_state <= 1'b0;
        end else begin
            if (dot_counter == 50_000_000 - 1) begin
                dot_counter <= 0;
                dot_tick <= 1'b1;
                dot_state <= ~dot_state; // 0.5초마다 상태 반전
            end else begin
                dot_counter <= dot_counter + 1;
                dot_tick <= 1'b0;
            end
        end
    end
endmodule

module counter_2bit (
    input               clk,
    input               reset,
    input               tick,
    output  reg [1:0]   count
);
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            if (tick) begin
                count <= count + 1;
            end
        end
    end
endmodule

module decoder_2x4 (
    input   [1:0]           x,
    output  reg [3:0]       y
);

    always @(*) begin
        y = 4'b1111;
        case (x)
            2'b00 : y = 4'b1110;
            2'b01 : y = 4'b1101;
            2'b10 : y = 4'b1011;
            2'b11 : y = 4'b0111;
        endcase
    end
    
endmodule

module digitSplitter (
    input   [13:0]          fndData,
    output  [3:0]           digit_1,
    output  [3:0]           digit_10,
    output  [3:0]           digit_100,
    output  [3:0]           digit_1000
);  
    assign                  digit_1 = fndData % 10;
    assign                  digit_10 = fndData / 10 % 10;
    assign                  digit_100 = fndData / 100 % 10;
    assign                  digit_1000 = fndData / 1000 % 10;
endmodule

module mux_4x1 (
    input       [1:0]       sel,
    input       [3:0]       x0,
    input       [3:0]       x1,
    input       [3:0]       x2,
    input       [3:0]       x3,
    output  reg [3:0]       y
);
    always @(*) begin
        y = 4'b0000;
        case (sel)
            2'b00: y = x0; 
            2'b01: y = x1;
            2'b10: y = x2;
            2'b11: y = x3;
            default: y = 4'b0000;
        endcase
    end
endmodule

module bcdtoseg (
    input           [3:0] bcd,
    input           [3:0] digit_1,  
    input           [1:0] digit_sel,  // 현재 표시 중인 자리
    output          reg [7:0] seg
);
    reg [6:0] segments;
    
    // 7-segment 디코딩 (dot 제외)
    always @(*) begin
        case (bcd)
            4'h0: segments = 7'b1000000; // 0
            4'h1: segments = 7'b1111001; // 1
            4'h2: segments = 7'b0100100; // 2
            4'h3: segments = 7'b0110000; // 3
            4'h4: segments = 7'b0011001; // 4
            4'h5: segments = 7'b0010010; // 5
            4'h6: segments = 7'b0000010; // 6
            4'h7: segments = 7'b1111000; // 7
            4'h8: segments = 7'b0000000; // 8
            4'h9: segments = 7'b0010000; // 9
            4'ha: segments = 7'b0001000; // A
            4'hb: segments = 7'b0000011; // b
            4'hc: segments = 7'b1000110; // C
            4'hd: segments = 7'b0100001; // d
            4'he: segments = 7'b0000110; // E
            4'hf: segments = 7'b1111111; // 표시 없음
            default: segments = 7'b1111111;
        endcase
        
        // 특정 자릿수에서만 점을 깜빡이게 함 (여기서는 10의 자리)
        if (digit_sel == 2'b01 && digit_1 <= 4)
            seg = {1'b0, segments}; // 점 켜기
        else
            seg = {1'b1, segments}; // 점 끄기
    end
endmodule
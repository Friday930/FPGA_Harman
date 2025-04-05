`timescale 1ns / 1ps

// module control_unit(
//     input           clk,
//     input           reset,
//     input           sw1,
//     input           sw2,
//     output          run_stop,
//     output          clear,
//     output reg      echo
//     );

//     parameter       STOP = 0, RUN = 1, CLEAR = 2;

//     reg [1:0]       state, next;
//     reg             r, c;

//     assign          sw1_inv = ~sw1;
//     assign          run_stop = r;
//     assign          clear = c;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             state <= 0;
//             echo <= 0;
//         end else begin
//             state <= next;

//             if (sw1_inv || sw2) begin
//                 echo <= 1;
//             end else echo <= 0;
//         end
//     end

//     always @(*) begin
//         next = state;
//         case (state)
//             STOP: begin
//                 if (sw1_inv == 1) begin
//                     next = RUN;
//                 end else if (sw2 == 1) begin
//                     next = CLEAR;
//                 end
//             end 
//             RUN: begin
//                 if (sw1_inv == 0) begin
//                     next = STOP;
//                 end else if (sw2 == 1) begin
//                     next = CLEAR;
//                 end
//             end
//             CLEAR: begin
//                 if (sw2 == 1) begin
//                     next = STOP;
//                 end else next = RUN;
//             end
//         endcase
//     end

//     always @(*) begin
//         r = 0;
//         c = 0;
//         case (state)
//             STOP: begin
//                 r = 0;
//                 c = 0;
//             end
//             RUN: begin
//                 r = 1;
//                 c = 0;
//             end
//             CLEAR: begin
//                 // r = 0;
//                 c = 1;
//             end
//         endcase
//     end

// endmodule

module control_unit(
    input           clk,
    input           reset,
    input           sw1,        // UART에서 받은 run 명령
    input           sw2,        // UART에서 받은 clear 명령
    output          run_stop,
    output          clear,
    output reg      echo        // echo 신호 추가
    );

    parameter       STOP = 0, RUN = 1, CLEAR = 2;

    reg [1:0]       state, next;
    reg             r, c;
    reg             sw1_prev, sw2_prev;  // 이전 입력 상태 저장

    assign          sw1_inv = ~sw1;      // 기존 코드 유지
    assign          run_stop = r;
    assign          clear = c;

    // 상태 및 이전 입력 업데이트, echo 생성
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
            sw1_prev <= 0;
            sw2_prev <= 0;
            echo <= 0;
        end else begin
            state <= next;
            sw1_prev <= sw1;     // 현재 입력 저장
            sw2_prev <= sw2;
            
            // 입력 변화 감지시 echo 신호 생성
            if ((sw1 == 1 && sw1_prev == 0) || (sw2 == 1 && sw2_prev == 0)) begin
                echo <= 1;  // 명령 감지시 echo 활성화
            end else begin
                echo <= 0;  // 그 외에는 echo 비활성화
            end
        end
    end

    // 다음 상태 결정 로직
    always @(*) begin
        next = state;
        
        // 입력이 0->1로 변할 때만 상태 변화 감지 (엣지 검출)
        case (state)
            STOP: begin
                if (sw1 == 1 && sw1_prev == 0) begin  // run 명령 상승 엣지
                    next = RUN;
                end else if (sw2 == 1 && sw2_prev == 0) begin  // clear 명령 상승 엣지
                    next = CLEAR;
                end
            end 
            RUN: begin
                if (sw1 == 1 && sw1_prev == 0) begin  // run 명령 상승 엣지
                    next = STOP;
                end else if (sw2 == 1 && sw2_prev == 0) begin  // clear 명령 상승 엣지
                    next = CLEAR;
                end
            end
            CLEAR: begin
                // CLEAR 상태에서는 짧은 시간 후 자동으로 STOP으로 돌아감
                next = STOP;
            end
        endcase
    end

    // 출력 생성 로직 - 변경 없음
    always @(*) begin
        r = 0;
        c = 0;
        case (state)
            STOP: begin
                r = 0;
                c = 0;
            end
            RUN: begin
                r = 1;
                c = 0;
            end
            CLEAR: begin
                // r = 0;  // 원래 주석 처리된 코드 유지
                c = 1;
            end
        endcase
    end

endmodule
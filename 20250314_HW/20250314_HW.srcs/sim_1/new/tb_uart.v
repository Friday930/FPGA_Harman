// `timescale 1ns / 1ps

// module tb_send_tx_btn();
//     // 테스트 신호 선언
//     reg         clk;
//     reg         rst;
//     reg         btn_start;
//     wire        tx;
    
//     // DUT 인스턴스화
//     send_tx_btn DUT (
//         .clk        (clk),
//         .rst        (rst),
//         .btn_start  (btn_start),
//         .tx         (tx)
//     );
    
//     // 클럭 생성 (100MHz 기준: 주기 10ns)
//     always #5 clk = ~clk;

    
//     // 디버깅용 내부 신호 모니터링
//     wire [7:0] current_data = DUT.send_tx_data_reg;
//     wire btn_debounced = DUT.w_start;
//     wire tx_done = DUT.w_tx_done;
    
//     // 테스트 시나리오
//     initial begin
//         // 초기화
//         clk = 0;
//         rst = 1;
//         btn_start = 0;
        
//         // 리셋 해제
//         #100 rst = 0;
        
//         // 버튼 누름 시뮬레이션 (5번 버튼 누름)
//         repeat (5) begin
//             // 버튼 누름
//             #1000 btn_start = 1;
//             #20000 btn_start = 0;  // 디바운스 회로를 통과할 충분한 시간
            
//             // 전송 완료 대기
//             wait(tx_done);
//             wait(!tx_done);
            
//             // 다음 버튼 누름 전에 충분한 간격
//             #50000;
//         end
        
//         // 시뮬레이션 종료
//         #100000 $finish;
//     end

// endmodule

`timescale 1ns / 1ps

module tb_send_tx_btn();
    // 테스트 신호 선언
    reg         clk;
    reg         rst;
    reg         btn_start;
    wire        tx;
    
    // 디바운스 출력 신호 직접 제어를 위한 내부 신호
    reg         force_debounced_btn;
    
    
    // 테스트 모듈 (시뮬레이션 용)
    module send_tx_btn_test(
        input               clk,
        input               rst,
        input               btn_start,
        input               force_debounced,  // 테스트용 강제 디바운스 신호
        output              tx
    );
        wire                w_start, w_tx_done;
        reg                 [7:0] send_tx_data_reg, send_tx_data_next;

        // 테스트를 위해 디바운스 회로를 우회하고 직접 강제 신호 사용
        assign w_start = force_debounced;

        top_uart U_UART(
            .clk            (clk),
            .rst            (rst),
            .btn_start      (w_start),
            .tx_data_in     (send_tx_data_reg),
            .tx             (tx),
            .tx_done        (w_tx_done)
        );  

        always @(posedge clk, posedge rst) begin
           if (rst) begin
                send_tx_data_reg <= 8'h30; // "0"
           end else begin
                send_tx_data_reg <= send_tx_data_next;
           end
        end

        always @(*) begin
            send_tx_data_next = send_tx_data_reg;
            if (w_start == 1'b1) begin // from debounce
                if (send_tx_data_reg == "z") begin
                    send_tx_data_next = "0";
                end else send_tx_data_next = send_tx_data_reg + 1; // ASCII code value increase 1 
            end
        end
    endmodule
    
    // 수정된 테스트용 모듈 인스턴스화
    send_tx_btn_test DUT (
        .clk            (clk),
        .rst            (rst),
        .btn_start      (btn_start),
        .tx             (tx),
        .force_debounced(force_debounced_btn)
    );
    // 클럭 생성 (100MHz 기준: 주기 10ns)
    always #5 clk = ~clk;
    
    // 디버깅용 내부 신호 모니터링
    wire [7:0] current_data = DUT.send_tx_data_reg;
    wire btn_debounced = DUT.w_start;
    wire tx_done = DUT.w_tx_done;
    
    // 테스트 시나리오
    initial begin
        // 초기화
        clk = 0;
        rst = 1;
        btn_start = 0;
        force_debounced_btn = 0;
        
        // 리셋 해제
        #100 rst = 0;
        
        // 버튼 누름 시뮬레이션 (5번 버튼 누름)
        repeat (5) begin
            // 버튼 누름 (물리적 버튼)
            #1000 btn_start = 1;
            
            // 디바운스 신호 강제 활성화 (실제 디바운스 회로 우회)
            #200 force_debounced_btn = 1;
            #200 force_debounced_btn = 0;
            
            // 버튼 해제
            #1000 btn_start = 0;
            
            // 전송 완료 대기
            wait(tx_done);
            wait(!tx_done);
            
            // 다음 버튼 누름 전에 충분한 간격
            #10000;
        end
        
        // 시뮬레이션 종료
        #20000 $finish;
    end


endmodule
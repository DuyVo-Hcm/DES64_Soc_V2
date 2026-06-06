`timescale 1ns / 1ps

module DES_STREAM_AVALON
(
    input wire clk,
    input wire reset_n,

    //=========================
    // Avalon-ST Sink
    //=========================
    input  wire [31:0] sink_data,
    input  wire        sink_valid,
    input  wire        sink_startofpacket,
    input  wire        sink_endofpacket,
    output wire        sink_ready,

    //=========================
    // Avalon-ST Source
    //=========================
    output wire [31:0] source_data,
    output wire        source_valid,
    output wire        source_startofpacket,
    output wire        source_endofpacket,
    input  wire        source_ready
);

    //====================================================
    // DES INTERFACE SIGNALS
    //====================================================
    reg [63:0] plaintext_reg;
    reg [63:0] key_reg;
    reg start_reg;

    wire [63:0] ciphertext;
    wire done;

    // Mạch bắt cạnh lên cho cờ done
    reg done_delay;
    always @(posedge clk or negedge reset_n)
    begin
        if(!reset_n)
            done_delay <= 1'b0;
        else
            done_delay <= done;
    end
    wire done_pulse = done && (!done_delay);

    //====================================================
    // [FIX VÀNG]: MẠCH GIỮ TRẠNG THÁI ĐANG CHẠY CỦA CORE DES
    //====================================================
    reg des_running;
    always @(posedge clk or negedge reset_n)
    begin
        if(!reset_n)
            des_running <= 1'b0;
        else if(start_reg)
            des_running <= 1'b1;  // Bật khi bắt đầu chạy
        else if(done_pulse)
            des_running <= 1'b0;  // Tắt khi đã xong
    end

    //====================================================
    // RECEIVE LOGIC (THẮT CHẶT QUY TRÌNH BẮT TAY)
    //====================================================
    reg [2:0] rx_count;
    reg        packet_ready;

    // Khóa busy bắt buộc phải giữ mức 1 trong suốt quá trình Core đang chạy tính toán
    wire busy = packet_ready || start_reg || des_running || output_pending;
    assign sink_ready = !busy;

    wire sink_accept = sink_valid && sink_ready;

    //====================================================
    // TRANSMIT LOGIC
    //====================================================
    reg [63:0] cipher_buffer;
    reg [1:0] tx_count;
    reg        output_pending;

    assign source_valid = output_pending;
    assign source_data = (tx_count == 0) ? cipher_buffer[63:32] : cipher_buffer[31:0];
    assign source_startofpacket = (tx_count == 0);
    assign source_endofpacket   = (tx_count == 1);

    wire source_accept = source_valid && source_ready;

    //====================================================
    // MAIN FSM CONTROL
    //====================================================
    always @(posedge clk or negedge reset_n)
    begin
        if(!reset_n)
        begin
            plaintext_reg  <= 64'd0;
            key_reg        <= 64'd0;
            rx_count       <= 3'd0;
            packet_ready   <= 1'b0;
            start_reg      <= 1'b0;
            cipher_buffer  <= 64'd0;
            tx_count       <= 2'd0;
            output_pending <= 1'b0;
        end
        else
        begin
            // Mặc định xung Start chỉ rộng đúng 1 chu kỳ clock
            start_reg <= 1'b0;

            // Nhận dữ liệu từ Sink Stream
            if(sink_accept)
            begin
                if(sink_startofpacket) 
                begin
                    // Ngay khi có gói tin mới (SOP), ép cứng Word 0 và đẩy count lên 1
                    plaintext_reg[63:32] <= sink_data;
                    rx_count <= 3'd1; 
                end
                else 
                begin
                    // Các Word tiếp theo chạy bình thường
                    case(rx_count)
                        3'd1: plaintext_reg[31:0]  <= sink_data;
                        3'd2: key_reg[63:32]       <= sink_data;
                        3'd3: begin
                            key_reg[31:0] <= sink_data;
                            packet_ready  <= 1'b1; // Đủ 4 Word -> Kích hoạt Core
                        end
                    endcase
                    rx_count <= rx_count + 1'b1;
                end
            end

            // Kích hoạt lõi DES mã hóa
            if(packet_ready)
            begin
                start_reg    <= 1'b1;
                packet_ready <= 1'b0;
            end

            // Khi DES hoàn thành tính toán, chốt dữ liệu vào bộ đệm nguồn
            if(done_pulse)
            begin
                cipher_buffer  <= ciphertext;
                output_pending <= 1'b1;
                tx_count       <= 2'd0;
            end

            // Đẩy dữ liệu ra Source Stream
            if(source_accept)
            begin
                if(tx_count == 1)
                begin
                    output_pending <= 1'b0;
                    tx_count       <= 2'd0;
                end
                else
                begin
                    tx_count <= tx_count + 1'b1;
                end
            end
        end
    end

    //====================================================
    // KHỞI TẠO LÕI DES CORE
    //====================================================
    DES_TOP U_DES
    (
        .CLK        (clk),
        .Resetn     (reset_n),
        .Start      (start_reg),
        .Plaintext  (plaintext_reg),
        .Key        (key_reg),
        .Ciphertext (ciphertext),
        .done       (done)
    );

endmodule
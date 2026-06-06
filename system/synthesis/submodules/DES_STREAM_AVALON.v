module DES_STREAM_AVALON
(
    input wire clk,
    input wire reset_n,

    //=========================
    // Avalon-ST Sink
    //=========================
    input wire [31:0] sink_data,
    input wire sink_valid,
    input wire sink_startofpacket,
    input wire sink_endofpacket,
    output wire sink_ready,

    //=========================
    // Avalon-ST Source
    //=========================
    output wire [31:0] source_data,
    output wire source_valid,
    output wire source_startofpacket,
    output wire source_endofpacket,
    input wire source_ready
);

    //========================================
    // DES signals
    //========================================

    reg [63:0] plaintext_reg;
    reg [63:0] key_reg;

    reg start_reg;

    wire [63:0] ciphertext;
    wire done;

    //========================================
    // Receive packet
    //
    // word0 = PT_H
    // word1 = PT_L
    // word2 = KEY_H
    // word3 = KEY_L
    //========================================

    reg [2:0] rx_count;
    reg packet_ready;

    assign sink_ready =
        !packet_ready &&
        !start_reg;

    wire sink_accept =
        sink_valid &&
        sink_ready;

    //========================================
    // Transmit packet
    //
    // word0 = CT_H
    // word1 = CT_L
    //========================================

    reg [63:0] cipher_buffer;

    reg [1:0] tx_count;
    reg output_pending;

    assign source_valid = output_pending;

    assign source_data =
        (tx_count == 0)
        ? cipher_buffer[63:32]
        : cipher_buffer[31:0];

    assign source_startofpacket =
        (tx_count == 0);

    assign source_endofpacket =
        (tx_count == 1);

    wire source_accept =
        source_valid &&
        source_ready;

    //========================================
    // Main FSM
    //========================================

    always @(posedge clk or negedge reset_n)
    begin

        if(!reset_n)
        begin

            plaintext_reg <= 64'd0;
            key_reg <= 64'd0;

            rx_count <= 0;

            packet_ready <= 0;

            start_reg <= 0;

            cipher_buffer <= 64'd0;

            tx_count <= 0;
            output_pending <= 0;

        end
        else
        begin

            //---------------------------------
            // default
            //---------------------------------

            if(done)
                start_reg <= 0;

            //---------------------------------
            // receive input stream
            //---------------------------------

            if(sink_accept)
            begin

                if(sink_startofpacket)
                    rx_count <= 0;

                case(rx_count)

                    3'd0:
                        plaintext_reg[63:32]
                            <= sink_data;

                    3'd1:
                        plaintext_reg[31:0]
                            <= sink_data;

                    3'd2:
                        key_reg[63:32]
                            <= sink_data;

                    3'd3:
                    begin

                        key_reg[31:0]
                            <= sink_data;

                        packet_ready <= 1'b1;

                    end

                endcase

                rx_count <= rx_count + 1'b1;

            end

            //---------------------------------
            // start DES
            //---------------------------------

            if(packet_ready && !start_reg)
            begin

                start_reg <= 1'b1;

                packet_ready <= 1'b0;

            end

            //---------------------------------
            // DES done
            //---------------------------------

            if(done)
            begin

                cipher_buffer <= ciphertext;

                output_pending <= 1'b1;

                tx_count <= 0;

            end

            //---------------------------------
            // send output stream
            //---------------------------------

            if(source_accept)
            begin

                if(tx_count == 1)
                begin

                    output_pending <= 0;

                    tx_count <= 0;

                end
                else
                begin

                    tx_count <= tx_count + 1'b1;

                end

            end

        end

    end

    //========================================
    // DES CORE
    //========================================

    DES_TOP U_DES
    (
        .CLK(clk),
        .Resetn(reset_n),
        .Start(start_reg),

        .Plaintext(plaintext_reg),
        .Key(key_reg),

        .Ciphertext(ciphertext),
        .done(done)
    );

endmodule
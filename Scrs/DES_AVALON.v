module DES_AVALON (
    input clk,
    input reset_n,

    // Avalon-MM Slave Interface
    input [2:0] address,
    input write,
    input read,
    input [31:0] writedata,

    output reg [31:0] readdata
);

// INTERNAL REGISTERS
reg [63:0] plaintext_reg;
reg [63:0] key_reg;

reg start_reg;
reg done_reg;

wire [63:0] ciphertext;
wire done;

// START CONTROL
// start_reg sẽ giữ mức 1
// cho tới khi DES hoàn thành

always @(posedge clk or negedge reset_n) begin
    if(!reset_n)
        start_reg <= 1'b0;

    else begin

        // CPU ghi start
        if(write && address == 3'd4 && writedata[0])
            start_reg <= 1'b1;

        // DES hoàn thành
        else if(done)
            start_reg <= 1'b0;

    end
end


// DONE LATCH
// latch done để CPU polling được

always @(posedge clk or negedge reset_n) begin
    if(!reset_n)
        done_reg <= 1'b0;

    else begin

        // clear done khi start lần mới
        if(write && address == 3'd4 && writedata[0])
            done_reg <= 1'b0;

        // latch done
        else if(done)
            done_reg <= 1'b1;

    end
end

// WRITE REGISTERS
always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin

        plaintext_reg <= 64'd0;
        key_reg <= 64'd0;

    end
    else begin

        if(write) begin

            case(address)

                // Plaintext[63:32]
                3'd0:
                    plaintext_reg[63:32] <= writedata;

                // Plaintext[31:0]
                3'd1:
                    plaintext_reg[31:0] <= writedata;
						  
                // Key[63:32]
                3'd2:
                    key_reg[63:32] <= writedata;

                // Key[31:0]
                3'd3:
                    key_reg[31:0] <= writedata;

            endcase
        end
    end
end

// READ REGISTERS

always @(*) begin

    readdata = 32'd0;

    if(read) begin

        case(address)

            3'd4:
                readdata = {31'd0, done_reg};

            3'd5:
                readdata = ciphertext[63:32];

            3'd6:
                readdata = ciphertext[31:0];

            default:
                readdata = 32'd0;

        endcase
    end
end

// DES CORE
DES_TOP DES_CORE (

    .CLK(clk),
    .Resetn(reset_n),
    .Start(start_reg),

    .Plaintext(plaintext_reg),
    .Key(key_reg),

    .Ciphertext(ciphertext),
    .done(done),

    .L_dbg(),
    .R_dbg(),
    .K_dbg()
);

endmodule
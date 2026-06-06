module ShiftRight(
    input [1:56] Data,
    input [4:0] n,
    output reg [1:56] out
);

reg [1:28] C, D;

always @(*) begin

    C = Data[1:28];
    D = Data[29:56];

    // reverse DES schedule
    case(n)

        // shift 1 bit
        1, 8, 15, 16: begin
            C = {C[28], C[1:27]};
            D = {D[28], D[1:27]};
        end

        // shift 2 bits
        default: begin
            C = {C[27:28], C[1:26]};
            D = {D[27:28], D[1:26]};
        end

    endcase

    out = {C, D};

end

endmodule
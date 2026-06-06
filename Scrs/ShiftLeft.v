module ShiftLeft(
    input [1:56] Data,
    input [4:0] n,
    output reg [1:56] out
);

reg [1:28] C, D;

always @(*) begin
    // split
    C = Data[1:28];
    D = Data[29:56];

    // DES key schedule shift
    case (n)
        1, 2, 9, 16: begin
            C = {C[2:28], C[1]};
            D = {D[2:28], D[1]};
        end

        default: begin
            C = {C[3:28], C[1:2]};
            D = {D[3:28], D[1:2]};
        end
    endcase

    out = {C, D};
end

endmodule
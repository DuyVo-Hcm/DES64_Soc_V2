module DES_Decrypt(
    input CLK,
    input Resetn,
    input Start,

    input [1:64] Ciphertext,
    input [1:64] Key,

    output [1:64] Plaintext,
    output done,

    output [1:32] L_dbg,
    output [1:32] R_dbg,
    output [1:48] K_dbg,
    output [1:32] F_dbg
);

wire S_Data;
wire [1:0] S_Key;

wire [4:0] n;

wire WE_D;
wire WE_K;

//================ CONTROL =================
ControlUnit_Decrypt CU (
    .CLK(CLK),
    .Start(Start),
    .Resetn(Resetn),

    .S_Data(S_Data),
    .S_Key(S_Key),

    .n(n),

    .done(done),

    .WE_D(WE_D),
    .WE_K(WE_K)
);

//================ DATAPATH =================
Datapath_Decrypt DP (
    .CLK(CLK),
    .RST(Resetn),

    .Ciphertext(Ciphertext),
    .Key(Key),

    .S_Data(S_Data),
    .S_Key(S_Key),

    .n(n),

    .done(done),

    .WE_D(WE_D),
    .WE_K(WE_K),

    .Plaintext(Plaintext),

    .L_dbg(L_dbg),
    .R_dbg(R_dbg),
    .K_dbg(K_dbg),
    .F_dbg(F_dbg)
);

endmodule
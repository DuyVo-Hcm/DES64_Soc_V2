module Datapath_Decrypt(
    input CLK,
    input RST,

    input [1:64] Ciphertext,
    input [1:64] Key,

    input S_Data,
    input [1:0] S_Key,

    input [4:0] n,

    input done,

    input WE_D,
    input WE_K,

    output [1:64] Plaintext,

    output [1:32] L_dbg,
    output [1:32] R_dbg,
    output [1:48] K_dbg,
    output [1:32] F_dbg
);

wire [1:64] o_ip;

wire [1:56] o_pc1;
wire [1:56] o_shiftleft;
wire [1:56] o_shiftright;

wire [1:48] o_pc2;

wire [1:32] o_f;
wire [1:32] o_xor;

wire [1:64] D_in;
wire [1:64] D_out;

wire [1:56] K_in;
wire [1:56] K_out;

wire [1:48] K_sub;

wire [1:64] plaintext_internal;

//================ INITIAL PERMUTATION =================
IP ip (
    .Data(Ciphertext),
    .IP(o_ip)
);

//================ PC1 =================
PC1 pc1 (
    .key(Key),
    .out(o_pc1)
);

//================ SHIFT =================
ShiftLeft sl (
    .Data(K_out),
    .n(n),
    .out(o_shiftleft)
);

ShiftRight sr (
    .Data(K_out),
    .n(n),
    .out(o_shiftright)
);

//================ PC2 =================
PC2 pc2 (
    .key(o_shiftright),
    .out(o_pc2)
);

//================ SUBKEY REGISTER =================
Reg48 regSubKey (
    .clk(CLK),
    .rst(RST),
    .WE(WE_K),
    .in(o_pc2),
    .out(K_sub)
);

//================ DES f FUNCTION =================
Hamf f (
    .R(D_out[33:64]),
    .K(K_sub),
    .F(o_f)
);

//================ XOR =================
xor_32 xr (
    .A(D_out[1:32]),
    .B(o_f),
    .out(o_xor)
);

//================ DATA MUX =================
assign D_in =
    (S_Data == 0) ? o_ip :
    (S_Data == 1) ? {D_out[33:64], o_xor} :
                    D_out;

//================ KEY MUX =================
assign K_in =
    (S_Key == 2'b00) ? o_pc1 :
    (S_Key == 2'b01) ? o_shiftleft :
    (S_Key == 2'b10) ? o_shiftright :
                       K_out;

//================ DATA REGISTER =================
Reg64 regD (
    .clk(CLK),
    .rst(RST),
    .WE(WE_D),
    .in(D_in),
    .out(D_out)
);

//================ KEY REGISTER =================
Reg56 regK (
    .clk(CLK),
    .rst(RST),
    .WE(WE_K),
    .in(K_in),
    .out(K_out)
);

//================ OUTPUT BUFFER =================
Tri_64 tri_out (
    .in(plaintext_internal),
    .en(done),
    .out(Plaintext)
);

//================ FINAL PERMUTATION =================
IP_1 ip1 (
    .Data({D_out[33:64], D_out[1:32]}),
    .IP1(plaintext_internal)
);

//================ DEBUG =================
assign L_dbg = D_out[1:32];
assign R_dbg = D_out[33:64];

assign K_dbg = K_sub;

assign F_dbg = o_f;

endmodule
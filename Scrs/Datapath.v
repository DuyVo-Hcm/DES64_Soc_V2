`timescale 1ns / 1ps

module Datapath(
    input CLK,
    input RST,

    input [1:64] Plaintext,
    input [1:64] Key,

    input S_Data, S_Key,
    input [4:0] n,
    input done,

    input WE_D,
    input WE_K,

    output [1:64] Ciphertext,
    output [1:32] L_dbg,
    output [1:32] R_dbg,
    output [1:48] K_dbg
);

//================= WIRE =================
wire [1:64] o_ip;
wire [1:56] o_pc1, o_shiftleft;
wire [1:48] o_pc2;
wire [1:32] o_f, o_xor;

wire [1:64] D_in, D_out;
wire [1:56] K_in, K_out;
wire [1:48] K_sub;   // subkey ?� register
wire [1:64] cipher_internal;
//================= MODULE =================

// Initial Permutation
IP ip (.Data(Plaintext), .IP(o_ip));

// PC1
PC1 pc1 (.key(Key), .out(o_pc1));

// Shift key (C + D)
ShiftLeft sl (.Data(K_out), .n(n), .out(o_shiftleft));

// PC2 ? subkey combinational
PC2 pc2 (.key(o_shiftleft), .out(o_pc2));

// ===== REGISTER SUBKEY (Reg48 c?a b?n) =====
Reg48 regSubKey (
    .clk(CLK),
    .rst(RST),
    .WE(WE_K),     
    .in(o_pc2),
    .out(K_sub)
);

// f function
Hamf f (
    .R(D_out[33:64]),
    .K(K_sub),
    .F(o_f)
);

// XOR
xor_32 xr (
    .A(D_out[1:32]),
    .B(o_f),
    .out(o_xor)
);

//================= MUX =================

// Data path
assign D_in = (S_Data == 0) ? o_ip :
              (S_Data == 1) ? {D_out[33:64], o_xor} :
              D_out;

// Key path (C + D)
assign K_in = (S_Key == 0) ? o_pc1 :
              (S_Key == 1) ? o_shiftleft :
              K_out;

//================= REGISTER =================

// Data register
Reg64 regD (
    .clk(CLK),
    .rst(RST),
    .WE(WE_D),
    .in(D_in),
    .out(D_out)
);

// Key register (C + D)
Reg56 regK (
    .clk(CLK),
    .rst(RST),
    .WE(WE_K),
    .in(K_in),
    .out(K_out)
);

//================= OUTPUT =================

// Final swap + IP^-1
Tri_64 tri_out (
    .in(cipher_internal),
    .en(done),
    .out(Ciphertext)
);

IP_1 ip1 (
    .Data({D_out[33:64], D_out[1:32]}),
    .IP1(cipher_internal)
);

//================= DEBUG =================
assign L_dbg = D_out[1:32];
assign R_dbg = D_out[33:64];
assign K_dbg = K_sub;


endmodule
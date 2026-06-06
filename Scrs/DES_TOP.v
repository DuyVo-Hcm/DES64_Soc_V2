`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 10:52:10 AM
// Design Name: 
// Module Name: DES_TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module DES_TOP(
 input CLK,
 input Resetn,
 input Start,

 input [1:64] Plaintext,
 input [1:64] Key,

 output [1:64] Ciphertext,
 output done
);

//================= WIRE =================
wire S_Data, S_Key;
wire [4:0] n;
wire WE_D;
wire WE_K;

//================= CONTROL UNIT =================
ControllUnit CU (
    .CLK(CLK),
    .Start(Start),
    .Resetn(Resetn),

    .S_Data(S_Data),
    .S_Key(S_Key),
    .n(n),
    .WE_D(WE_D),
    .WE_K(WE_K),
    .done(done)
);

//================= DATAPATH =================
Datapath DP (
    .CLK(CLK),
    .RST(Resetn),   

    .Plaintext(Plaintext),
    .Key(Key),

    .S_Data(S_Data),
    .S_Key(S_Key),
    .n(n),
    .done(done),

    .WE_D(WE_D),
    .WE_K(WE_K),

    .Ciphertext(Ciphertext)
);

endmodule
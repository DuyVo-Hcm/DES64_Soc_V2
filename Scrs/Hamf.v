`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2026 10:14:16 AM
// Design Name: 
// Module Name: Hamf
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


module Hamf(
    input [1:32] R,
    input [1:48] K,
    output [1:32] F
);
wire [1:48] outE, outXOR;
wire [1:32] outSbox;

    E inst0 ( .Data(R), .E(outE) );
    assign outXOR = outE ^ K;
    S_BOX inst1 (.Data(outXOR), .out(outSbox) );
    P inst2 ( .Data(outSbox ), .out(F) );
    
endmodule

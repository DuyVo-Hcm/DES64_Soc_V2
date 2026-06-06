`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2026 11:24:48 AM
// Design Name: 
// Module Name: xor_32
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


module xor_32(
    input [1:32] A,
    input [1:32] B,
    output [1:32] out
    );

assign out = A ^ B;
endmodule


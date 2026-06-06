`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2026 11:35:42 AM
// Design Name: 
// Module Name: Tri_64
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

module Tri_64(
    input [1:64] in,
    input en,
    output [1:64] out
);
assign out = en ? in : 64'bz;
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2026 01:27:00 PM
// Design Name: 
// Module Name: Reg64
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


module Reg64 (
    input clk,
    input rst,
    input WE,
    input [1:64] in,
    output [1:64] out
);

reg [1:64] data_reg;

always @(posedge clk or negedge rst) begin
    if (!rst)
        data_reg <= 0;
    else if (WE)
        data_reg <= in;
end

assign out = data_reg;

endmodule

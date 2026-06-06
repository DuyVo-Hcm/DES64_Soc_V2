`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2026 01:36:45 PM
// Design Name: 
// Module Name: Reg56
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


module Reg56 (
    input clk,
    input rst,
    input WE,              // <-- thêm Write Enable
    input OE,              // Output Enable
    input [1:56] in,
    output [1:56] out
);

reg [1:56] data_reg;

// L?u d? li?u có ?i?u ki?n
always @(posedge clk or negedge rst) begin
    if (!rst)
        data_reg <= 0;
    else if (WE)           // <-- ch? ghi khi WE = 1
        data_reg <= in;
end

// Output control
assign out = data_reg;

endmodule

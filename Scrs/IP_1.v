`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2026 12:00:43 PM
// Design Name: 
// Module Name: IP_1
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


module IP_1 (
    input  [1:64] Data,
    output [1:64] IP1
);

assign IP1 = {
    Data[40], Data[8],  Data[48], Data[16], Data[56], Data[24], Data[64], Data[32],
    Data[39], Data[7],  Data[47], Data[15], Data[55], Data[23], Data[63], Data[31],
    Data[38], Data[6],  Data[46], Data[14], Data[54], Data[22], Data[62], Data[30],
    Data[37], Data[5],  Data[45], Data[13], Data[53], Data[21], Data[61], Data[29],
    Data[36], Data[4],  Data[44], Data[12], Data[52], Data[20], Data[60], Data[28],
    Data[35], Data[3],  Data[43], Data[11], Data[51], Data[19], Data[59], Data[27],
    Data[34], Data[2],  Data[42], Data[10], Data[50], Data[18], Data[58], Data[26],
    Data[33], Data[1],  Data[41], Data[9],  Data[49], Data[17], Data[57], Data[25]
};

endmodule

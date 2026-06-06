module IP (
    input  [1:64] Data,
    output [1:64] IP
);

assign IP = {
    Data[58], Data[50], Data[42], Data[34], Data[26], Data[18], Data[10], Data[2],
    Data[60], Data[52], Data[44], Data[36], Data[28], Data[20], Data[12], Data[4],
    Data[62], Data[54], Data[46], Data[38], Data[30], Data[22], Data[14], Data[6],
    Data[64], Data[56], Data[48], Data[40], Data[32], Data[24], Data[16], Data[8],
    Data[57], Data[49], Data[41], Data[33], Data[25], Data[17], Data[9],  Data[1],
    Data[59], Data[51], Data[43], Data[35], Data[27], Data[19], Data[11], Data[3],
    Data[61], Data[53], Data[45], Data[37], Data[29], Data[21], Data[13], Data[5],
    Data[63], Data[55], Data[47], Data[39], Data[31], Data[23], Data[15], Data[7]
};

endmodule

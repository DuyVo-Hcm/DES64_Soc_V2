module P (
    input  [1:32] Data,
    output [1:32] out
);

assign out = {
    Data[16], Data[7],  Data[20], Data[21],
    Data[29], Data[12], Data[28], Data[17],
    Data[1],  Data[15], Data[23], Data[26],
    Data[5],  Data[18], Data[31], Data[10],
    Data[2],  Data[8],  Data[24], Data[14],
    Data[32], Data[27], Data[3],  Data[9],
    Data[19], Data[13], Data[30], Data[6],
    Data[22], Data[11], Data[4],  Data[25]
};

endmodule
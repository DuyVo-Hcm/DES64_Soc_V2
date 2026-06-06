module PC2 (
    input  [1:56] key,
    output [1:48] out
);

assign out = {
    key[14], key[17], key[11], key[24], key[1],  key[5],
    key[3],  key[28], key[15], key[6],  key[21], key[10],
    key[23], key[19], key[12], key[4],  key[26], key[8],
    key[16], key[7],  key[27], key[20], key[13], key[2],
    key[41], key[52], key[31], key[37], key[47], key[55],
    key[30], key[40], key[51], key[45], key[33], key[48],
    key[44], key[49], key[39], key[56], key[34], key[53],
    key[46], key[42], key[50], key[36], key[29], key[32]
};

endmodule
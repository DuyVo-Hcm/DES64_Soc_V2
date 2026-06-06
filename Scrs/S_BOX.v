module S_BOX  (
	input [1:48] Data,
	output [1:32] out
);

wire [1:4] s1, s2, s3, s4, s5, s6, s7, s8;

S1_Box S1 (Data[1:6], s1);
S2_Box S2 (Data[7:12], s2);
S3_Box S3 (Data[13:18], s3);
S4_Box S4 (Data[19:24], s4);
S5_Box S5 (Data[25:30], s5);
S6_Box S6 (Data[31:36], s6);
S7_Box S7 (Data[37:42], s7);
S8_Box S8 (Data[43:48], s8);

assign out = {s1, s2, s3, s4, s5, s6, s7, s8};

endmodule 
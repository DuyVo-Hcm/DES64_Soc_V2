module S5_Box (
	input [1:6] Data,
	output reg [1:4] out
);

wire [1:2] row;
wire [1:4] col;

assign row = {Data[1], Data[6]};
assign col = {Data[2], Data[3], Data[4], Data[5]};

always @ (*) begin
	case ({row, col})
		6'b000000: out = 2;
		6'b000001: out = 12;
		6'b000010: out = 4;
		6'b000011: out = 1;
		6'b000100: out = 7;
		6'b000101: out = 10;
		6'b000110: out = 11;
		6'b000111: out = 6;
		6'b001000: out = 8;
		6'b001001: out = 5;
		6'b001010: out = 3;
		6'b001011: out = 15;
		6'b001100: out = 13;
		6'b001101: out = 0;
		6'b001110: out = 14;
		6'b001111: out = 9;

		6'b010000: out = 14;
		6'b010001: out = 11;
		6'b010010: out = 2;
		6'b010011: out = 12;
		6'b010100: out = 4;
		6'b010101: out = 7;
		6'b010110: out = 13;
		6'b010111: out = 1;
		6'b011000: out = 5;
		6'b011001: out = 0;
		6'b011010: out = 15;
		6'b011011: out = 10;
		6'b011100: out = 3;
		6'b011101: out = 9;
		6'b011110: out = 8;
		6'b011111: out = 6;

		6'b100000: out = 4;
		6'b100001: out = 2;
		6'b100010: out = 1;
		6'b100011: out = 11;
		6'b100100: out = 10;
		6'b100101: out = 13;
		6'b100110: out = 7;
		6'b100111: out = 8;
		6'b101000: out = 15;
		6'b101001: out = 9;
		6'b101010: out = 12;
		6'b101011: out = 5;
		6'b101100: out = 6;
		6'b101101: out = 3;
		6'b101110: out = 0;
		6'b101111: out = 14;

		6'b110000: out = 11;
		6'b110001: out = 8;
		6'b110010: out = 12;
		6'b110011: out = 7;
		6'b110100: out = 1;
		6'b110101: out = 14;
		6'b110110: out = 2;
		6'b110111: out = 13;
		6'b111000: out = 6;
		6'b111001: out = 15;
		6'b111010: out = 0;
		6'b111011: out = 9;
		6'b111100: out = 10;
		6'b111101: out = 4;
		6'b111110: out = 5;
		6'b111111: out = 3;

		default: out = 0;
	endcase
end
endmodule
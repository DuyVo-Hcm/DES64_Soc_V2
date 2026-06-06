module LCD_TEST(

    input CLOCK_50,

    output reg [7:0] LCD_DATA,
    output reg LCD_RS,
    output reg LCD_RW,
    output reg LCD_EN
);

reg [5:0] state;

always @(posedge CLOCK_50)
begin

    state <= state + 1;

    case(state)

    0: begin
        LCD_RS   <= 0;
        LCD_RW   <= 0;
        LCD_DATA <= 8'h38;
        LCD_EN   <= 1;
    end

    1: LCD_EN <= 0;

    2: begin
        LCD_RS   <= 0;
        LCD_RW   <= 0;
        LCD_DATA <= 8'h0C;
        LCD_EN   <= 1;
    end

    3: LCD_EN <= 0;

    4: begin
        LCD_RS   <= 0;
        LCD_RW   <= 0;
        LCD_DATA <= 8'h01;
        LCD_EN   <= 1;
    end

    5: LCD_EN <= 0;

    6: begin
        LCD_RS   <= 1;
        LCD_RW   <= 0;
        LCD_DATA <= "H";
        LCD_EN   <= 1;
    end

    7: LCD_EN <= 0;

    8: begin
        LCD_RS   <= 1;
        LCD_RW   <= 0;
        LCD_DATA <= "E";
        LCD_EN   <= 1;
    end

    9: LCD_EN <= 0;

    10: begin
        LCD_RS   <= 1;
        LCD_RW   <= 0;
        LCD_DATA <= "L";
        LCD_EN   <= 1;
    end

    11: LCD_EN <= 0;

    12: begin
        LCD_RS   <= 1;
        LCD_RW   <= 0;
        LCD_DATA <= "L";
        LCD_EN   <= 1;
    end

    13: LCD_EN <= 0;

    14: begin
        LCD_RS   <= 1;
        LCD_RW   <= 0;
        LCD_DATA <= "O";
        LCD_EN   <= 1;
    end

    15: LCD_EN <= 0;

    endcase

end

endmodule
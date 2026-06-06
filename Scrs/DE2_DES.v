module DE2_DES(

    input [3:0] KEY,
    input [17:0] SW,

    output [7:0] LCD_DATA,
    output LCD_RS,
    output LCD_RW,
    output LCD_EN,
    output LCD_ON,
    output LCD_BLON
);

assign LCD_ON   = 1'b1;
assign LCD_BLON = 1'b1;

LCD_TEST lcd0(
    .CLOCK_50(KEY[0]),

    .LCD_DATA(LCD_DATA),
    .LCD_RS(LCD_RS),
    .LCD_RW(LCD_RW),
    .LCD_EN(LCD_EN)
);

endmodule
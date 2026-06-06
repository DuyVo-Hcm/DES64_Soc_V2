module Bai_DES(
    input          CLOCK_50,
    input  [3:0]   KEY,
    output [17:0]  LEDR,
    inout  [35:0]  GPIO_1
);

wire lcd_sda;
wire lcd_scl;

assign GPIO_1[0] = lcd_sda;
assign GPIO_1[1] = lcd_scl;

//====================================================================
// QSYS SYSTEM INSTANTIATION 
//====================================================================
system DES_system (
    .clk_clk(CLOCK_50),
    .reset_reset_n(1'b1),   

    .sda_external_connection_export(lcd_sda),
    .scl_external_connection_export(lcd_scl),

    .key_external_connection_export(KEY),
    .ledr_external_connection_export(LEDR)
);

// Lưu ý: Hai khối sgdma_tx và sgdma_rx bên trong Qsys vẫn tự động 
// kết nối đến lõi DES_STREAM_AVALON thông qua các đường dây nội bộ Avalon-ST.
// Bạn hoàn toàn giữ nguyên sơ đồ khối Qsys cũ mà không sợ lỗi!

endmodule
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "system.h"
#include "io.h"
#include "sys/alt_stdio.h"
#include "sys/alt_cache.h"            // Thư viện quản lý Cache chính quy của Altera
#include "altera_avalon_jtag_uart_regs.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_sgdma.h"
#include "altera_avalon_sgdma_descriptor.h"
#include "altera_avalon_sgdma_regs.h"

// ========================================================================
// CẤU HÌNH ĐỊA CHỈ PHẦN CỨNG (ĐỒNG BỘ TỪ SYSTEM.H CỦA BẠN)
// ========================================================================
#define DMA_TX_BASE 0x11080
#define DMA_RX_BASE 0x110c0

#ifndef SGDMA_TX_NAME
  #define SGDMA_TX_NAME "/dev/sgdma_tx_0"
#endif
#ifndef SGDMA_RX_NAME
  #define SGDMA_RX_NAME "/dev/sgdma_rx_0"
#endif

#define KEY_BASE        0x11150
#define LEDR_BASE       0x11140
#define SCL_BASE        0x11160
#define SDA_BASE        0x11170

#define I2C_LCD_ADDR    0x27
#define PIN_RS          0x01
#define PIN_RW          0x02
#define PIN_EN          0x04
#define PIN_BL          0x08

// Vùng đệm tĩnh căn lề 4-bytes cho SGDMA hoạt động
volatile alt_u32 dma_src_buffer[4] __attribute__((aligned(4)));
volatile alt_u32 dma_dest_buffer[2] __attribute__((aligned(4)));

alt_sgdma_descriptor tx_descriptor;
alt_sgdma_descriptor rx_descriptor;

alt_sgdma_dev *sgdma_tx_dev = NULL;
alt_sgdma_dev *sgdma_rx_dev = NULL;

// Prototypes (Nguyên mẫu hàm) để trình biên dịch không báo lỗi Implicit
void DES_Encrypt_With_SGDMA(unsigned int pt_high, unsigned int pt_low, unsigned int key_high, unsigned int key_low, unsigned int *ct_high, unsigned int *ct_low);
void Run_All_10_Testcases_Automatically(void);
unsigned int swap_bytes_32(unsigned int val);

typedef struct {
    unsigned int pt_high;
    unsigned int pt_low;
    unsigned int key_high;
    unsigned int key_low;
    unsigned int expected_ct_high;
    unsigned int expected_ct_low;
} DES_Testcase;

DES_Testcase testcases[10] = {
    {0x01234567, 0x89ABCDEF, 0x13345779, 0x9BBCDFF1, 0x85E81354, 0x0F0AB405}, // TC1
    {0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x8CA64DE9, 0xC1B123A7}, // TC2
    {0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x7359B216, 0x3E4EDC58}, // TC3
    {0x30303030, 0x30303030, 0xAA55AA55, 0xAA55AA55, 0xF2E12666, 0x675B082A}, // TC4
    {0xFEEBDAED, 0xDEADBEEF, 0x01010101, 0x01010101, 0xFC7FFA55, 0x6A4F527E}, // TC5
    {0x11111111, 0x11111111, 0xF0F0F0F0, 0xF0F0F0F0, 0xEE281E51, 0x5E9EAA27}, // TC6
    {0x12345678, 0x9ABCDEF0, 0x0F1E2D3C, 0x4B5A6978, 0x719FF2E2, 0xE79207B4}, // TC7
    {0x55555555, 0x55555555, 0xCCCCCCCC, 0xCCCCCCCC, 0xF7B9CCD7, 0x8AC23A8F}, // TC8
    {0xAAAAA222, 0xBBBBB333, 0x11112222, 0x33334444, 0xE1C799F5, 0x146868AA}, // TC9
    {0x88888888, 0x77777777, 0x99999999, 0xBBBBBBBB, 0x9ABB39FD, 0x518CEAB3}  // TC10
};

void delay_us(int us) { usleep(us); }

unsigned int swap_bytes_32(unsigned int val) {
    return ((val >> 24) & 0x000000FF) | ((val >> 8)  & 0x0000FF00) |
           ((val << 8)  & 0x00FF0000) | ((val << 24) & 0xFF000000);
}

/////////////////////////////////////////////////////////
// I2C LCD 16X2 DRIVER ENGINE
/////////////////////////////////////////////////////////
void I2C_SCL_Write(int s) { IOWR(SCL_BASE, 0, s); }
void I2C_SDA_Write(int s) { if (s) IOWR(SDA_BASE, 1, 0); else { IOWR(SDA_BASE, 1, 1); IOWR(SDA_BASE, 0, 0); } }
void I2C_Start() { I2C_SDA_Write(1); I2C_SCL_Write(1); delay_us(4); I2C_SDA_Write(0); delay_us(4); I2C_SCL_Write(0); }
void I2C_Stop() { I2C_SDA_Write(0); delay_us(4); I2C_SCL_Write(1); delay_us(4); I2C_SDA_Write(1); }
void I2C_SendByte(unsigned char d) { int i; for (i = 0; i < 8; i++) { I2C_SDA_Write((d & 0x80) ? 1 : 0); delay_us(2); I2C_SCL_Write(1); delay_us(4); I2C_SCL_Write(0); delay_us(2); d <<= 1; } I2C_SDA_Write(1); delay_us(2); I2C_SCL_Write(1); delay_us(4); I2C_SCL_Write(0); }
void LCD_Write_Nibble(unsigned char n, unsigned char rs) { unsigned char d = n | (rs ? 0x01 : 0x00) | PIN_BL; I2C_Start(); I2C_SendByte(I2C_LCD_ADDR << 1); I2C_SendByte(d | PIN_EN); delay_us(1); I2C_SendByte(d & ~PIN_EN); delay_us(50); I2C_Stop(); }
void LCD_Send(unsigned char v, unsigned char mode) { LCD_Write_Nibble(v & 0xF0, mode); LCD_Write_Nibble((v << 4) & 0xF0, mode); }
void LCD_Command(unsigned char c) { LCD_Send(c, 0); }
void LCD_Char(unsigned char c)    { LCD_Send(c, 1); }
void LCD_Init() { delay_us(50000); LCD_Write_Nibble(0x30, 0); delay_us(5000); LCD_Write_Nibble(0x30, 0); delay_us(200); LCD_Write_Nibble(0x30, 0); delay_us(200); LCD_Write_Nibble(0x20, 0); delay_us(200); LCD_Command(0x28); LCD_Command(0x0C); LCD_Command(0x06); LCD_Command(0x01); delay_us(2000); }
void LCD_SetCursor(unsigned char row, unsigned char col) { LCD_Command((row == 0 ? 0x80 : 0xC0) + col); }
void LCD_String(char *s) { while (*s) LCD_Char(*s++); }
void LCD_Clear() { LCD_Command(0x01); delay_us(2000); }

void JTAG_UART_WriteChar(char c) { unsigned int jtag_control; while(1) { jtag_control = IORD_ALTERA_AVALON_JTAG_UART_CONTROL(JTAG_UART_0_BASE); if ((jtag_control & ALTERA_AVALON_JTAG_UART_CONTROL_WSPACE_MSK) != 0) { IOWR_ALTERA_AVALON_JTAG_UART_DATA(JTAG_UART_0_BASE, c); break; } } }
void JTAG_UART_WriteString(const char *s) { while(*s) JTAG_UART_WriteChar(*s++); }
void UART_PrintHex(unsigned int x) { char hex[] = "0123456789ABCDEF"; int i; for(i = 28; i >= 0; i -= 4) JTAG_UART_WriteChar(hex[(x >> i) & 0xF]); }
void hex_to_string_16char(unsigned int high, unsigned int low, char *buf) { char hex[] = "0123456789ABCDEF"; int i; for(i = 0; i < 8; i++) { buf[7 - i] = hex[high & 0xF]; high >>= 4; } for(i = 0; i < 8; i++) { buf[15 - i] = hex[low & 0xF]; low >>= 4; } buf[16] = 0; }

// ========================================================================
// SGDMA PIPELINE ENGINE (BẢN PHỐI HỢP RESETS CỨNG + ĐỒNG BỘ CACHE VẬT LÝ)
// ========================================================================
void DES_Encrypt_With_SGDMA(unsigned int pt_high, unsigned int pt_low, unsigned int key_high, unsigned int key_low, unsigned int *ct_high, unsigned int *ct_low) {
    if (!sgdma_tx_dev || !sgdma_rx_dev) return;

    // 1. Gán dữ liệu thô
    dma_src_buffer[0] = swap_bytes_32(pt_high);
    dma_src_buffer[1] = swap_bytes_32(pt_low);
    dma_src_buffer[2] = swap_bytes_32(key_high);
    dma_src_buffer[3] = swap_bytes_32(key_low);

    dma_dest_buffer[0] = 0;
    dma_dest_buffer[1] = 0;

    // 2. Ép dữ liệu từ Cache CPU xuống RAM để DMA không đọc nhầm số 0
    alt_dcache_flush((void*)dma_src_buffer, sizeof(dma_src_buffer));
    alt_dcache_flush((void*)dma_dest_buffer, sizeof(dma_dest_buffer));

    // 3. Khởi tạo cấu trúc luồng
    alt_avalon_sgdma_construct_stream_to_mem_desc(&rx_descriptor, NULL, (alt_u32 *)dma_dest_buffer, 8, 0);
    alt_avalon_sgdma_construct_mem_to_stream_desc(&tx_descriptor, NULL, (alt_u32 *)dma_src_buffer, 16, 0, 1, 1, 0);

    // 4. Kích hoạt DMA
    alt_avalon_sgdma_do_async_transfer(sgdma_rx_dev, &rx_descriptor);
    alt_avalon_sgdma_do_async_transfer(sgdma_tx_dev, &tx_descriptor);

    // 5. Chờ phần cứng xử lý
    int timeout = 5000000;
    while (timeout--) {
        if (alt_avalon_sgdma_check_descriptor_status(&rx_descriptor) == 0 &&
            alt_avalon_sgdma_check_descriptor_status(&tx_descriptor) == 0) {
            break;
        }
    }

    if (timeout <= 0) {
        JTAG_UART_WriteString(">>> ERROR: TIMEOUT <<<\n");
        *ct_high = 0; *ct_low = 0;
        return;
    }

    // 6. Đọc kết quả qua con trỏ Uncached (Bypass Cache)
    volatile alt_u32 *uncached_dest = (volatile alt_u32 *)(((alt_u32)dma_dest_buffer) | 0x80000000);

    *ct_high = swap_bytes_32(uncached_dest[0]);
    *ct_low  = swap_bytes_32(uncached_dest[1]);
}

// ========================================================================
// ENGINE TỰ ĐỘNG CHẠY VÀ QUÉT ĐỒNG BỘ HIỂN THỊ LCD (GIỮ NGUYÊN)
// ========================================================================
void Run_All_10_Testcases_Automatically() {
    unsigned int ct_high, ct_low;
    int tc;
    int success_count = 0;
    char lcd_msg1[20];
    char lcd_msg2[20];
    char buf_disp[17];

    JTAG_UART_WriteString("\n=================================================\n");
    JTAG_UART_WriteString("   BAT DAU QUET TU DONG 10 TESTCASES LIEN MACH   \n");
    JTAG_UART_WriteString("=================================================\n");

    for(tc = 0; tc < 10; tc++) {
        LCD_Clear();
        sprintf(lcd_msg1, "RUNNING TC: %02d", tc + 1);
        LCD_SetCursor(0, 0); LCD_String(lcd_msg1);
        LCD_SetCursor(1, 0); LCD_String("CALCULATING...");

        JTAG_UART_WriteString("\n-------------------------------------------------\n");
        JTAG_UART_WriteString("RUNNING TESTCASE: "); UART_PrintHex(tc + 1); JTAG_UART_WriteString("\n");

        DES_Encrypt_With_SGDMA(testcases[tc].pt_high, testcases[tc].pt_low, testcases[tc].key_high, testcases[tc].key_low, &ct_high, &ct_low);

        JTAG_UART_WriteString("OUTPUT CT: "); UART_PrintHex(ct_high); JTAG_UART_WriteChar(' '); UART_PrintHex(ct_low); JTAG_UART_WriteString("\n");
        JTAG_UART_WriteString("EXPECTED : "); UART_PrintHex(testcases[tc].expected_ct_high); JTAG_UART_WriteChar(' '); UART_PrintHex(testcases[tc].expected_ct_low); JTAG_UART_WriteString("\n");

        LCD_Clear();
        sprintf(lcd_msg1, "TC%02d: ", tc + 1);
        LCD_SetCursor(0, 0); LCD_String(lcd_msg1);

        if(ct_high == testcases[tc].expected_ct_high && ct_low == testcases[tc].expected_ct_low) {
            JTAG_UART_WriteString(">>> STATUS: VERIFICATION SUCCESS (100%) <<<\n");
            LCD_SetCursor(0, 6); LCD_String("SUCCESS");
            success_count++;
        } else {
            JTAG_UART_WriteString(">>> STATUS: VERIFICATION FAILED <<<\n");
            LCD_SetCursor(0, 6); LCD_String("FAILED BIT  ");
        }
        JTAG_UART_WriteString("-------------------------------------------------\n");

        hex_to_string_16char(ct_high, ct_low, buf_disp);
        LCD_SetCursor(1, 0); LCD_String(buf_disp);

        usleep(1500000);
    }

    LCD_Clear();
    LCD_SetCursor(0, 0); LCD_String("DONE ALL 10 TCs");
    sprintf(lcd_msg2, "SCORE: %02d/10 OK ", success_count);
    LCD_SetCursor(1, 0); LCD_String(lcd_msg2);

    JTAG_UART_WriteString("\n=================================================\n");
    JTAG_UART_WriteString("KET LUAN CHUNG: TOAN BO HE THONG DAT ");
    UART_PrintHex(success_count); JTAG_UART_WriteString("/10 KET QUA HOAN HAO.\n");
    JTAG_UART_WriteString("=================================================\n");
}

int main() {
    LCD_Init();

    sgdma_tx_dev = alt_avalon_sgdma_open(SGDMA_TX_NAME);
    sgdma_rx_dev = alt_avalon_sgdma_open(SGDMA_RX_NAME);

    unsigned int btn_state;

    start_point:
    IOWR(LEDR_BASE, 0, 0x00000);
    LCD_Clear();
    LCD_SetCursor(0, 0); LCD_String("DES AUTO SYSTEM");
    LCD_SetCursor(1, 0); LCD_String("K0:RST | K1:START");

    JTAG_UART_WriteString("\n=============================================\n");
    JTAG_UART_WriteString("   READY SYS: KEY[0]=RESET | KEY[1]=START AUTO \n");
    JTAG_UART_WriteString("=============================================\n");

    while(1) {
        btn_state = IORD_ALTERA_AVALON_PIO_DATA(KEY_BASE);
        int k0 = (btn_state >> 0) & 1;
        int k1 = (btn_state >> 1) & 1;

        if (k0 == 0) {
            delay_us(25000);
            if (((IORD_ALTERA_AVALON_PIO_DATA(KEY_BASE) >> 0) & 1) == 0) {
                while(((IORD_ALTERA_AVALON_PIO_DATA(KEY_BASE) >> 0) & 1) == 0);
                JTAG_UART_WriteString("\n[KEY 0] -> HE THONG DA RESET VE BAN DAU.\n");
                goto start_point;
            }
        }

        if (k1 == 0) {
            delay_us(25000);
            if (((IORD_ALTERA_AVALON_PIO_DATA(KEY_BASE) >> 1) & 1) == 0) {
                while(((IORD_ALTERA_AVALON_PIO_DATA(KEY_BASE) >> 1) & 1) == 0);
                IOWR(LEDR_BASE, 0, 0x3FFFF);
                Run_All_10_Testcases_Automatically();
                IOWR(LEDR_BASE, 0, 0x00000);
            }
        }
        delay_us(2000);
    }
    return 0;
}

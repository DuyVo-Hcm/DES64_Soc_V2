#include <stdio.h>
#include <unistd.h>

#include "system.h"
#include "io.h"

/////////////////////////////////////////////////////////
// LCD ENABLE
/////////////////////////////////////////////////////////

void LCD_Enable()
{
    IOWR(LCD_EN_BASE,0,1);

    usleep(1);

    IOWR(LCD_EN_BASE,0,0);

    usleep(100);
}

/////////////////////////////////////////////////////////
// LCD COMMAND
/////////////////////////////////////////////////////////

void LCD_Command(unsigned char cmd)
{
    IOWR(LCD_RS_BASE,0,0);

    IOWR(LCD_RW_BASE,0,0);

    IOWR(LCD_D_BASE,0,cmd);

    LCD_Enable();
}

/////////////////////////////////////////////////////////
// LCD DATA
/////////////////////////////////////////////////////////

void LCD_Char(unsigned char data)
{
    IOWR(LCD_RS_BASE,0,1);

    IOWR(LCD_RW_BASE,0,0);

    IOWR(LCD_D_BASE,0,data);

    LCD_Enable();
}

/////////////////////////////////////////////////////////
// LCD STRING
/////////////////////////////////////////////////////////

void LCD_String(char *str)
{
    while(*str)
    {
        LCD_Char(*str);
        str++;
    }
}

/////////////////////////////////////////////////////////
// LCD CLEAR
/////////////////////////////////////////////////////////

void LCD_Clear()
{
    LCD_Command(0x01);

    usleep(2000);
}

/////////////////////////////////////////////////////////
// LCD LINE 2
/////////////////////////////////////////////////////////

void LCD_Line2()
{
    LCD_Command(0xC0);
}

/////////////////////////////////////////////////////////
// LCD INIT
/////////////////////////////////////////////////////////

void LCD_Init()
{
    IOWR(LCD_ON_BASE,0,1);

    IOWR(LCD_BLON_BASE,0,1);

    usleep(50000);

    LCD_Command(0x38);

    LCD_Command(0x0C);

    LCD_Command(0x06);

    LCD_Clear();
}

/////////////////////////////////////////////////////////
// HEX CHAR -> VALUE
/////////////////////////////////////////////////////////

unsigned int hex_to_val(char c)
{
    if(c >= '0' && c <= '9')
        return c - '0';

    if(c >= 'A' && c <= 'F')
        return c - 'A' + 10;

    if(c >= 'a' && c <= 'f')
        return c - 'a' + 10;

    return 0;
}

/////////////////////////////////////////////////////////
// READ HEX UART
/////////////////////////////////////////////////////////

unsigned int UART_ReadHex()
{
    char c;

    int i;

    unsigned int value = 0;

    for(i=0;i<8;i++)
    {
        c = getchar();

        putchar(c);

        value =
            (value << 4)
            | hex_to_val(c);
    }

    return value;
}

/////////////////////////////////////////////////////////
// DES ENCRYPT
/////////////////////////////////////////////////////////

void DES_encrypt(
    unsigned int pt_high,
    unsigned int pt_low,
    unsigned int key_high,
    unsigned int key_low,
    unsigned int *ct_high,
    unsigned int *ct_low
)
{
    /////////////////////////////////////////
    // PLAINTEXT
    /////////////////////////////////////////

    IOWR(DES_AVALON_0_BASE,0,pt_high);

    IOWR(DES_AVALON_0_BASE,1,pt_low);

    /////////////////////////////////////////
    // KEY
    /////////////////////////////////////////

    IOWR(DES_AVALON_0_BASE,2,key_high);

    IOWR(DES_AVALON_0_BASE,3,key_low);

    /////////////////////////////////////////
    // START
    /////////////////////////////////////////

    IOWR(DES_AVALON_0_BASE,4,1);

    /////////////////////////////////////////
    // WAIT DONE
    /////////////////////////////////////////

    while((IORD(DES_AVALON_0_BASE,4) & 1) == 0);

    /////////////////////////////////////////
    // READ OUTPUT
    /////////////////////////////////////////

    *ct_high = IORD(DES_AVALON_0_BASE,5);

    *ct_low  = IORD(DES_AVALON_0_BASE,6);
}

/////////////////////////////////////////////////////////
// MAIN
/////////////////////////////////////////////////////////

int main()
{
    unsigned int pt_high;
    unsigned int pt_low;

    unsigned int key_high;
    unsigned int key_low;

    unsigned int ct_high;
    unsigned int ct_low;

    char buffer[17];

    LCD_Init();

    LCD_String("DES READY");

    printf("\nDES UART READY\n");

    while(1)
    {
        /////////////////////////////////////////
        // INPUT PLAINTEXT
        /////////////////////////////////////////

        printf("\nPT HIGH (8 HEX): ");

        pt_high = UART_ReadHex();

        printf("\n");

        printf("PT LOW  (8 HEX): ");

        pt_low = UART_ReadHex();

        printf("\n");

        /////////////////////////////////////////
        // INPUT KEY
        /////////////////////////////////////////

        printf("KEY HIGH (8 HEX): ");

        key_high = UART_ReadHex();

        printf("\n");

        printf("KEY LOW  (8 HEX): ");

        key_low = UART_ReadHex();

        printf("\n");

        /////////////////////////////////////////
        // LCD SHOW INPUT
        /////////////////////////////////////////

        LCD_Clear();

        sprintf(buffer,"%08X",pt_high);

        LCD_String(buffer);

        LCD_Line2();

        sprintf(buffer,"%08X",key_high);

        LCD_String(buffer);

        /////////////////////////////////////////
        // DES
        /////////////////////////////////////////

        DES_encrypt(
            pt_high,
            pt_low,
            key_high,
            key_low,
            &ct_high,
            &ct_low
        );

        /////////////////////////////////////////
        // RESULT
        /////////////////////////////////////////

        printf("\n");

        printf("CIPHERTEXT = %08X %08X\n",
               ct_high,
               ct_low);

        /////////////////////////////////////////
        // LCD OUTPUT
        /////////////////////////////////////////

        LCD_Clear();

        sprintf(buffer,"%08X",ct_high);

        LCD_String(buffer);

        LCD_Line2();

        sprintf(buffer,"%08X",ct_low);

        LCD_String(buffer);
    }

    return 0;
}

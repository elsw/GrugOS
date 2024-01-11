#include "kernel.h"
#include <stdint.h>
#include <stddef.h>

uint16_t* video_text = 0;
uint16_t terminal_row,terminal_col;

uint16_t terminal_make_char(char c,char colour)
{
    return c | (colour << 8);
}

void putchar(int x,int y,char c,char colour)
{
    video_text[(y * VGA_WIDTH) + x] = terminal_make_char(c,colour);
}

void terminal_append_char(char c,char colour)
{
    if(c == '\n')
    {
        terminal_row++;
        terminal_col = 0;
        return;
    }

    putchar(terminal_col,terminal_row,c,colour);
    terminal_col++;
    if(terminal_col >= VGA_WIDTH)
    {
        terminal_row++;
        terminal_col = 0;
    }
}

void terminal_initialise()
{
    video_text = (uint16_t*)(0xB8000);
    for(int y = 0 ; y < VGA_HEIGHT ; y++)
    {
        for(int x = 0 ; x < VGA_WIDTH ; x++)
        {
            putchar(x,y,' ',0);
        }
    }
    terminal_row = 0;
    terminal_col = 0;
}

size_t strlen(const char* str)
{
    size_t len = 0;
    while(str[len])
    {
        len++;
    }
    return len;
}

void print(const char *str)
{
    print_colour(str,5);
}

void print_colour(const char* str,const char colour)
{
    size_t len = strlen(str);
    for(int i = 0 ; i < len ; i++)
    {
        terminal_append_char(str[i],colour);
    }
}

void kernel_main()
{
    terminal_initialise();
    print_colour("Grug say ugg",5);
}
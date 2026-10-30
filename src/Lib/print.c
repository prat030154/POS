#include "stdarg.h"
#include "stdint.h"
#include "print.h"

static struct screenBuffer screen_buffer = {(char*)0xb8000, 0, 0};

void write_screen(char *buffer, int buffer_size, struct screenBuffer *sb, int8_t color)
{
    int col = sb->col;
    int row = sb->row;
    char *vga = sb->buffer;

    for(int i = 0; i < buffer_size; i++)
    {
        if(buffer[i]!='\n')
        {
            vga[row*2+col*160] = buffer[i];
            vga[row*2+col*160+1] = color;
            col += row/79;
            row = (row+1)%80;
        }
        else col++,row=0;

        if(col>=25)
        {
            // scroll
            char *vgaBuff = (char *)0xB8000;
            for(int i = 1; i < 24; i++)
            {
                for(int j = 0; j < 160; j++)
                {
                    vgaBuff[(i-1)*160+j] = vgaBuff[i*160+j];
                }
            }
            col--;
        }
    }
    sb->col = col;
    sb->row = row;
}

int u2s(char *buffer, int buffer_size, uint64_t n)   // unsigned to string
{
    char *buff = "";
    int i = 0;
    do
    {
        buff[i++] = ('0'+n%10);
        n /= 10;
    } while (n!=0);
    int cnt=i;
    while(--cnt>=0)
    {
        buffer[buffer_size++] = buff[cnt];
    }
    return i;
}

int i2s(char *buffer, int buffer_size, int64_t n)   // int to string
{
    char *buff = "";
    int i = 0;
    bool negative = false;
    if(n<0)
    {
        negative = true;
        n *= -1;
    }
    do
    {
        buff[i++] = ('0'+n%10);
        n /= 10;
    } while (n!=0);
    
    if(negative)
    {
        buff[i++] = '-';
    }
    int cnt=i;
    while(--cnt>=0)
    {
        buffer[buffer_size++] = buff[cnt];
    }
    return i;
}

int i2hs(char *buffer, int buffer_size, uint64_t n)   // int to hex string
{
    char *buff = "";
    char *c = "0123456789ABCDEF";
    int i = 0;
    do
    {
        buff[i++] = c[n%16];
        n /= 16;
    } while (n!=0);
    buff[i++] = 'x';
    buff[i++] = '0';
    int cnt=i;
    while(--cnt>=0)
    {
        buffer[buffer_size++] = buff[cnt];
    }
    return i;
}

int readStr(char *buffer, int buffer_size, char *string)
{
    int i = 0;
    while(string[i]!='\0')
    {
        buffer[buffer_size++] = string[i];
        i++;
    }
    return i;
}

int print(const char *format, ...)
{
    char buffer[1024];
    int buffer_size = 0;
    int64_t integer = 0;
    char *string = 0;
    va_list args;

    va_start(args,format);

    for (int i = 0; format[i] != '\0'; i++) {
        if (format[i] != '%') {
            buffer[buffer_size++] = format[i];
        }
        else {
            switch (format[++i]) {
                case 'x':
                    integer = va_arg(args, int64_t);
                    buffer_size += i2hs(buffer,buffer_size,(uint64_t)integer);
                    break;

                case 'u':
                    integer = va_arg(args, int64_t);
                    buffer_size += u2s(buffer,buffer_size,(uint64_t)integer);
                    break;

                case 'd':
                    integer = va_arg(args, int64_t);
                    buffer_size += i2s(buffer,buffer_size,integer);
                    break;

                case 's':
                    string = va_arg(args, char*);
                    buffer_size += readStr(buffer,buffer_size,string);
                    break;

                default:
                    buffer[buffer_size++] = '%';
                    i--;
            }
        }     
    }

    write_screen(buffer, buffer_size, &screen_buffer, 0xf);
    va_end(args);
    return buffer_size;
}
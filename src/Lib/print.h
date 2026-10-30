#ifndef PRINT_H
#define PRINT_H

#define LINE_SIZE 160

struct screenBuffer
{
    char *buffer;
    int col;
    int row;
};

int print(const char *format, ...);

#endif
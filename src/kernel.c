#include "stdint.h"
#include "Lib/print.h"

void main()
{
    // freeze
    print("Hello\n");
    int64_t t = 3;
    print("%d %u %x", t, t, t);
    for(;;){}
}
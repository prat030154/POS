void main()
{
    char *vga = (char *)0xB8000;
    vga[0] = 'M';
    vga[1] = 0x0E;

    // freeze
    for(;;){}
}
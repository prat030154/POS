ENTRY(main)

SECTIONS
{
    . = 0x10000;

    .text : {*(.text)}
    .bss : {*(.bss)}
    .data : {*(.data)}
    .rodata : {*(.rodata)}
}
[org 0x7e00]
[bits 16]

start:
    mov ah,0xe
    mov al,'L'
    int 0x10

end:
    hlt
    jmp $
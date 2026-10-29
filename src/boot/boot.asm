[org 0x7c00]
[bits 16]

start:
    cli     ; disable interrupt
    mov [DRIVEID], dl
    ; Setup segment
    xor ax, ax
    mov ds, ax      ; BIOS does not guarantee the initial data segment
    mov ss, ax      ; stack segment
    mov es, ax      ; extra segment
    mov sp, 0x7c00  ; stack pointer

    ; Read the disk using 0x13 interrupt
    mov si, LBA_PACKET
    mov ah, 0x42
    mov dl, [DRIVEID]
    int 0x13

    ; jump to the loaded data
    jmp 0x0000:0x7e00
    jmp $

DRIVEID: db 0
LBA_PACKET:
    db 0x10     ; packet size(16 bytes)
    db 0        ; always 0
    dw 1        ; load exactly one loader sector
    dw 0x7e00   ; memory buffer destination 
    dw 0x0      ; (0x0:0x7e00)
    dd 1        ; low addr of lba address
    dd 0        ; high addr of lba address

times 510-($-$$) db 0
dw 0xaa55

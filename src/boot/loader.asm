[org 0x7e00]
[bits 16]

start:
    cli
    mov [DRIVEID],dl
    ; Check A20 line and activate it
    mov ax, 0x2403          ; query A20 gate support
    int 0x15   
    jc .a20NotSupport       ; int 0x15 not support
    test ah, ah     
    jnz .a20NotSupport      ; int 0x15 not support

    mov ax, 0x2402          ; get A20 status
    int 0x15
    jc .a20Failed           ; couldn't get status
    test ah, ah
    jnz .a20Failed          ; couldn't get status
    test al, al 
    jnz .a20Activated       ; A20 already activated

    mov ax, 0x2401          ; activate A20 gate
    int 0x15
    jc .a20Failed           ; couldn't activate
    test ah, ah
    jnz .a20Failed          ; couldn't activate

.a20NotSupport:
.a20Failed:
    jmp end

.a20Activated:       
    ; Set video mode
    mov ah, 0
    mov al, 3
    int 0x10

    ; Load kernel at 0x10000
    mov si, LBA_PACKET      ; load kernel at 0x10000
    mov ah, 0x42
    mov dl, 0x80
    int 0x13

    ; Get memory map at 0x8000
    xor ax, ax
    mov es, ax
    mov ds, ax

    mov si, 0
    mov di, 0x8002

    xor ebx, ebx
    .next:
        mov eax, 0xE820
        mov edx, 0x534D4150
        mov ecx, 24

        int 0x15

        jc .error

        cmp eax, 0x534D4150
        jne .error

        inc si

        add di, 24

        test ebx, ebx
        jnz .next

    .done:
        mov [0x8000], si
        jmp .loadGDT
        jmp $

    .error:
        mov word [0x8000], 0xFFFF
    

    ; Load 32bit GDT
.loadGDT:
    lgdt [GDT32DESCRIPTOR]

    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CodeSeg:ProtectedModeEntry

end:
    hlt
    jmp $

DRIVEID: db 0
LBA_PACKET:
    db 0x10     ; packet size(16 bytes)
    db 0        ; always 0
    dw 100
    dw 0        ; memory buffer destination 
    dw 0x1000   ; 0x1000*16+0 = 0x10000
    dd 2        ; low addr of lba address
    dd 0        ; high addr of lba address

GDT32DESCRIPTOR:
    dw GDT32END-GDT32-1     ; GDT size -1
    dd GDT32                ; address of GDT

GDT32:
GDT32NULL:
    dq 0
GDT32CODE:
    dw 0xFFFF   ; bit 0-15  Limit
    dw 0        ; bit 16-31 Base
    db 0        ; bit 32-39 Base
    db 0x9A     ; bit 40-47 Access byte
    db 0xCF     ; bit 48-55 Limit+Flags
    db 0        ; bit 56-63 Base
GDT32DATA:
    dw 0xFFFF   ; bit 0-15  Limit
    dw 0        ; bit 16-31 Base
    db 0        ; bit 32-39 Base
    db 0x92     ; bit 40-47 Access byte
    db 0xCF     ; bit 48-55 Limit+Flags
    db 0        ; bit 56-63 Base
GDT32END:

CodeSeg equ GDT32CODE-GDT32
DataSeg equ GDT32DATA-GDT32


; Protected mode
[bits 32]

ProtectedModeEntry:
    mov ax, DataSeg
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x90000

    mov eax, 0x10000    ; jump to 0x10000
    jmp eax

    jmp $
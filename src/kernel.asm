[BITS 32]
global _start

extern kernel_main
CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    mov ax, DATA_SEG
    mov es, ax
    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; this segemnt we are setting the AL20 line so that we could access any memory address,
    ; "in" and "out" are used to read/write from processor bus to immediate hardware
    in al, 0x92
    or al, 2
    out 0x92, al

    call kernel_main

    jmp $


times 512 - ($ - $$) db 0    
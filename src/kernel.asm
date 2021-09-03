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

    ;Remap the master PIC
    mov al, 00010001b; puts PIC in initialization mode
    out 0x20, al ; Tell master PIC

    mov al, 0x20 ; Interrupt 0x20 is where master ISR should start, right after Exception interrupts
    out 0x21, al

    mov al, 00000001b
    out 0x21, al
    ; End remap the Master PIC  

    ;Enable interrupts
    sti
       
    call kernel_main

    jmp $


times 512 - ($ - $$) db 0    
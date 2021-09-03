section .asm

extern init21h_handler
extern no_interrupt_handler

global init21h
global idt_load
global no_interrupt


idt_load:
    push ebp
    mov ebp, esp

    mov ebx, [ebp+8]
    lidt [ebx]
    pop ebp
    ret

;keyboard interrupt
init21h:
    cli
    ;push all orginal registers
    pushad
    call init21h_handler
    popad
    sti
    iret

no_interrupt:
    cli
    ;push all orginal registers
    pushad
    call no_interrupt_handler
    popad
    sti
    iret

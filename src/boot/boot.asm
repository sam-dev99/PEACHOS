org 0x7c00

bits 16

CODE_SEG  equ gdt_code - gdt_start
DATA_SEG  equ gdt_data - gdt_start
_start:
    jmp short start
    nop

;create 33 bytes after nop. these are our BIOS parameter block in case our BIOS starts
;corrupting it will corrupt these empty 33 bytes. see manual or ref.
times 33 db 0
start:
    ;for code segment to start at 0x7c0 we use jmp.
    jmp 0:step2 


step2:
    cli ;Clear interrupts
    ;we are going to change some register segments, so we clear all interrupts before hand 
    ; because we dont want any hardware failure
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax ; setstack segement to 0
    mov sp, 0x7c00  
    sti ; Enables interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32



;GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

;offset 0x8
gdt_code:       ;CS should point to this
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0        ; Base first 0-15 bits
    db 0        ;Base 16-23 bits
    db 0x9a     ;Access byte
    db 11001111b ; High 4bit flags and lower 4 bit flags
    db 0            ;Base 24-31 bits

;offset 0x10
gdt_data:       ;DS, SS, ES, GS FS
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0        ; Base first 0-15 bits
    db 0        ;Base 16-23 bits
    db 0x92     ;Access byte
    db 11001111b ; High 4bit flags and lower 4 bit flags
    db 0            ;Base 24-31 bits

gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

[BITS 32]
load32:
    ;sector number to start reading from aka our kernel
    mov eax, 1
    ; number of sectors to read that we set in make file to 100
    mov ecx, 100
    ; contain address that we need to load to which in this case is 1 M
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

; we need to write out own driver to interact with harddisk sectors now since we cant use the BIOS directly because we are in 
; protected mode now
ata_lba_read:
    mov ebx, eax ; backup the LBA
    ; Send the highest 8 bits of the lba to hard disk  controller
    shr eax, 24
    or eax, 0xE0 ; Select the master driver
    mov dx, 0x1F6
    out dx, al
    ; finished sending the highest 8 bits of lba

    ;Send the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ;Finished sending the total sectors to read

    mov eax, ebx ;Restoring the backup lba
    mov dx, 0x1F3
    out dx, al ; talking with the bus on motherboard
    ;Finished sending more bits of LBA

    mov dx, 0x1F4
    mov eax, ebx ; Restore the backup LBA
    shr eax, 8
    out dx, al
    ;Send uppped 16 bits of LBA
    mov dx, 0x1F5
    mov eax, ebx; Restore backup LBA
    shr eax, 16
    out dx, al; output to controller
    ;Finished sending 16 bits 

    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

    ;Read all sectors into memory

.next_sector:
    push ecx

;Checking if we need to read
.try_again:
    mov dx, 0x1F7 ; read from this port into al register
    in al, dx
    test al, 8 ; check for bitmask 8 
    jz .try_again ; if test fails

   ; we need to read 256 words at a time
   mov ecx, 256
   mov dx, 0x1F0
   rep insw ; reads 256 words from 0x1F0 port and insert in edi = 1M declared above
   pop ecx ; Restore ecx we saved. total number of sectors
   loop .next_sector
   
   ;End of reading sectors into memory
   ret  


times 510- ($ - $$) db 0
dw 0xAA55
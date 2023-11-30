ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

;Setup BPB (BIOS Parameter Block)
_start:
    jmp short start ; Standard start for BPB as you dont want to execute your params
    nop

times 33 db 0 ; Allocate BPB, empty initialised

start:
    jmp 0:step2 ; Set code segment to 0

step2:
    cli ; clear interrupts
    mov ax, 0x00
    mov ds, ax  ; setup data degment
    mov es, ax  ; setup Extra segment
    mov ss, ax  ; Set Stack segment to 0
    mov sp, 0x7c00 ; Set stack pointer
    sti ; enable interrupts
    


.load_protected:
    cli
    lgdt[gdt_descriptor] ; Load global descriptor table
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32

   ; Setup GDT (Global Descriptor table)
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code: ; CS shoud point to this
    dw 0xffff   ; Segment limit first 0-15 bite
    dw 0        ; Base first 0-15 bits
    db 0        ; Base 16-23 bits
    db 0x9a     ; Access byte
    db 11001111b    ; Permission flags, Ring level etc...
    db 0

; offset 0x10
gdt_data:       ; DS, SS, ES, FS, GS
    dw 0xffff   ; Segment limit first 0-15 bite
    dw 0        ; Base first 0-15 bits
    db 0        ; Base 16-23 bits
    db 0x92     ; Access byte
    db 11001111b    ; Permission flags, Ring level etc...
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp
    jmp $


times 510-($ - $$) db 0 ; Fill excess program data with zeros
dw 0xAA55 ; Add boot signature to end of the program        

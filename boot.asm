ORG 0
BITS 16

;Setup BPB (BIOS Parameter Block)
_start:
    jmp short start ; Standard start for BPB as you dont want to execute your params
    nop

times 33 db 0 ; Allocate BPB, empty initialised

start:
    jmp 0x7c0:step2 ; Set code segment to 0x7c0

step2:
    cli ; clear interrupts
    mov ax, 0x7c0
    mov ds, ax  ; setup data degment
    mov es, ax  ; setup Extra segment
    mov ax, 0x00
    mov ss, ax  ; Set Stack segment to 0
    mov sp, 0x7c00 ; Set stack pointer
    sti ; enable interrupts
    
    mov ah, 0x02
    mov al, 0x01
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov bx, buffer
    int 0x13
    jc error
    mov si, buffer
    call print
    jmp end

error:
    mov si, error_message
    call print

end:
    jmp $ ; infinate loop

print:
    mov bx,0 
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

error_message: db 'Failed to Load Sector', 0

times 510-($ - $$) db 0 ; Fill excess program data with zeros
dw 0xAA55 ; Add boot signature to end of the program

buffer: ; Buffer to point at the end of our memory, the memory is added with dd in the Makefile
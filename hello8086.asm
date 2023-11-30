
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
           
jmp main 
message: db 'Hello World!', 0

print_char:

print:
    mov ah, 0eh  ; BIOS command to output chars
._loop:
    lodsb  ; load si into al then increment si pointer
    cmp al, 0
    je .done  ; jmp if equal to zero if al is at the -0 terminator
    int 10h
    jmp ._loop
.done:
    ret

main:
    mov si, message  ; load msg address into si
    call print


ret





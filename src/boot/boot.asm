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
    mov eax, 1
    mov ecx, 100
    mov edi, 0x100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax ; backup the LBA
    ; Send the highest 8 bits of the lba to the hard disk controller
    shr eax, 24
    or eax, 0xE0 ; Select the master drive
    mov dx, 0x1F6
    out dx, al
    ; Finshed sending the highest 8 bits of the lba

    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; Finsiehd sengint the total sectors the read

    mov eax, ebx ; restore the backup LBA
    mov dx, 0x1F3
    out dx, al
    ; Finsihed sending more bit od the LBA

    mov dx, 0x1F4
    mov eax, ebx ; restore the backup LBA
    shr eax, 8
    out dx, al
     ; Finsihed sending more bit od the LBA

     ; Send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx,al 
    ; Finsihed sengint upper 16 bts of the LBA

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; Read all sectors into memory
.next_sector:
    push ecx

; Checking if we need to read
.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again

; We need to read 256 words (1 sector) at a time 
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ; End of reading sectors into memory
    ret

times 510-($ - $$) db 0 ; Fill excess program data with zeros
dw 0xAA55 ; Add boot signature to end of the program        

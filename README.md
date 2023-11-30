# Kernel Course Notes

## Overview

CPU start by loading BIOS ROM
BIOS loads real mode, small 16 bit env, 1MB accessible RAM, origin x86 design(1970s!), no security, here is the bootloader
BIOS runs a standard set of simple instruction set in the 16bit env
Bootloader loads the kernel (grub, uboot etc…)
BIOS runs mandatory drivers, looks for boot signature 0x55AA from (USB, harddisks etc…)

# Real mode development

## Assembly 8086
General 16 bit registered ax,bx,cx,dx. Ah al refers to high and low bytes
```
IP = program counter
DS = Data segment, memory access has this offset * block size (16)
CS = Code segment, like the DS, offset for the program counter * Block size (16)
SP = stack pointer
SS = segment for the stack pointer
ES = Extra segment
```

SI = source index, address for BIOS command routines like:
Lodsb - Load data  pointed to by DS+SI into al and increment si
Cmp al, 0 - compare al to zero
Je - optional jump

.label: only applies to the label above them

DOS docs https://www.ctyme.com/rbrown.htm

OS dev info on USB booting https://wiki.osdev.org/FAT

## Building and running assembly
```
nasm -f bin ./boot.asm -o ./boot.bin
qemu-system-x86_64 -hda ./boot.bin
```

## Interrupt Vector table
Old state gets saved on the stack, then interupt executed

256 interrupt handlers with pointers to code segment (2 bytes) + offset (2 bytes)

https://wiki.osdev.org/Exceptions

## Disk access

Format of the disk contols how it must be interpreted, usually in block on 512 bytes

CHS old style 

LBA, logical block address, newer and simpler style of addressing. Block address is the index of the 512 byte blocks.

In real mode, int 13h is for disk operations

https://www.ctyme.com/intr/rb-0607.htm

# Protected mode

https://wiki.osdev.org/Protected_Mode

4GB addressable memory. 32 bit instructions and 32bit numbers

Memory and hardware protection:
 - Ring 0, Kernel access to ALL memory!
 - Ring 1, device drivers
 - Ring 2, device drivers
 - Ring 3, User space for applications. Cannot modify kernel memory, cannot access hardware with asking kernel

 Different memory schemes
 - Segment registers are now selector registers
 - Paging: remapping memory addresses

 ## Selector memory scheme

 selectors point to data structures and permission requirements

 ## Paging schemes

 - virtual addresses mapped to physical addresses
 - Allows all programs to beleive they are using address 0
 - Maps out all programs to physical memory

 ## Running with GDB

```
gdb
target remote | qemu-system-x86_64 -hda ./boot.bin -S -gdb stdio
```
Look at raw 
```
layout asm
```
Look at registers
```
info registers
```


## Assembly 32 bit registers

Data registers: extended 32 bit versions. lower halfs still pointed to by ax,bx etc...
```
EAX
EBX
ECX
EDX
```
Pointer registers:
```
IP - Instruction Pointer
ESP - Extended Stack Pointer
EBP - Extented Base pointer
```
Index Registers
```
ESI - Extended Source index
EDI - Extended Destination Index
```
Control Registers
```
OF - Overflow Flag
DF - Direction Flag
IF - Interrupt Flag
TF - Trap Flag
SF - Sign Flag
ZF - Zero Flag
AF - Auxillery Carry Flag
PR - Parity Flag
CF - Carry Flag
```
Segment Registers (same as 16 bit)
```
CS - Code segment
DS - Data Segment
SS - Stack Segment
```
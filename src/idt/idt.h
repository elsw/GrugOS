#ifndef IDT_H
#define IDT_H
#include <stdint.h>

//See https://wiki.osdev.org/Interrupt_Descriptor_Table

struct idt_desc
{
    uint16_t offset_1; //offset bits 0 - 15
    uint16_t selector; // selector thins in our GDT 
    uint16_t zero; 
    uint16_t type_attr; // descriptor type and attrributes
    uint16_t offset_2; // Offset bite 16 - 31
} __attribute__((packed));

struct idtr_desc
{
    uint16_t limit; // Size of descriptor table -1 
    uint16_t base; // base address of the start of the interrupt descriptor table
} __attribute__((packed));

#endif

void idt_init();

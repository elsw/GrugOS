#include "idt.h"
#include "config.h"
#include "memory.h"
#include "kernel.h"

struct idt_desc idt_descriptors[GRUGOS_TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;

extern void idt_load(struct idtr_desc* ptr);

//Interupt zero is the divide by zero error
void idt_zero()
{
    print("Divide by zero error\n");
}

//Setup one interrupt in the interrupt description table
void idt_set(int interrupt_num, void *address)
{
    struct idt_desc* desc = &idt_descriptors[interrupt_num];
    desc->offset_1 = (uint32_t) address & 0x0000FFFF;
    desc->selector = KERNEL_CODE_SELECTOR;
    desc->zero = 0x00;
    desc->type_attr = 0xEE;//Set Gate Type,Set Storage Segment, Descriptor priveledge level & preset
                            //See Gate desciptor under https://wiki.osdev.org/Interrupt_Descriptor_Table
    desc->offset_2 = (uint32_t) address >> 16;
}

//Initialise the Interupt description tables
void idt_init()
{
    memset(idt_descriptors, 0 , sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t) idt_descriptors;

    idt_set(0, idt_zero);

    //load the interrupt description table
    idt_load(&idtr_descriptor);
}
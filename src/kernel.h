#ifndef KERNEL_H
#define KERNEL_H

#define VGA_WIDTH 80
#define VGA_HEIGHT 20

void print(const char *str);
void print_colour(const char *str, const char colour);

void kernel_main();

#endif
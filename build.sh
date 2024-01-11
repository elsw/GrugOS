#!/bin/bash
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
mkdir build
mkdir bin
mkdir build/memory
mkdir build/idt
make all
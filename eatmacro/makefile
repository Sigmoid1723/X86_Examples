eatmacro: eatmacro.o
		ld -o eatmacro eatmacro.o -m elf_i386

eatmacro.o: eatmacro.asm
		nasm -f elf -g -F stabs eatmacro.asm -l eatmacro.lst

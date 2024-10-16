eatterm: eatterm.o
		ld -o eatterm eatterm.o -m elf_i386

eatterm.o: eatterm.asm
		nasm -f elf -g -F stabs eatterm.asm -l eatterm.lst

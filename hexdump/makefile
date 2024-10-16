hexdump: hexdump.o
		ld -o hexdump hexdump.o

hexdump.o: hexdump.asm
		nasm -f elf64 -g -F stabs hexdump.asm -l hexdump.lst

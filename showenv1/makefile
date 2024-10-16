showenv1: showenv1.o
		ld -o showenv1 showenv1.o -m elf_i386

showenv1.o: showenv1.asm
		nasm -f elf -g -F stabs showenv1.asm -l showenv1.lst

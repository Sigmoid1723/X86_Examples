newsandbox: newsandbox.o
		ld -o newsandbox newsandbox.o

newsandbox.o: newsandbox.asm
		nasm -f elf64 -g -F stabs newsandbox.asm -l newsandbox.lst

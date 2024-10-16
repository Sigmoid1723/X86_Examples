uppercaseerror: uppercaseerror.o
		ld -o uppercaseerror uppercaseerror.o

uppercaseerror.o: uppercaseerror.asm
		nasm -f elf64 -g -F stabs uppercaseerror.asm -l uppercaseerror.lst

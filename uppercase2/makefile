uppercase2: uppercase2.o
		ld -o uppercase2 uppercase2.o

uppercase2.o: uppercase2.asm
		nasm -f elf64 -g -F stabs uppercase2.asm -l uppercase2.lst

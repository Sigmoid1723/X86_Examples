showargc: showargc.o
		gcc -m32 -o showargc showargc.o

showargc.o: showargc.asm
		nasm -f elf32 -g -F stabs showargc.asm -l showarc.lst

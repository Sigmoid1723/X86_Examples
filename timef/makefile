timef: timef.o
		gcc -m32 -o timef timef.o

timef.o: timef.asm
		nasm -f elf32 -g -F stabs timef.asm -l timef.lst

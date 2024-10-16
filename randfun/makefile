randfun: randfun.o
		gcc -m32 randfun.o -o randfun

randfun.o: randfun.asm
		nasm -f elf32 -g -F stabs randfun.asm -l randfun.lst

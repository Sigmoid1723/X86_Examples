t5: textfile.o
		gcc -o t5 textfile.o -m32

textfile.o: textfile.asm
		nasm -f elf32 -g -F stabs textfile.asm -l textfile.lst

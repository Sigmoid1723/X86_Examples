charinput: charinput.o
		gcc -m32 -o charinput charinput.o

charinput.o: charinput.asm
		nasm -f elf32 -g -F stabs charinput.asm -l charinput.lst

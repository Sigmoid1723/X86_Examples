eatclib: eatclib.o
		# ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o eatclib -lc eatclib.o
		gcc -m32 -o eatclib eatclib.o 

eatclib.o: eatclib.asm
		nasm -f elf32 -g -F stabs eatclib.asm -l -eatclib.lst

#need to install gcc-multilib package
# sudo apt-get install gcc-multilib

dateis: dateis.o dateis.lst dateis2.lst
		gcc -o dateis dateis.o -m32

dateis.lst: dateis.s
		# objdump -d dateis.o > dateis.lst
		gcc -Wa,-adhln -g -m32 dateis.s> dateis.lst

dateis2.lst: dateis2.s
		gcc -g -Wa,-adhln -m32 dateis2.s> dateis2.lst
		# objdump -d -j . -M intel dateis.o > dateis2.lst
		# gcc -g -c -m32 -masm=intel dateis.c > dateis2.lst
		rm -f a.out

dateis.o: dateis.s
		gcc -c -m32 dateis.s -o dateis.o 

dateis.s: dateis.c
		gcc -S dateis.c -o dateis.s -m32

dateis2.s: dateis.c
		gcc -S -masm=intel dateis.c -o dateis2.s -m32

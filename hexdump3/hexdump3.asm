    ;    Run it this way:
    ;    
    ;    hexdump < (input file)
    ;
    ;    Build using these commands:
    ;    
    ;    nasm -f elf64 -g -F stabs hexdump.asm -l hexdump.asm
    ;    ld -o hexdump hexdump.o
    
section .bss

    BUFFLEN equ 10              ;16 len buffer
Buff: resb BUFFLEN              ;text buffer

section .data
section .text

    extern Clearline, DumpChar,Printline
 
global _start

    ;-------------------------------------------------------------------------
    ; main program starts here
    ;-------------------------------------------------------------------------

_start:
    nop                         ;gdb happy noises

    ;initialization before loop Scan starts here
    xor esi,esi                 ;clear esi
    
Read:
    mov eax,3                   ;specify sys_read call
    mov ebx,0                   ;specify file descriptor 0,stdin
    mov ecx,Buff                ;store buffer address
    mov edx,BUFFLEN             ;number of character to read
    int 80h                     ;call sys_read
    
    mov ebp,eax                 ;save number of character for later use
    cmp eax,0                   ;if eax=0 it reached EOF
    je Done                     ;exit
    
    xor ecx,ecx                 ;clear xor register

    ;go through buffer and convert binary value to hexdigits
Scan:
    xor eax,eax                 ;clear eax
    mov al,byte[Buff+ecx]       ;get a byte from buffer to al
    mov edx,esi                 ;copy total count to edx
    and edx,0000000fh           ;mask lowest bit for character counter
    call DumpChar               ;call the poke procedure

    ;bump to next character till it's done
    inc esi                     ;increment character procedure
    inc ecx                     ;increment buffer pointer
    cmp ecx,ebp                 ;compare with number of characters
    jae Read                    ;if we got the buffer go back

    test esi,0000000fh          ;test lower 4 bits of counter
    jnz Scan                    ;Scan if not zero
    call Printline              ;call printline
    call Clearline              ;clear the line
    jmp Scan                    ;next Scan for buffer

Done:
    call Printline              ;print any lefovers
    mov eax,1                   ;code for exit syscall
    mov ebx,0                   ;return code for 0
    int 80h                     ;make kernel call

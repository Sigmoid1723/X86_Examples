;    Run it this way:
;    
;    hexdump < (input file)
;
;    Build using these commands:
;    
;    nasm -f elf64 -g -F stabs hexdump.asm -l hexdump.asm
;    ld -o hexdump hexdump.o
    
section .bss

    BUFFLEN equ 16              ;16 len buffer
    Buff: resb BUFFLEN              ;text buffer

section .data

    Hexstr: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10
    HEXLEN equ $-Hexstr

    Digits: db "0123456789ABCDEF"

section .text

global _start

_start:
    nop                         ;keep gdb start at first instruction so uninitialized values(assuming)

    ;Read buffer text full of data
Read:
    mov eax,3                   ;specify sys_read call
    mov ebx,0                   ;specify file descripter 0,stdin
    mov ecx,Buff                ;pass buffer address
    mov edx,BUFFLEN             ;number of bytes to read from
    int 80h                     ;sys_read call
    mov ebp,eax                 ;save number of files read for later
    cmp eax,0                   ;if eax =  0 then it reached EOF
    je Done                     ;jump for exit

    ;setup register for process buffer steps
    mov esi,Buff                ;move Buff address to esi
    mov edi,Hexstr              ;place address of Hexstring to edi
    xor ecx,ecx                 ;clear ecx register

Scan:
    xor eax,eax                 ;clear eax register

    ;calculate the offset in hexstr, which is value in ecx X 3
    mov edx,ecx                 ;copy character counter to edx
    shl edx,1                   ;multiply pointer by 2 using left shift
    add edx,ecx                 ;complete the multiplication x3

    ;get character from buffer and put in eax and ebx
    mov al,byte [esi+ecx]       ;put the byte from input buffer to al
    mov ebx,eax                 ;duplicate byte from bl for second nybble

    ;look up low nybble and insert into string
    and al,0fh                  ;mask out all but low nybble
    mov al,byte [Digits+eax]    ;look up the character value
    mov byte [Hexstr+edx+2],al     ;write lsb character digit to line string

    ;look up high nybble character insert into string
    shr bl,4                    ;shift high 4 bits into low 4 bits
    mov bl,byte[Digits+ebx]     ;lookup character equivelent to nybble
    mov byte [Hexstr+edx+1],bl  ;write most significant byte to string

    ;bump pointer to next character and see if we are done:
    inc ecx                     ;increment line in pointer
    cmp ecx,ebp                 ;compare to number of character in buffer
    jna Scan                    ;loop back ecx <= characters in buffer

    ;write the hex value
Write:
    mov eax,4                   ;specify sys_write call
    mov ebx,1                   ;specify file descripter 1,stdin
    mov ecx,Hexstr              ;pass address of Hexstr
    mov edx,HEXLEN              ;pass length of HexStr
    int 80h                     ;call sys_write
    jmp Read                    ;jump to read for other 16 bits

    ;lets exit its all done
Done:
    mov eax,1                   ;specify sys_exit call
    mov ebx,0                   ;specify return value 0
    int 80h                     ;call sys_exit 

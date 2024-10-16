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

Dumplin: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
    DUMPLEN equ $-Dumplin
    
Asclin: db "|................|",10
    ASCLEN equ $-Asclin
    FULLLEN EQU $-Dumplin
    
Hexdigits: db "0123456789ABCDEF"

    ;character for ascill presentation where other unwanted character set to '.'
    
DOTXLAT:
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
    db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
    db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
    db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
    db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh

section .text

    ;-------------------------------------------------------------------------
    ; ClearLine: Clear a hex dump line string to 16 0 values
    ; UPDATED: 25/06/2023
    ; IN:Nothing
    ; RETURNS: Nothing
    ; MODIFIES: Nothing
    ; CALLS:DumpChar
    ; DESCRIPTION: The hex dump line string is cleared to binary 0 by
    ; calling DumpChar 16 times, passing it 0 each time.

Clearline:
    pushad                      ;save all caller's GP register
    mov edx,15                  ;16 pokes counting from 0

.poke:
    mov eax,0                   ;tell dump character to poke at 0
    call DumpChar               ;instert '0' into hexdump string
    sub edx,1                   ;decrement doesn't set CF
    jae .poke                   ;loop back till edx >= 0
    popad                       ;restore all character GP register
    ret                         ;go home

    ;-------------------------------------------------------------------------
    ; DumpChar:“Poke“ a value into the hex dump line string.
    ; UPDATED:25/06/2023
    ; IN:Pass the 8-bit value to be poked in EAX.
    ; Pass the value’s position in the line (0-15) in EDX
    ; RETURNS:Nothing
    ; MODIFIES:EAX, ASCLin, DumpLin
    ; CALLS:Nothing
    ; DESCRIPTION: The value passed in EAX will be put in both the hex dump
    ; portion and in the ASCII portion, at the position passed
    ; in EDX, represented by a space where it is not a
    ; printable character.

DumpChar:
    push ebx                    ;save caller's ebx
    push edi                    ;save caller's edi

    ;insert the ascii portion of the dump line
    mov bl,byte[DOTXLAT+eax]    ;translate non printable to '.'
    mov byte[Asclin+edx+1],bl   ;write to ascii portion

    ;insert hex equivalent of input to hexportion
    mov ebx,eax                 ;save second copy of input characters
    lea edi,[edx*2+edx]         ;multiply offset by 3

    ;lookup low nybble character and instert into string
    and eax,0000000fh           ;mask out all low nybble
    mov al,byte[Hexdigits+eax]  ;look up character equivalent to string
    mov byte[Dumplin+edi+2],al  ;write chracter equivalent to line string

    ;lookup high nybble character and instert into string
    and ebx,000000f0h           ;mask out all but high nybble
    shr ebx,4                   ;shift high  4 bites to low 4 bits
    mov bl,byte[Hexdigits+ebx]  ;look up character equivalent to string
    mov byte[Dumplin+edi+1],bl  ;write chracter equivalent to line string

    ;Done go home
    pop edi                     ;Restore caller's edi
    pop ebx                     ;Restore caller's ebx
    ret                         ;return to caller

    ;-------------------------------------------------------------------------
    ; PrintLine:Displays DumpLin to stdout
    ; UPDATED:25/06/2023
    ; IN:Nothing
    ; RETURNS:Nothing
    ; MODIFIES:Nothing
    ; CALLS:Kernel sys_write
    ; DESCRIPTION: The hex dump line string DumpLin is displayed to stdout
    ; using INT 80h sys_write. All GP registers are preserved.
    
Printline:
    pushad                      ;save all GP register
    mov eax,4                   ;specify sys_write call
    mov ebx,1                   ;specify file descriptor 1, stdout
    mov ecx,Dumplin             ;pass address to ecx
    mov edx,FULLLEN             ;size of line string
    int 80h                     ;call sys_write
    popad                       ;restore all GP register
    ret                         ;return to caller

    ;-------------------------------------------------------------------------
    ; LoadBuff:Fills a buffer with data from stdin via INT 80h sys_read
    ; UPDATED:25/05/2023
    ; IN:Nothing
    ; RETURNS:# of bytes read in EBP
    ; MODIFIES:ECX, EBP, Buff
    ; CALLS:Kernel sys_write
    ; DESCRIPTION: Loads a buffer full of data (BUFFLEN bytes) from stdin
    ; using INT 80h sys_read and places it in Buff. Buffer
    ; offset counter ECX is zeroed, because we’re starting in
    ; on a new buffer full of data. Caller must test value in
    ; EBP: If EBP contains zero on return, we hit EOF on stdin.
    ; Less than 0 in EBP on return indicates some kind of error.

Loadbuff:
    push eax                    ;save caller's eax
    push ebx                    ;save caller's ebx
    push edx                    ;save caller's edx
    mov eax,3                   ;specify sys_read call
    mov ebx,0                   ;specify file descriptor 0,stdin
    mov ecx,Buff                ;store buffer address
    mov edx,BUFFLEN             ;number of character to read
    int 80h                     ;call sys_read
    mov ebp,eax                 ;save number of character for later use
    xor ecx,ecx                 ;clear xor register
    pop edx                     ;restore caller's edx
    pop ebx                     ;restore caller's ebx
    pop eax                     ;restore caller's eax
    ret                         ;return to caller

global _start

    ;-------------------------------------------------------------------------
    ; main program starts here
    ;-------------------------------------------------------------------------

_start:
    nop                         ;gdb happy noises

    ;initialization before loop Scan starts here
    xor esi,esi                 ;clear esi
    call Loadbuff               ;read first buffer data form stdin
    cmp ebp,0                   ;if ebp=0 it reached EOF
    jbe Exit                    ;exit

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
    jb .modtest                 ;if we processed all character in buffer
    call Loadbuff               ;..fill buffer again
    cmp ebp,0                   ;if ebp=0 it reached EOF
    jbe Done                    ;done

.modtest:
    test esi,0000000fh          ;test lower 4 bits of counter
    jnz Scan                    ;Scan if not zero
    call Printline              ;call printline
    call Clearline              ;clear the line
    jmp Scan                    ;next Scan for buffer

Done:
    call Printline              ;print any lefovers

Exit:
    mov eax,1                   ;code for exit syscall
    mov ebx,0                   ;return code for 0
    int 80h                     ;make kernel call

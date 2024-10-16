section .data                   ;section containing initialized data

Statmsg: db "Processing ...",10
    Statlen equ $-Statmsg
Donemsg: db "...done!",10
    Donelen equ $-Donemsg

    ;translation table

Upcase:
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
    db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
    db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
    db 60h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,7Bh,7Ch,7Dh,7Eh,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h

    ;Custom table
Custom:
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
    db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
    db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
    db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
    db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h

section .bss

    READLEN equ 1024            ;buffersize
Buff: resb READLEN              ;reserve bytes 1024

section .text

global _start

_start:

    nop                         ;keep debugger happy

    ;Display "i'm working via stderr"
    mov eax,4                   ;specify sys_write call
    mov ebx,2                   ;specify file descriptor 2,stderr
    mov ecx,Statmsg             ;pass offset message to register
    mov edx,Statlen             ;number of length to msg
    int 80h                     ;make sys_write call

    ;read buffer full of text from stdin
Read:
    mov eax,3                   ;specify sys_read call
    mov ebx,0                   ;specify file descriptor 0,stdin
    mov ecx,Buff                ;pass buffer address
    mov edx,READLEN             ;pass number of character to read
    int 80h                     ;make sys_read call

    mov ebp,eax                 ;copy read value for safekeeping
    cmp eax,0                   ;if = 0 then it reached EOF
    je Done                     ;finish the thing

    ;setup register for translation step
    mov ebx,Upcase              ;place address to ebx
    mov edx,Buff                ;put address of buffer to edx
    mov ecx,ebp                 ;put number of bytes into the ecx

Translate:
    xor eax,eax                 ;clear eax
    mov al,byte[edx+ecx]        ;load character into al
    mov al,byte[Upcase+eax]     ;put translated character into al
    xlat                        ;translate character in al via table(al + ebx)
    mov byte[edx+ecx],al       ;put back character after translation
    dec ecx                     ;decrement the ecx
    jnz Translate               ;jump back till not 0

Write:
    mov eax,4                   ;specify sys_write call
    mov ebx,1                   ;specify file descriptor 1,stdout
    mov ecx,Buff                ;put buffer address
    mov edx,READLEN             ;number of character to output
    int 80h                     ;make sys_write call
    jmp Read                    ;jump back for next read

Done:
    mov eax,4                   ;specify sys_write call
    mov ebx,2                   ;specify file descriptor 2,stderr
    mov ecx,Donemsg             ;pass Donemsg address
    mov edx,Donelen             ;pass number of characters to print
    int 80h                     ;make sys_write call

    ;put an end to this
    mov eax,1                   ;code for Exit syscall
    mov ebx,0                   ;return value 0
    int 80h                     ;exit call

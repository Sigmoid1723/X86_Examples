section .bss
    Buff resb 1

section .data

section .text
global _start

_start:
    nop                         ;for debugger
Read: mov eax,3                 ;specify sys_read call
    mov ebx,0                   ;specify file descripter 0, stdin
    mov ecx,Buff                ;pass Buff address to ecx
    mov edx,1                   ;tell sys_read to read one character from stdin
    int 80h                     ;call sys_read

    cmp eax,0                   ;compare sys_read return value
    je Exit                     ;jump to exit if equal to 0
    ;fall thourgh next instruction

    cmp byte [Buff],61h         ;test input character against lowercase 'a'
    jb Write                    ;If below than 'a' then not lowercase
    cmp byte [Buff],7ah         ;test input character against lowercase 'z'
    ja Write                    ;If above than 'z' then not lowercase
    ;we have lowercase character only now

    sub byte [Buff],20h         ;substaract 20h from buff character
    ;write out to stdout now

Write: mov eax,4                ;specify sys_write call
    mov ebx,1                   ;specify file decripter 1, stdout
    mov ecx,Buff                ;pass address of character to write
    mov edx,1                   ;pass number of characters to write
    int 80h                     ;call sys_write
    jmp Read                    ;jump to Read to read another character

Exit:mov eax,1                  ;specify sys_exit call
    mov ebx,0                   ;specify return value 0
    int 80h                     ;call sys_exit
    

section .bss

    Bufflen equ 1024            ;buffer lenght 1024 bytes
Buff: resb Bufflen              ;reserve bufflen bytes

section .data

section .text

global _start

_start:
    nop                         ;keep gdb happy

    ;read buffer full of text form stdin

Read:
    mov eax,3                   ;specify sys_read call
    mov ebx,0                   ;specify file descripter 0:stdin
    mov ecx,Buff                ;pass offset of the buffer to read through(address)
    mov edx,Bufflen             ;number of bytes i want to read
    int 80h                     ;calls sys_read
    mov esi,eax                 ;copy sys_read return value for safekeeping
    cmp eax,0                   ;if eax=0,sys_read reached EOF
    je Done                     ;jump if equal to compare

    ;setup register to process buffer steps
    mov ecx,esi                 ;place the number of bytes read into the stack
    mov ebp,Buff                ;place address of the buffer into ebp
    dec ebp                     ;adjust count to offset

    ;Go through buffer and covert lowercase to uppercase

Scan:
    ; dec ecx
    cmp byte [ebp+ecx],61h      ;compare with lowercase 'a'
    jb Next                     ;jump if below
    cmp byte [ebp+ecx],7ah      ;compare with lowercase 'z'
    ja Next                     ;jump if above
    sub byte [ebp+ecx],20h           ;subtarcact the 20h form lowercase to reach uppercase

Next:
    dec ecx                     ;Decrement counter
    ; cmp ecx,0
    jnz Scan                    ;jump till it reaches to zero

    ;write the buffer full of processed text

Write:
    mov eax,4                   ;specify sys_write call
    mov ebx,1                   ;specify file descripter 1, stdin
    mov ecx,Buff                ;where we want to write
    mov edx,esi                 ;pass the number of bytes data in the buffer
    int 80h                     ;call sys_write
    jmp Read                    ;jmp to read more characters

    ;now its done let's finish

Done:
    mov eax,1                   ;specify sys_exit call
    mov ebx,0                   ;specify sys_exit return 0
    int 80h                     ;call sys_exit

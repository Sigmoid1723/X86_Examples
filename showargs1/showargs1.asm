section .data

    Errmsg db "Terminated with error.",10
    ERRLEN equ $-Errmsg

section .bss

    MAXARGS equ 10              ;maximum number of argument we support
Argcount: resd 1                ;# of argument passed to program
Argptrs: resd MAXARGS           ;table of pointers to argument
Arglens: resd MAXARGS           ;table of argument list

section .text

global _start

_start:

    nop                         ;keep gdb happy

    ;get the argument count in ecx and validate
    pop ecx                     ;TOS contain argument and we pop in in ecx
    cmp ecx,MAXARGS             ;see if arg count exceeds maxargs
    ja Error                    ;if more the error
    mov dword[Argcount],ecx     ;save argcount in memory varaiable

    ;once we know how many args are there loop will pop into argptrs
    xor edx,edx                 ;clear edx loop counter
Saveargs:
    pop dword[Argptrs + edx*4]  ;pop an arg adress into memory table
    inc edx                     ;increment of next counter
    cmp edx,ecx                 ;compare till number of argument
    jb Saveargs                 ;if not loop back furthure

    ;with argptrs stored,time to calculate their lenghts
    xor eax,eax                 ;clear eax for searching 0 byte(since each string terminated with one 0 byte)
    xor ebx,ebx                 ;pointer table offset address starts at 0

Scanone:
    mov ecx,0000ffffh           ;limit search to 65535 byte maxargs
    mov edi,dword [Argptrs+ebx*4] ;put address of string to serach in edi
    mov edx,edi                   ;copy stirng address to edx
    cld                           ;clear direction flag
    repne scasb                   ;repeat till 0 encounter
    jnz Error                     ;it didn't find 0
    mov byte[edi-1],10            ;store EOL where 0 was there
    sub edi,edx                   ;subset positon of 0 form last address
    mov dword[Arglens+ebx*4],edi  ;put length of argument in table
    inc ebx                       ;add 1 to argument counter
    cmp ebx,[Argcount]            ;see if exceeds argcount
    jb Scanone                    ;if not loop back for another one

    ;Display argument to stdout
    xor esi,esi                 ;start at 0(for table adressing reasons)
Showem:
    mov ecx,[Argptrs+esi*4]     ;pass offset to message
    mov eax,4                   ;specify sys_write call
    mov ebx,1                   ;specify file descriptor 1,stdout
    mov edx,[Arglens+esi*4]     ;pass length of message
    int 80h                     ;make kernel call
    inc esi                     ;increment for next argument
    cmp esi,[Argcount]          ;see if we displayed all arguments
    jb Showem                   ;if not loop countinues
    jmp Exit                    ;we finish we exit

Error:
    mov eax,4                   ;mention sys_write call
    mov ebx,2                   ;specify file descriptor 2,stderr
    mov ecx,Errmsg              ;mention Errmsg address
    mov edx,ERRLEN              ;mention error length
    int 80h                     ;make kernel call

Exit:
    mov eax,1                   ;specify sys_exit call
    mov ebx,0                   ;specify return value 0
    int 80h                     ;kernel call for sys_exit
    

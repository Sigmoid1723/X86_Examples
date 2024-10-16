section .data

    Errmsg db "Terminated with error.",10
    ERRLEN equ $-Errmsg

section .bss

    MAXENV equ 300             ;maximum number of enviournment we support
Envlen: resd MAXENV           ;table of pointers to enviournment

section .text

global _start

_start:

    nop                         ;keep gdb happy

    ;get the enviournment count in ecx and validate
    mov ebp,esp                   ;move stack pointer to base ponter
    xor eax,eax                   ;clear eax loop counter

; FindEnv:
    ; mov ecx,0000ffffh           ;limit search   
    ; mov edi,ebp                 ;put address of string
    ; mov edx,edi                 ;copy string address
    ; cld                         ;set flag
    ; repne scasb                 ;scan null ptr in string at edi
    ; jnz Error                   ;ended with finding at edi
    ; mov ebp,edi                 ;env address begin after null ptr
    ; xor ebx,ebx                 ;zero ebx for other use

    pop ecx                     ;pop value into ecx
    lea ebp,[ebp+ecx*4+8]       ;args address ecx * 4 + null 4 + argcount 4
    ; add ebp,4                   ;skip argument
; FindEnv:
;     add ebp,4                   ;skip argumnet adress
;     dec ecx                     ;dec argcount
;     cmp ecx,0                   ;compare argument list
;     jnz FindEnv                 ;repeat till 0
;     add ebp,4                   ;remove null string
    
    ;we now know the address
Scanone:
    mov ecx,0000ffffh           ;limit search to 65535 byte maxenvs
    mov edi,dword [ebp+ebx*4] ;put address of string to serach in edi
    cmp edi,0                 ;see if we hit second pointer
    je Showem                 ;if yes then show them all
    mov edx,edi               ;copy stirng adress to edx
    cld                       ;set flag
    repne scasb               ;search for 0 at end
    jnz Error                 ;ended failed
    mov byte[edi-1],10        ;put EOL where 0
    sub edi,edx               ;sub for length
    mov dword[Envlen+ebx*4],edi ;put length into table
    inc ebx                     ;add 1 env into table
    jmp Scanone                 ;loopback for another

    ;Display enviournment to stdout
    xor esi,esi                 ;start at 0(for table adressing reasons)
Showem:
    mov ecx,[ebp+esi*4]     ;pass offset to message
    mov eax,4                   ;specify sys_write call
    mov ebx,1                   ;specify file descriptor 1,stdout
    mov edx,[Envlen+esi*4]     ;pass length of message
    int 80h                     ;make kernel call
    inc esi                     ;increment for next enviournment
    cmp dword[ebp+esi*4],0          ;see if we displayed all enviournments
    jne Showem                   ;if not loop countinues
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
    

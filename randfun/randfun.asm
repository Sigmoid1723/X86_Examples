[section .data]

Nstring: db "Your Number is: %x",10,0
Cstring: db "-0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM@"

[section .bss]

    RTbuff resb 4
    Bufflen equ $-RTbuff

[section  .text]

extern rand
extern srand
extern printf
extern time
extern puts
global main
    
pull32:    
    mov ecx,0                   ;for 31-bit random number we don't shift since wa want all 32 bits
    call rand                   ;call rand function
    ret
pull6:    
    call rand                   ;call rand function
    shl eax,26                  ;take the last 6 bytes only
    shr eax,26                  ;take the last 6 bytes only
    
    ret                         ;go home

main:
    push ebp                    ;create frame
    mov ebp,esp                 ;save stack pointer
    push ebx                    ;save all register
    push esi
    push edi

;; boiler plate above

    push dword 0                ;pass null pointer
    call time                   ;call time function
    add esp,4                   ;clear stack

    push eax                    ;push the time we recived
    call srand                  ;call srand function
    add esp,4                   ;clears stack

    call pull32                 ;call the pull32
    push eax                    ;call whatever number we got for print
    push Nstring                ;pass string
    call printf                 ;call printf
    add esp,8                   ;clear stack

    push dword 0                ;pass null pointer
    call time                   ;call time function
    add esp,4                   ;clear stack

    push eax                    ;push the time we recived
    call srand                  ;call srand function
    add esp,4                   ;clears stack

    mov ebx,Bufflen             ;put length to ebx
Charloop:
    dec ebx                     ;decrement so we can add since base 0
    call pull6                  ;get 6 digit random number
    mov cl,[eax+Cstring]        ;get that value
    mov [ebx+RTbuff],cl         ;put that in buffer
    cmp ebx,0                   ;check if ebx is 0
    jne Charloop                ;jump till not 0
    
    push RTbuff                 ;push buffer address
    call puts                   ;call puts to display
    add esp,4                   ;clear stack
    
;;boiler plate below

    pop edi                     ;restore registers
    pop esi
    pop ebx
    mov esi,ebp                 ;put pointer end of stack frame
    pop ebp                     ;destroy frame
    ret                         ;return to linux

[section .data]

Iprompt: db "Enter the number you want to display:",0
Intformat: db "%d",0
Displayprompt: db "Your number is: %d",10,0
Tprompt: db "Enter the text you want to enter(72 char) followed by enter: ",0
Tdprompt: db "The text you enterd was: %s",10,0

[section .bss]

    Intval resd 1                   ;reserve word
    Maxchar resb 128                ;reserve 92 characters for text

[section .text]                 ;section contain code

extern fgets
extern stdin
extern scanf
extern printf
global main

main:
    push ebp                    ;make hook
    mov ebp,esp                 ;save esi value
    push ebx                    ;save registers
    push esi
    push edi

;;boiler plate above

    
    push Tprompt                ;put address for prompt
    call printf                 ;call printf
    add esp,4                   ;clean up stack

    push dword [stdin]          ;pass stdin for fgets
    push 72                     ;show 72 charcter only
    push Maxchar                ;put address where we want to store this
    call fgets                  ;call fgets
    add esp,12                  ;clear stack

    push Maxchar                ;put address of the string we want to show
    push Tdprompt               ;put address of the prompt
    call printf                 ;cal printf
    add esp,8                   ;clear stack
    push Iprompt                ;put address for prompt
    call printf                 ;call printf
    add esp,4                   ;4 * number of push we did to clear stack

    push Intval                 ;pass address for scanf
    push Intformat              ;pass format for scanf
    call scanf                  ;calling scanf
    add esp,8                   ;clear stack

    push dword[Intval]          ;push for display the integer
    push Displayprompt          ;put displayprompt address
    call printf                 ;call the printf
    add esp,8                   ;clear stack

    
;;boilerplate below
    pop edi                     ;getting all registers back
    pop esi
    pop ebx
    mov esp,ebp                 ;bring back to we started out
    pop ebp                     ;release hook
    ret                         ;go home dawg
    

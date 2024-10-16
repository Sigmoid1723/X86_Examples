    ; build it this way:
    ; nasm -f elf32 -g -F stabs eatclib.asm -l eatclib.lst
    ; gcc -m32 -o eatclib eatclib.o
    ;
    ; you have to have 32 bit c libraries(libc.so) in order to link and to do that:
    ; sudo apt-get install gcc-multilib
    ;
    
[Section .data]                 ;section containing itnitalized data

EatMsg: db "eat at joe's!",0

[Section .bss]                  ;section containing unitnitalized data

[Section .text]                 ;section containing code

extern puts                    ;simple "put string" routine form glibc
global main                    ;required linker to find entry point

main:
    push ebp                    ;setup stack frame for debugger
    mov ebp,esp
    push ebx                    ;preserve ebx,ebp,esi,edi
    push esi
    push edi

    ;boiler plate for calling c functions above

    push EatMsg                 ;put address of the message on the stack
    call puts                   ;call glibc function for displaying strings
    ; call puts
    add esp,4                   ;clean stack by 4 bytes adjusting esp, since i push message after calling it i remove from stack to clean up for other values
    sub esp,4                   ;check if stack data is there
    call puts
    add esp,4                   ;bring me back to where we started out

    ;boiler plate for calling c functions above
    pop edi                     ;restore saved registers
    pop esi
    pop ebx
    mov esp,ebp                 ;destroy stack frame by returning initial address for stack
    pop ebp                     ;move esp after poping ebp so it points to the above code block
    ret                         ;return to linux
    

    
    

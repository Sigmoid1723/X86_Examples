[section .data]

    PrintString db "%d:%s",10,0

[section .bss]

[section .text]

extern printf
global main

main:
    push ebp                    ;create frame
    mov ebp,esp                 ;save stack value
    push ebx                    ;push all registers
    push esi                    
    push edi

;;above boiler plate

    mov edi,[ebp+8]             ;get args count
    mov ebx,[ebp+12]            ;get 1st count address

    xor esi,esi                 ;clear esi

.loop:
    push dword[ebx+esi*4]       ;push that value on stack
    push esi                    ;arg number
    push PrintString            ;print string
    call printf                 ;call printf
    add esp,8                   ;clear stack
    inc esi                     ;increment to next string
    dec edi                     ;decrement arg count
    jnz .loop

;;below boiler plate

    pop edi                     ;give back all registers
    pop esi
    pop ebx
    mov esp,ebp                 ;give stack back
    pop ebp                     ;destroy frame
    ret                         ;go back 2 linux

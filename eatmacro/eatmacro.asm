section .data
    
Scrwidth: equ 20                ;80 character by defualt assumtion
Posterm: db 27,"[01;01H"        ;<Esc> [<Y>,<X>H
    POSLEN equ $-Posterm        ;length of term positioning
Clearterm:db 27,"[2J"           ;<Esc>[2J
    CLEARLEN equ $-Clearterm    ;length of term celarstirng
Admsg: db "Eat at Joe's!",10,10 ;Ad message
    ADLEN equ $-Admsg           ;admsg length
Prompt: db "Press Enter:"       ;user prompt
    PROMTLEN equ $-Prompt       ;Legth of the user prompt
    ; table of ascii digits upto 80

Digits:
    db "0001020304050607080910111213141516171819"
    db "2021222324252627282930313233343536373839"
    db "4041424344454647484950515253545556575859"
    db "606162636465666768697071727374757677787980"

section .bss

section .text

    ;macro for exiting program
    
%macro ExitProg 0
    mov eax,1                   ;specify sys_exit
    mov ebx,0                   ;return 0
    int 80h                     ;kernel call
%endmacro

    ;wait enter macro
    
%macro WaitEnter 0
    mov eax,3                   ;specify sys_read
    mov ebx,0                   ;specify file descriptor 0,stdin
    int 80h                     ;kernel call
%endmacro

    ;macro for writing string

%macro Writestr 2               ;2 args %1 = string address,%2= stirng length
    push eax                    ;save register
    push ebx
    mov ecx,%1                  ;put string address to ECX
    mov edx,%2                  ;put stirng length to ECX
    mov eax,4                   ;specify sys_write call
    mov ebx,1                   ;specify file descriptor 1,stdout
    int 80h                     ;kernel call
    pop ebx                     ;restore caller register
    pop eax
%endmacro

    ;macro for clearing screenlegth

%macro Clrscr 0
    push eax                    ;saving caller register
    push ebx
    push ecx
    push edx
    Writestr Clearterm,CLEARLEN ;call writestr macro
    pop edx                     ;restore all register
    pop ecx
    pop ebx
    pop eax
%endmacro

    ;macro for positioning in X,Y cursor

%macro Gotoxy 2                 ;%1 = X value,%2 = Y value
    pushad                      ;saving caller registers
    xor edx,edx                 ;clear edx
    xor ecx,ecx                 ;clear ecx

    ;Poke the Y digits
    mov dl,%2                   ;put Y value in offset
    mov cx,word [Digits+edx*2]  ;fetch decimal digits to cx
    mov word [Posterm+2],cx     ;poke digits into control string

    ;Poke the X digits
    mov dl,%1                   ;put X value in offset
    mov cx,word [Digits+edx*2]  ;fetch decimal digits to cx
    mov word [Posterm+5],cx     ;poke digits into contorl string

    Writestr Posterm,POSLEN     ;send sequence to stdout
    popad                       ;restore caller registers
%endmacro

    ;macro for centering string

%macro Writectr 3               ;%1 = row,%2 = string addr,%3 = string length
    push ebx                    ;save caller ebx
    push edx                    ;save caller edx
    mov edx,%3                  ;load string length to edx
    xor ebx,ebx                 ;clear ebx
    mov bl,Scrwidth             ;load screen width value in bl
    sub bl,dl                   ;calculate diffrence of two x value
    shr bl,1                    ;divide value by 2 for X value
    Gotoxy bl,%1                ;position cursor for display
    Writestr %2,%3              ;write string to console
    pop edx                     ;restore caller registers
    pop ebx
%endmacro

global _start                   ;linker needs this an entry point

_start:
    nop                         ;keep gdb happy

    Clrscr                      ;clear terminal display
    Writectr 12,Admsg,ADLEN     ;positioning add in center to display
    Gotoxy 1,23                 ;position cursor for press enter prompt
    Writestr Prompt,PROMTLEN    ;display press enter prompt
    WaitEnter                   ;wait user to enter
    ExitProg                    ;Exit the program

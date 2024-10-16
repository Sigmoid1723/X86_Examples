section .data                   ;section containing initialized data

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

section .bss                    ;section for uninitialized data

section .text                   ;section containing code

    ;-------------------------------------------------------------------------
    ; ClrScr:Clear the Linux console
    ; UPDATED:25/06/2023
    ; IN:Nothing
    ; RETURNS:Nothing
    ; MODIFIES:Nothing
    ; CALLS:Kernel sys_write
    ; DESCRIPTION: Sends the predefined control string <ESC>[2J to the
    ; console, which clears the full display

Clrscr:
    push eax                    ;save register
    push ebx                    ;save register
    push ecx                    ;save register
    push edx                    ;save register
    mov ecx,Clearterm           ;pass offset to the terminal string
    mov edx,CLEARLEN            ;pass the leght of terminal to string
    call Writestr               ;Send control string to console
    pop edx                     ;restore register
    pop ecx                     ;restore register
    pop ebx                     ;restore register
    pop eax                     ;restore register
    ret                         ;go home

    ;-------------------------------------------------------------------------
    ; GotoXY:Position the Linux Console cursor to an X,Y position
    ; UPDATED:25/06/2023
    ; IN:X in AH, Y in AL
    ; RETURNS:Nothing
    ; MODIFIES:PosTerm terminal control sequence string
    ; CALLS:Kernel sys_write
    ; DESCRIPTION: Prepares a terminal control string for the X,Y coordinates
    ; passed in AL and AH and calls sys_write to position the
    ; console cursor to that X,Y position. Writing text to the
    ; console after calling GotoXY will begin display of text
    ; at that X,Y position.

Gotoxy:
    pushad                      ;save caller's register
    xor ebx,ebx                 ;clear ebx
    xor ecx,ecx                 ;clear ecx

    ;poke at y digits
    mov bl,al                   ;put y value in scale term
    mov cx,word[Digits+ebx*2]   ;fetch decimal digits to CX
    mov word[Posterm+2],cx      ;poke digits into control string

    ;poke at x digits
    mov bl,ah                   ;put x value in scale term
    mov cx,word[Digits+ebx*2]   ;fetch decimal digits to CX
    mov word[Posterm+5],cx      ;poke digits into control string

    ;send control signal to stdout
    mov ecx,Posterm             ;pass address of the control stirng
    mov edx,POSLEN              ;pass address of the length
    call Writestr               ;write that down michael

    ;wrap this up and go back
    popad                       ;restore all caller's register
    ret                         ;go home

    ;-------------------------------------------------------------------------
    ; WriteCtr:Send a string centered to an 80-char wide Linux console
    ; UPDATED:25/06/2023
    ; IN:Y value in AL, String address in ECX, string length in EDX
    ; RETURNS:Nothing
    ; MODIFIES:PosTerm terminal control sequence string
    ; CALLS:GotoXY, WriteStr
    ; DESCRIPTION: Displays a string to the Linux console centered in an
    ; 80-column display. Calculates the X for the passed-in
    ; string length, then calls GotoXY and WriteStr to send
    ; the string to the consolea

Writectr:
    push ebx                    ;save caller ebx
    xor ebx,ebx                 ;clear ebx register
    mov bl,Scrwidth             ;load the screenwidth value to scrwidth
    sub bl,dl                   ;take diff screenwidth - screenlegth
    shr bl,1                    ;divide difference by 2 for getting x
    mov ah,bl                   ;Gotoxy requires x value in ah
    ; mov ah,20                   ;specify x 20
    call Gotoxy                 ;position cursor for display
    call Writestr               ;call the writestr
    pop ebx                     ;restore caller ebx
    ret                         ;go home

    ;-------------------------------------------------------------------------
    ; WriteStr:Send a string to the Linux console
    ; UPDATED:25/06/2023
    ; IN:String address in ECX, string length in EDX
    ; RETURNS:Nothing
    ; MODIFIES:Nothing
    ; CALLS:Kernel sys_write
    ; DESCRIPTION: Displays a string to the Linux console through a
    ; sys_write kernel call

Writestr:
    push eax                    ;save caller registers
    push ebx
    mov eax,4                   ;specify sys_write call
    mov ebx,1                   ;specify file descriptor 1, stdout
    int 80h                     ;make kernel call
    pop ebx                     ;restore callers registors
    pop eax
    ret                         ;go home

global _start                   ;linker need this entery point

_start:
    nop                         ;keep gdb happy

    ;first clear terminal display
    call Clrscr

    ;post admsg centered in 80-wide console
    mov al,12                   ;specify line in 12
    mov ecx,Admsg               ;pass address of message
    mov edx,ADLEN               ;pass length of message
    call Writectr               ;display it to console

    ;position cursor for the "Press Enter" prompt
    mov ax,0117h                ;mov to 1,23 hexvalue cursor
    call Gotoxy                 ;position the cursor

    ;display "press Enter" prompt;
    mov ecx,Prompt               ;pass offset of the prompt
    mov edx,PROMTLEN             ;pass length of prompt
    call Writestr                ;send the prompt to console

    ;Wait for the user to press enter
    mov eax,3                   ;code for sys_read
    mov ebx,0                   ;specify file descriptor 0, stdin
    int 80h                     ;make kernel call

    ;Exit
Exit:
    mov eax,1                   ;code for exit syscall
    mov ebx,0                   ;return value 0
    int 80h                     ;make kernel call

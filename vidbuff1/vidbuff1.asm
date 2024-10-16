section .data

    EOL equ 10                  ;linxu end of line character
    FILLCHAR equ 32             ;ascii seq character
    ; HBARCHAR equ 192            ;use dash character if this doesn't display
    HBARCHAR equ 45            ;use dash character if this doesn't display
    STRROW equ 2                ;row where graph begins

    ;table of byte length members
    Dataset db 9,71,17,52,55,18,29,36,18,68,77,63,58,44,0

    Message db "Data as of 26/06/2023"
    MSGLEN equ $-Message

    ;clear consol and put text cursor on origin (1,1)
    ; Clrhome db 27,"[2J",27,"[01;01H",27,"[42m" ;<esc> Clear,<esc> Y:X,<esc>GreenBG
    ; Clrhome db 27,"[2J",27,"[01;01H",27,"[32m" ;<esc> Clear,<esc> Y:X,<esc>GreenBG
    Clrhome db 27,"[2J",27,"[01;01H",27,"[37m",27,"[44m" ;<esc> Clear,<esc> Y:X,<esc>Whitetext,<esc>BlueBG
    CLRLEN equ $-Clrhome            ;length of terminal clear string


section .bss                    ;section containing uninitialized data

    COLS equ 81                 ;line leght + 1 for EOL
    ROWS equ 25                 ;number of line in display
    Vidbuff resb COLS*ROWS      ;vidbuff reserve bytes

section .text

global _start                   ;linker entry point

    ;macro for clearing terminal

%macro Clrterm 0
    pushad                      ;save all register
    mov eax,4                   ;mention sys_write call
    mov ebx,1                   ;specify file descriptor 1, stdin
    mov ecx,Clrhome             ;put Clrhome address
    mov edx,CLRLEN              ;Clrhome length
    int 80h                     ;kernel call
    popad                       ;restore all register
%endmacro

    ;procedure for display text buffer

show:
    pushad                      ;save all register
    mov eax,4                   ;mention sys_write call
    mov ebx,1                   ;specify file descriptor 1,stdout
    mov ecx,Vidbuff             ;pass offset to buffer
    mov edx,COLS*ROWS           ;pass length of buffer
    int 80h                     ;kernel call
    popad                       ;restore all register
    ret                         ;return home

    ;procedure for clear text buffer with spaces and EOLs

Clrvid:
    push eax                    ;saving caller's registers
    push ecx
    push edi
    cld                         ;clear DF, we are counting up memory
    mov al,FILLCHAR             ;put the FILLchar in al
    mov edi,Vidbuff             ;point destination index at buffer
    mov ecx,COLS*ROWS           ;put count of character stored in ecx
    rep stosb                   ;blast character at buffer?

    ;buffer is cleard now we need to insert EOL at each line end
    mov edi,Vidbuff             ;point at destination index at buffer agian
    dec edi                     ;start EOL poistion count at 0 character
    mov ecx,ROWS                ;put number of rows at count register
PtEOL: add edi ,COLS            ;add column count to edi
    mov byte [edi],EOL          ;store EOL at end of the rows
    loop PtEOL                  ;loopback until more line left
    pop edi                     ;restoring caller's registers
    pop ecx
    pop eax
    ret                         ;go home

    ; procedure for writing string to text buffer at 1-based , x, y position

Wrtln:
    push eax                    ;saving caller's register
    push ebx
    push ecx
    push edi
    cld                         ;clear DF for up-memory write
    mov edi,Vidbuff             ;load the buffer offset
    dec eax                     ;decrement Y value down 1 for address calc
    dec ebx                     ;adjust X value down by 1
    mov ah,COLS                 ;move screen width to AH
    mul ah                      ;do 8 bit multiplication AL*AH to AX
    add edi,eax                 ;add Y offset to vidbuff
    add edi,ebx                 ;add X offset to vid buffer
    rep movsb                   ;blast string into buffer
    pop edi                     ;restore all caller's registers
    pop ecx
    pop ebx
    pop eax
    ret                         ;go home

    ; generate "-------------" at X,Y in text buffer

WrtHB:
    push eax                    ;save register we might change
    push ebx
    push ecx
    push edi
    cld                         ;clear DF for memory up-write
    mov edi,Vidbuff             ;put address into destination register
    dec eax                     ;adjust Y value down for 1 address for calc
    dec ebx                     ;adjust X value down for 1 address for calc
    mov ah,COLS                 ;move screen width to all
    mul ah                      ;AL*AH to AX
    add edi,eax                 ;Add Y offset to EDI
    add edi,ebx                 ;Add X offset to EDX
    mov al,HBARCHAR             ;put bar in al
    rep stosb                   ;blast the bar into buffer
    pop edi                     ;restore all registers
    pop ecx
    pop ebx
    pop eax
    ret                         ;go home

    ;procedure for genrating "0123456789" ruler at X,Y position

Ruler:
    push eax                    ;save caller's registers
    push ebx
    push ecx
    push edi
    mov edi,Vidbuff             ;put buffer address at edi
    dec eax                     ;adjust Y value down 1 for address calc
    dec ebx                     ;adjust X value down 1 for address calc
    mov ah,COLS                 ;move screen width to AH
    mul ah                      ;8-bit mul AL*AH into AX
    add edi,eax                 ;add Y offset into buffer
    add edi,ebx                 ;add X offset into buffer

    ; now it point to the memory where ruler begins
    mov al,'1'                  ;start ruler with '1' digit
Dochar: stosb                   ;Note: no "rep" prefix
    add al,'1'                  ;bump character value al by '1'
    aaa                         ;adjust AX to make BCD addition
    add al,'0'                  ;add 30 to show ascii equivent code if more than 10
    loop Dochar                 ;loop back till countregister ecx become 0
    pop edi                     ;resotre all registers
    pop ecx
    pop ebx
    pop eax
    ret                         ;go home

    ;----------------------------------------------------------------------------------------------------
    ; Main Program
    ;----------------------------------------------------------------------------------------------------

_start:

    nop                         ;keep gdb happy

    ; Get the console and text display text buffer ready to go

    Clrterm                     ;clear the terminal
    call Clrvid                 ;initialize the buffer

    ; display top ruler

    mov eax,1                   ;load Y pos to al
    mov ebx,1                   ;load X pos to bl
    mov ecx,COLS-1              ;load ruler to length(81-1)
    call Ruler                  ;write ruler to buffer

    ; loop through dataset and graph data

    mov esi,Dataset             ;put the address of dataset in esi
    mov ebx,1                   ;start all bars at left margin(X=1)
    mov ebp,0                   ;dataset element index start at 0
.blast: mov eax,ebp             ;add dataset number to element index
    add eax,STRROW              ;bias row value by row number of first bar
    mov cl,byte[esi+ebp]        ;put dataset value in low byte of ECX
    cmp ecx,0                   ;see if 0 has been pulled from dataset
    je .rule2                   ;If we pulled 0 form dataset then we are done
    call WrtHB                  ;Graph data in horizontal bars
    inc ebp                     ;Increment the dataset element index
    jmp .blast                  ;go back and do another bar

    ; Display the bottem ruler
.rule2: mov eax,ebp             ;use the dataset counter to the set ruler now
    add eax,STRROW              ;bias down by the row of the first bars
    mov ebx,1                   ;load X pos in BL
    mov ecx,COLS-1              ;load ruler length to ECX
    call Ruler                  ;write the ruler to buffer

    ; Informative message centerd of the last line
    mov esi,Message             ;load the address of the message to ESI
    mov ecx,MSGLEN              ;its length to ecx
    mov ebx,COLS                ;add the screen width to ebx
    sub ebx,ecx                 ;calc diffrence btw screen width - message length
    shr ebx,1                   ;divide the difference by 2 in value
    mov eax,24                  ;set the display row at line 24
    call Wrtln                  ;display the centerd message

    ; Having written all that to buffer and send that buffer to console
    call show                   ;refresh the buffer console

Exit: mov eax,1                 ;code for exit_syscall
    mov ebx,0                   ;return value 0
    int 80h                     ;make kernel call

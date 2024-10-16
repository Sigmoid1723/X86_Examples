section .bss

    BUFFLEN equ 10              ;16 len buffer
Buff: resb BUFFLEN              ;text buffer

section .data

Dumplin: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
    DUMPLEN equ $-Dumplin
    
Asclin: db "|................|",10
    ASCLEN equ $-Asclin
    FULLLEN EQU $-Dumplin
    
Hexdigits: db "0123456789ABCDEF"

Bindigits:
    db "0000","0001","0010","0011"
    db "0100","0101","0110","0111"
    db "1000","1001","1010","1011"
    db "1100","1101","1110","1111"

    ;character for ascill presentation where other unwanted character set to '.'
    
DOTXLAT:
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
    db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
    db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
    db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
    db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
    db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh

section .text

GLOBAL Clearline, DumpChar, Newlines, Printline ;procedure
GLOBAL Dumplin,Hexdigits,Bindigits              ;dataitem

    ;-------------------------------------------------------------------------
    ; ClearLine: Clear a hex dump line string to 16 0 values
    ; UPDATED: 25/06/2023
    ; IN:Nothing
    ; RETURNS: Nothing
    ; MODIFIES: Nothing
    ; CALLS:DumpChar
    ; DESCRIPTION: The hex dump line string is cleared to binary 0 by
    ; calling DumpChar 16 times, passing it 0 each time.

Clearline:
    pushad                      ;save all caller's GP register
    mov edx,15                  ;16 pokes counting from 0

.poke:
    mov eax,0                   ;tell dump character to poke at 0
    call DumpChar               ;instert '0' into hexdump string
    sub edx,1                   ;decrement doesn't set CF
    jae .poke                   ;loop back till edx >= 0
    popad                       ;restore all character GP register
    ret                         ;go home

    ;-------------------------------------------------------------------------
    ; DumpChar:"Poke" a value into the hex dump line string.
    ; UPDATED:25/06/2023
    ; IN:Pass the 8-bit value to be poked in EAX.
    ; Pass the value’s position in the line (0-15) in EDX
    ; RETURNS:Nothing
    ; MODIFIES:EAX, ASCLin, DumpLin
    ; CALLS:Nothing
    ; DESCRIPTION: The value passed in EAX will be put in both the hex dump
    ; portion and in the ASCII portion, at the position passed
    ; in EDX, represented by a space where it is not a
    ; printable character.

DumpChar:
    push ebx                    ;save caller's ebx
    push edi                    ;save caller's edi

    ;insert the ascii portion of the dump line
    mov bl,byte[DOTXLAT+eax]    ;translate non printable to '.'
    mov byte[Asclin+edx+1],bl   ;write to ascii portion

    ;insert hex equivalent of input to hexportion
    mov ebx,eax                 ;save second copy of input characters
    lea edi,[edx*2+edx]         ;multiply offset by 3

    ;lookup low nybble character and instert into string
    and eax,0000000fh           ;mask out all low nybble
    mov al,byte[Hexdigits+eax]  ;look up character equivalent to string
    mov byte[Dumplin+edi+2],al  ;write chracter equivalent to line string

    ;lookup high nybble character and instert into string
    and ebx,000000f0h           ;mask out all but high nybble
    shr ebx,4                   ;shift high  4 bites to low 4 bits
    mov bl,byte[Hexdigits+ebx]  ;look up character equivalent to string
    mov byte[Dumplin+edi+1],bl  ;write chracter equivalent to line string

    ;Done go home
    pop edi                     ;Restore caller's edi
    pop ebx                     ;Restore caller's ebx
    ret                         ;return to caller

    ;-------------------------------------------------------------------------
    ; Newlines:Sends between 1 and 15 newlines to the Linux console
    ; UPDATED:25/06/2023
    ; IN:# of newlines to send, from 1 to 15
    ; RETURNS:Nothing
    ; MODIFIES:Nothing
    ; CALLS:Kernel sys_write
    ; DESCRIPTION: The number of newline chareacters (0Ah) specified in EDX
    ; is sent to stdout using using INT 80h sys_write. This
    ; procedure demonstrates placing constant data in the
    ; procedure definition itself, rather than in the .data or
    ; .bss sections.

Newlines:
    pushad                      ;save all caller's register
    cmp edx,15                  ;make sure caller didn't asked for more then 15
    ja .exit                    ;if so exit without doing anything
    mov ecx,EOLs                ;put address of EOLs into ecx
    mov eax,4                   ;specify sys_write call
    mov ebx,1                   ;specify file discriptor 1,stdout
    int 80h                     ;call kernel
.exit: popad                    ;restore all character to registers
    ret                         ;return to caller
EOLs: db 10,10,10,10,10,10,10,10,10,10,10,10,10,10,10

    ;-------------------------------------------------------------------------
    ; PrintLine:Displays DumpLin to stdout
    ; UPDATED:25/06/2023
    ; IN:Nothing
    ; RETURNS:Nothing
    ; MODIFIES:Nothing
    ; CALLS:Kernel sys_write
    ; DESCRIPTION: The hex dump line string DumpLin is displayed to stdout
    ; using INT 80h sys_write. All GP registers are preserved.
    
Printline:
    pushad                      ;save all GP register
    mov eax,4                   ;specify sys_write call
    mov ebx,1                   ;specify file descriptor 1, stdout
    mov ecx,Dumplin             ;pass address to ecx
    mov edx,FULLLEN             ;size of line string
    int 80h                     ;call sys_write
    popad                       ;restore all GP register
    ret                         ;return to caller


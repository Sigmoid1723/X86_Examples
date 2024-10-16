section .data

    ; WordString: dw 'CQ'
    ; DoubleString: dd 'Stop'
    Editbuff dq 'abcdefghijklm            q'
    Editbufflen equ $-Editbuff
    ENDPOS equ 12
    INSERTPOS equ 5
    
    
section .text

    global _start

_start:
    nop
    ;; put experiment between two nops
    ;; mov ax,067FEh
    ;; mov bx,ax
    ;; mov cl,bh
    ;; mov ch,bl
    ;; xchg cl,ch
    ;; mov eax,0ffffffffh
    ;; mov ebx,02dh
    ;; dec ebx
    ;; inc eax
    ; mov eax,5
; DoMore: dec eax
;     ; jnz DoMore
    ;     Jmp DoMore
    ; mov eax,42
    ; neg eax
    ; add eax,42
    ; mov eax,07FFFFFFFh
    ; inc eax
    ; mov ax,-42
    ; mov ebx,eax
    ; mov ax,-42
    ; movsx ebx,ax
    ; mov eax,447
    ; mov ebx,1739
    ; mul ebx
    ; mov eax,0FFFFFFFFh
    ; mov ebx,03B72h
    ; mul ebx
    ; mov eax,WordString
    ; mov edx,DoubleString
    ; mov al,byte[UpCase+eax]

    ; std                         ;down memory transfer
    ; mov ebx,Editbuff+INSERTPOS  ;save address of insert position
    ; mov esi,ENDPOS+Editbuff     ;start at end of text
    ; mov edi,Editbuff+ENDPOS+1   ;bump text right by 1
    ; mov ecx,ENDPOS-INSERTPOS+1  ;count for execution
    ; rep movsb                   ;move'em
    ; mov byte [ebx],' '          ;write a space at insert position

    ; stc
    ; mov eax,8h
    ; adc eax,2h

    ; mov ax,1
    ; db 0c1h,0e0h,001h
    ; mov dx,ax

    mov eax,4                   ;sys_write
    mov ebx,1                   ;stdout
    mov ecx,Editbuff            ;pass address
    mov edx,Editbufflen         ;pass length
    int 80h                     ;kernel call

    mov eax,1                       ;sys_exit
    mov ebx,0                       ;return 0
    int 80h                     ;kernel call
    ;; put experiment between two nops
    nop

section .bss

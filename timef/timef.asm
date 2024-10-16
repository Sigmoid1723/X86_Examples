[section .data]

Ctimetext: db"C time: ",0
Localtimetext: db "Local time:%d %d/%d/%d",0
Elapsed: db "A total of %d seconds has elapsed since program began running.",10,0
    
[section .bss]

    Oldtime resd 1              ;reserve double for time
    Newtime resd 1              ;reserve double for time
    Tmstruct resd 9             ;tm struct contain 9 dwords
    Timediff resd 1             ;put timediff

[section .text]                 ;section containing code

extern difftime
extern getchar
extern localtime
extern ctime
extern printf
extern time
global main

main:
    push ebp                    ;create hook
    mov ebp,esp                 ;save value for esp to ebp
    push ebx                    ;save all registers
    push esi
    push edi

;;boiler plate above

    ; push Oldtime                ;mention address you want to store time
    push dword 0                ;pass null pointer
    call time                   ;call time function
    add esp,4                   ;clear stack
    mov [Oldtime],eax           ;put that value in oldtime

    push Ctimetext              ;push prompt
    call printf                 ;call printf
    add esp,4                   ;clear stack
    
    push Oldtime                ;push stord time pointer
    call ctime                  ;call ctime function
    add esp,4                   ;clear stack
    
    push eax                    ;push address of fetched value
    call printf                 ;call printf
    add esp,4                   ;clear stack
    
    ; push Localtimetext          ;prompt address
    ; call printf                 ;call printf
    ; add esp,4                   ;clear stack

    push Oldtime                ;push stored time pointer
    call localtime              ;call localtime function
    add esp,4                   ;clear stack

    mov edx,dword[eax+20]       ;get year value
    add edx,1900                ;add 1900 year to it
    mov ecx,dword[eax+16]       ;fetch month value
    add ecx,1
    mov ebx,dword[eax+12]       ;day value
    mov esi,dword[eax+24]        ;week day from sunday
    
    push edx                    ;push that value in stack
    push ecx                    ;push value for print
    push ebx                    ;push value for print
    push esi                    ;push that thing
    push Localtimetext          ;prompt address
    call printf                 ;print the time value as per localtime
    add esp,8                   ;clear stack

    ; mov esi,eax                 ;move copy to esi
    ; mov edi,Tmstruct            ;tmstruct for firing
    ; mov ecx,9                   ;9 time firing since tm struct 9 bytes
    ; cld                         ;clear direction flag
    ; rep movsd                   ;copy to local copy

    ; push Tmstruct               ;now print Tm struct
    ; call printf                 ;print the time value as per localtime
    ; add esp,4                   ;clear stack

    call getchar                ;get enter to get difference between time
    
    push dword 0                ;pass null pointer
    call time                   ;get newtime
    add esp,4                   ;clear stack
    mov [Newtime],eax           ;move to new time

    sub eax,[Oldtime]           ;calculate difference
    mov [Timediff],eax          ;save the difference value

    push dword[Timediff]        ;push it into stack
    push Elapsed                ;put the prompt
    call printf                 ;print this
    add esp,8                   ;clear stack
    
;;boiler plate below

    pop edi                     ;restore all registers
    pop esi
    pop ebx
    mov esp,ebp                 ;return stack
    pop ebp                     ;clear hook
    ret                         ;return linux

[section .data]

    ErrorNonum db "Error: Please Enter the valid number after ./textfile2",10,0
    ErrorMsg db "Usage: ./textfile2 <number> <string1> <string2> .....",10,0
    Charstring db "-0123456789qwertuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM@"
    fname db "textfile.txt ",0
    Writecode db "w",0
    ErrorFileText db "Error: file %s cannot be opened.",10,0
    SuperString db "%s",10,0
    GenerateString db "The file %shas been generated containing %s lines.",10,0
    
[section .bss]

    Linecount resb 4            ;linecount bytes
    MAXCHAR equ 70+2             ;number of character we want to show + EOL + 0
    Randbuff resb MAXCHAR
    BUFFLEN equ $-Randbuff

[section .text]

extern fprintf
extern sprintf
extern fopen
extern fclose
extern time
extern srand
extern rand
extern printf
global main

;;random character string
    
RCS:
;;get the seed
    push dword 0                ;pass null pointer
    call time                   ;call time function
    add esp,4                   ;clear stack

    push eax                    ;push seed
    call srand                  ;call srand function
    add esp,4                   ;clear stack

    mov ecx,0                   ;number of character count
.again:
    push ecx                    ;just incase
    call rand                   ;call rand function
    pop ecx                     ;get back

    and eax,003fh                ;get last six bits
    mov bl,byte[eax+Charstring] ;get that random chracter in bl
    mov [Randbuff+ecx],bl       ;get that value in buffer
    inc ecx
    cmp ecx,MAXCHAR-2           ;compare value
    jnz .again                   ;if not last go again
    ; mov byte[Randbuff+ecx],10   ;feed EOL and fall through
    ; inc ecx
    mov byte[Randbuff+ecx],0    ;Null terminate just in case

    ;check the random generated string via printf
    ; push Randbuff               ;get buffer address
    ; call printf                 ;call printf fucntion
    ; add esp,4                   ;clear stack

    mov edi,[ebp+8]             ;save arg count
    mov esi,[ebp+12]            ;save arg
    jmp Numtest1                ;check method

    ;file opening procedure
Openfiles:
    push dword Writecode              ;push 'w' for writing file
    push dword fname                    ;file string
    ; mov ecx,fname            ;pass string to eax
    ; mov edx,Writecode           ;write mode
    call fopen                  ;call fopen function
    add esp,8                   ;clear stack
    mov ebx,eax                 ;it contain file handle save it in ebx

    ; cmp eax,0                   ;it will return null if its failed
    ; jz ErrorFile                ;jump to error file section
    ret                         ;return

    ;display buffer string in each lines
linesBuffer:
    call  Openfiles              ;open the files
    ; mov ebx,fname                ;lets go
    mov esi,Randbuff
    ; push Randbuff               ;push random string
    push esi                ;push that buffer
    push SuperString            ;push that string
    push ebx                    ;mention file handle that you want to push
    mov edi,[Linecount]
writeline:
    cmp edi,0      ;compare till number of line is 0
    je donewrite             ;loop back
    call fprintf                ;call fprintf
    dec edi        ;decrement ebx number
    jmp writeline
donewrite:
    add esp,12                   ;clear stack
    
    push ebx                    ;mention file
    call fclose                 ;close file
    add esp,4                   ;clear stack
    jmp Generated                 ;go back
;;test the number
    
Numtest1:                       ;check method 1(not great since we need to convert string into number as well
    mov eax,[esi+4]             ;get the 2 arg in ebx
    mov eax,dword[eax]          ;lol
    xor edx,edx                 ;clean this al well
.addanother:
    cmp al,0                    ;check the bit if its 0
    je .clean
    shl edx,8                   ;shift left reverse order
    add dl,al                   ;add that to dl
    shr eax,8                   ;shift right for other bits
    jmp .addanother              ;go loop
.clean:
    xor ebx,ebx                 ;clear buffer register
    xor eax,eax                 ;clear eax
    xor ecx,ecx                 ;clear count
.loopn:
    cmp dl,30h                  ;check if it is less than '0' ascii
    jb ENonum                   ;if it is jump to error
    cmp dl,39h                  ;if it is more than '9' ascii
    ja ENonum                   ;if it is jump to error
    sub dl,30h                  ;sub that
    mov ch,cl                   ;ch for multipling 10 how many times if cl 2 than multiply twice by 10
    cmp cl,1                    ;if more than 1
    jae .ahead
    mov bl,dl                   ;other wise just add
    jmp .next1
.ahead:
    mov al,dl                   ;move for multiply
.Aloop:
    imul eax,10                 ;multiply by 10
    dec ch                      ;dec loop we want to multiply
    jne .Aloop                   ;again loop
    add bl,al                   ;get that value
.next1:
    inc cl
    shr edx,8                   ;check for next number
    
    jnz .loopn                   ;if it not jump to loop
.finish:
    mov dword[Linecount],ebx      ;move that to line count
    cmp edi,2                   ;if exactly two count then printf form buffer
    je linesBuffer              ;then go to buffer

    ;else we get args from terminal
PrintArgument:
    mov edi,[ebp+8]             ;save argcount
    mov esi,[ebp+12]            ;get the 3rd argument
    sub edi,3                   ;see number of argument more than 3
    xor eax,eax                 ;clear eax
    mov esi,[esi+8]       ;get that value
    mov ebx,Randbuff            ;put that random buffer
    push esi
    push SuperString
    push ebx                    ;push that buffer where we store value
    xor ebx,ebx                 ;clear this
.anotherarg:
    
    call sprintf                ;call sprintf
    add ebx,eax

    cmp edi,0                   ;check if it reach 0 then go ahead
    jz .appendzero
    mov byte[Randbuff+ebx-1],20h ;other wise append space
    dec edi
    add [esp],eax                 ;check for now
    add [esp+8],eax                 ;check for now
    jmp .anotherarg
.appendzero:
    add esp,12                  ;clear stack
    mov byte[Randbuff+ebx-1],0 ;append 0    
.cont:
    jmp linesBuffer             ;time to print this
    
;;error if not number
ENonum:
    cmp dl,0                   ;if number is 0
    je Numtest1.finish                   ;go back
    push ErrorNonum             ;push error messag string
    call printf                 ;call printf
    add esp,4                   ;clear stack
    push ErrorMsg               ;push error message string
    call printf                 ;call printf
    add esp,4                   ;clear stack
    jmp BoilerB                 ;jump to the end

;;error usage message
Error:
    push ErrorMsg               ;push error message string
    call printf                 ;call printf function
    add esp,4                   ;clear stack
    jmp BoilerB                 ;jump to the end

;;error file open message
ErrorFile:
    ; push ebx
    ; call fclose
    ; add esp,4                   ;clear stack

    mov eax,fname
    push eax
    call fclose                 ;close the file
    add esp,4                   ;clear the stack
    
    push fname               ;pass file name
    push ErrorFileText          ;push error message string
    call printf                 ;call printf function
    add esp,8                   ;clear stack
    jmp BoilerB                 ;jump to the end
    
main:
    push ebp                    ;create framre
    mov ebp,esp                 ;save fram entry
    push ebx                    ;save all sacred registers
    push esi
    push edi

;;boiler plate above

    mov edi,[ebp+8]             ;save arg count
    cmp edi,1                  ;compare if argcount is 1
    jbe Error                    ;if that it goes straight to error

    mov edi,[ebp+8]             ;save arg count
    mov esi,[ebp+12]            ;save arg
    cmp edi,2                   ;if argcount is 2
    je RCS                      ;go to number testing

    jmp Numtest1                ;else jump for number checking

Generated:
    mov esi,[ebp+12]            ;get argument address
    mov esi,[esi+4]               ;move that argument to esi
    push esi                    ;push argument[1]
    push fname                  ;push filename string
    push GenerateString         ;pass string message
    call printf                 ;printf function
    add esp,12                  ;3 push x 4 pointer
    
BoilerB:                        
;;boiler plate below
    pop edi                     ;restore registers
    pop esi
    pop ebx
    mov esp,ebp                 ;go back to frame entry
    pop ebp                     ;destroy frame to furter use
    ret                         ;go back to linux

.model tiny
.code
org 100h

ProgEnter:
    JMP main

    noArgsString db "No arguments$"
    exception db "Wrong arguments$"
    notInstalledException db "Qdrhcdms,hr,mns,hmrs`kkdc$"
    secretString db "Rnqqx'tmrtoonqsdc,ed`stqd($"

    int21Initial dw 2 dup(?)
    int2FInitial dw 2 dup(?)

int2FProc proc
    cmp ax, 0C000h
    je myHandler    
    jmp dword ptr cs:[int2FInitial]

    myHandler:

    mov al, 0FFh
    iret
endp    

int2FProcClear proc
    cmp ax, 0C000h
    je myHandlerClear    
    jmp dword ptr cs:[int2FInitial]

    myHandlerClear:

    mov al, 000h
    iret
endp    

int21Proc proc
    cmp ah, 09h
    je myHandler21
    jmp dword ptr cs:[int21Initial]

    myHandler21:
    pushf 
    push ax ds es dx 

    mov ax, cs
    mov es, ax

    push si di cx bx

    mov bx, dx
    cycle:
    mov al, byte ptr[bx]
    cmp al, '$'

    je finish

    mov dl, al

    inc dl

    mov ah, 02h

    pushf
    call dword ptr cs:[int21Initial]           ;calling old handler 21h interrupt

    inc bx
    jmp cycle
    finish:

    pop bx cx di si 
    pop dx es ds ax
    popf

    iret
endp

Installation:

main:
    cmp byte ptr es:[80h], 0
    
    mov bl, byte ptr es:[80h]
    mov cl, byte ptr es:[82h]
    mov ch, byte ptr es:[83h]

    mov ax, cs
    mov ds, ax
    mov es, ax

    mov ax, 0C000h
    int 2Fh

    cmp bl, 0
    je noArgs
    cmp bl, 3
    jne displayException
    cmp cl, '-'
    jne displayException
    cmp ch, 'd'
    jne displayException

    jmp uninstall
    noArgs:
        cmp al, 0FFh
        je endMain

        mov ax, 352Fh ; pointer on interuption handler (returns in es:bx)
        int 21h

        mov cs:int2FInitial, bx ; saving old handler
        mov cs:int2FInitial + 2, es

        mov ax, 3521h
        int 21h

        mov word ptr int21Initial, bx
        mov word ptr int21Initial + 2, es

        mov ax, 252Fh ; set pointer to new handler
        mov dx, cs
        mov ds, dx
        lea dx, int2FProc
        int 21h

        mov ax, 2521h
        mov dx, cs
        mov ds, dx
        lea dx, int21Proc
        int 21h

        lea dx, Installation
        int 27h

        jmp endMain
    displayException:
        lea dx, exception
        mov ah, 09h
        int 21h

        jmp endMain
    displayNotInstalled:
        lea dx, notInstalledException
        mov ah, 09h
        int 21h

        jmp endMain
    uninstall: 
        cmp al, 00h
        je displayNotInstalled

        mov ax, 252Fh ; set pointer to new handler
        mov dx, cs
        mov ds, dx
        lea dx, int2FProcClear
        int 21h

        lea dx, secretString
        mov ah, 09h
        int 21h
endMain:
    mov     ax, 4c00h
    int     21h
end ProgEnter

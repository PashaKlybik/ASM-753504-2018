.8086
.model small
.386
.stack 100h
.data
    a dw 4
    b dw 3
    c dw 2
    d dw 1
    
.code
start:

    mov ax, @data
    mov ds, ax

    mov ax, a
    mov bx, b
    mov cx, c
    mov dx, d

    cmp ax, bx
    jle ALessThanB
    jmp BLessThanA

ALessThanB:
    cmp ax, cx
    jle ALessThanC
    jmp CLessThanA

BLessThanA:
    cmp bx, cx
    jle BLessThanC
    jmp CLessThanB

ALessThanC:
    cmp ax, dx
    jle ALess
    jmp DLess

CLessThanA:
    cmp cx, dx
    jle CLess
    jmp DLess

BLessThanC:
    cmp bx, dx
    jle BLess
    jmp DLess

CLessThanB:
    cmp cx, dx
    jle CLess
    jmp DLess

ALess:
    mov ax, a
    jmp exit

BLess:
    mov ax, b
    jmp exit

CLess:
    mov ax, c
    jmp exit

DLess:
    mov ax, d
    jmp exit

exit:
    mov ax, 4c00h
    int 21h
end start
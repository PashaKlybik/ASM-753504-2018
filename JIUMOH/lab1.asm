;variant 9
model small
.STACK 100h
.DATA
    a dw 3
    b dw 6
    c dw 9
    d dw 7
.CODE
START:
    mov ax, @data
    mov ds, ax
    mov ax, a
    mov bx, b  
    cmp ax, bx
    JNG less1
    JMP more1 
less1:
    mov ax, b
more1:
    mov bx, c
    cmp ax, bx
    JNG less2
    JMP more2
less2:
    mov ax, c
more2:
    mov bx, d
    cmp ax, bx
    JNG less3
    JMP more3
less3:
    mov ax, d
more3:
    JMP EndProgramm


EndProgramm :
    mov ax,4c00h
    int 21h

END START
.model small
.stack 100h

.data
    a dw 1
    b dw 1
    c dw 1
    d dw 1
.code

main:

    mov ax, @data
    mov ds, ax
    
    mov ax, a 
    mul c
    mov bx, ax
    xor ax, ax

    mov ax, b
    mul d
    mov dx, ax
    xor ax, ax

    add bx, dx
    xor dx, dx

    mov ax, a
    mul d
    mov cx, ax
    xor ax, ax

    mov ax, b
    mul c
    mov dx, ax
    xor ax, ax

    add dx, cx
    xor cx, cx

    cmp bx, dx
    je case1

    xor bx,bx
    xor dx,dx

    mov bx, a
    mov cx, c
    cmp bx, cx
    jg case2

    mov ax, a
    mov bx, b
    mov dx, c

    or bx,dx
    sub ax,bx

    jmp finish

case1:
    
    mov ax, a
    mul a
    
    jmp finish

case2:

    xor bx,bx
    mov bx, b
    and cx,bx
    mov ax,cx
    
    jmp finish

finish:

    xor bx,bx
    xor cx,cx
    xor dx,dx
    int 21h

END main

;v:3
.model small
.stack 256
.data
    a dw 1
    b dw 5
    c dw 3
    d dw 7
.code
main:
    mov ax, @data
    mov ds, ax
    
    mov ax, a
    mul c
    mov bx, ax
    
    mov ax, b
    mul d
    add bx, ax
    
    mov ax, a
    mul d
    mov cx, ax

    mov ax, b
    mul c
    add cx, ax
    
    cmp bx, cx
        ;if(a * c + b * d = a * d + b * c)
        je equal    
    mov ax, c
    cmp ax, a
        ;if(a > c)
        jc aIsBigger   
    ;else AX = a – (b OR c)		
    mov bx, b
    or bx, c
    mov ax, a
    sub ax, bx
    jmp all
    
    aIsBigger:
       mov ax, c
       and ax, b
       jmp all
 
    equal:
        mov ax, a
        mul ax

    all:
        mov ax, 4c00h
        int 21h
end main
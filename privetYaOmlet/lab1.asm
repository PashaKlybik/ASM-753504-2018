.model small
.stack 256
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
    mov bx, b
    and bx, ax
    mov ax, c
    mul c
    mul c
    mul c 
    cmp bx, ax
    je case1

    mov bx, c
    mov ax, b
    add bx, ax
    mul b
    mul b
    mov dx, ax
    mov ax, a
    mul a
    mul a
    add ax, dx
    cmp x, cx
    je case2

    mov ax, b
    shr ax, 3
    jmp end
    
        case1: 
        mov ax,c
        mov bx,d
        mov cx,b
        xor dx,dx
        div bx
        xor dx,dx
        div cx
        add ax,a
        jmp end
    
        case2:
        mov ax, a
        mov cx, b
        mov bx, c
        add cx, bx
        xor ax, cx
    
        end:
        int 21h
end main
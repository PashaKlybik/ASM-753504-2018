.model small
.stack 256
.data
    a dw 3
    b dw 2
    c dw 33
    d dw 3

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
		
    je point1
    mov cx, c
    mov ax, b
    add cx, ax
    mul b
    mul b
    mov dx, ax
    mov ax, a
    mul a
    mul a
    add ax, dx
    cmp ax, cx
    je point2
    mov ax, b
    shr ax, 3
    jmp endPoint
	
point1: 
    mov ax,c
    mov cx,d
    mov bx,b
    xor dx,dx
    div cx
    xor dx,dx
    div bx
    add ax,a
jmp endPoint
	
point2:
    mov ax, a
    mov bx, b
    mov cx, c
    add bx, cx
    xor ax, bx
	
endPoint:
    int 21h
end main
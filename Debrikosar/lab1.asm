.model small
.stack 256
.data
    a dw 2
    b dw 1
    c dw 1
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
    je firstConditionTrue

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
    je secondConditionTrue

    mov ax, b
    shr ax, 3
    jmp endPoint
	
firstConditionTrue:
    mov ax, c
    mov cx, d
    mov bx, b
    xor dx, dx
    div cx
    xor dx, dx
    div bx
    add ax, a
    jmp endPoint
	
secondConditionTrue:
    mov ax, a
    mov bx, b
    mov cx, c
    add bx, cx
    xor ax, bx
	
endPoint:
    int 21h
end main
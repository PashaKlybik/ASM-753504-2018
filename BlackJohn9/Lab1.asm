; Lab 1 - Option 6

.model small
.stack 100h

.data
	a dw 11
	b dw 22
	c dw 47
	d dw 54

.code
main:
    mov ax, @data
    mov ds, ax

    mov ax, a
    mov bx, b
    mov cx, c
    mov dx, d

    inc ax
    
    OR ax, a
    cmp ax, bx
    je FirstOption

    mov ax, a
    AND ax, b
    OR cx, dx
    cmp ax, cx
    je SecondOption

    jmp DefaultOption


FirstOption:
    mov ax, a
    mul bx
    add ax, cx
    div dx
    mov ax, dx
    
SecondOption:
    sub bx, 1
    AND b, bx

DefaultOption:
    mov ax, b
    mov cx, a
    mul cx
    mov a, ax

    xor dx, dx
    mov ax, c
    mov bx, d
    div bx 

    add dx, a	

    mov ax, 4c00h
    int 21h

end main
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
	mov cx, c
	
	and bx, ax
	mov ax, cx
	mul c
	mul c
	mul c 
	cmp bx, ax
		
	je point1

	mov cx, c
	mov bx, b
	mov ax, a
	
	add cx, bx
	
	mul a
	mul a
	
	mov bx, ax
	mov ax, b
	
	mul b
	mul b
	
	add ax, bx
	
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
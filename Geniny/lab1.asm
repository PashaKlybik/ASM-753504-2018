.model small
.stack 256
.data
    a dw 26
    b dw 25
    c dw 3
    d dw 7
.code
main:
    mov ax, @data
    mov ds, ax
    
    mov ax,a
    dec ax
    mov bx,a
    and ax,bx
    mov bx,b
    cmp ax,bx
	jc firstBranch

	mov ax,0
	mov ax,c
	mov bx,0
	mov bx,b
	add ax,bx
	mov bx,d
	cmp bx,ax
	jc secondBranch
 
	mov ax,c
	mov bx,d
	div bx
	add ax,dx
	jmp endBranch

	secondBranch:
	mov ax,c
	mov bx,d
	XOR ax,bx
	jmp endBranch

	firstBranch:
	mov bx,b
	inc bx
	mov ax,b
	OR ax,bx
	    
	endBranch:

	mov ax,4c00h
    	int 21h
end main
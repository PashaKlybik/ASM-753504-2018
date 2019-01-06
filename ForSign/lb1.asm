.model small
.stack 256
.data
    a dw 13
    b dw 13
	n dw 17
	d dw 14
;    message db 'Hello world!', 13, 10, '$'
.code
main:
    mov ax, @data
    mov ds, ax

	 ; making sum

    mov ax, a
	mov bx, n
    mul bx
		mov cx, ax ; beckap
	mov ax ,b
	mov bx, d
	mul bx
	mov ax, 0
	add ax, bx
	add ax, cx

	 ; making next sum

		mov cx, ax ; snova beckap
	mov ax, a
	mov bx, d
    mul bx
    	push cx
	    mov cx, ax
	mov ax, b
	mov bx, n
	mul bx
	mov ax, 0
	add ax, bx
	add ax, cx
	;xor cx,cx
		pop cx

	 ; 1st compare

	cmp ax, cx
	jl nope
	jg nope
	mov ax, a
	mul ax
	jmp exit

	 ; if not

	nope:
	mov ax, a
	mov bx, n
	cmp ax, bx
	jl nopesecond
	jg nopesecond
	mov ax, a
	and ax, n
	jmp exit

	 ; if not

	nopesecond:
	mov ax, b
	or ax, n
	mov bx, ax
	mov ax, a
	sub ax, bx
	jmp exit

	exit:

    mov ax, 4c00h
    int 21h
end main

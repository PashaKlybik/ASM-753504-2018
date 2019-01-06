.model small
.stack 256
.data
    a dw 7
    b dw 5
	n dw 3
	d dw 9
;    message db 'Hello world!', 13, 10, '$'
.code
main:
    mov ax, @data
    mov ds, ax

	 ; making sum

    mov ax, a
	mov bx, n
    mul bx			;multiplying
	mov cx, ax 		;backup after assuming
	mov ax ,b
	mov bx, d
	mul bx			;multiplying
	mov ax, 0
	add ax, bx
	add ax, cx	;making sum
	 		   ; making next sum
	mov cx, ax ; snova beckap
	mov ax, a
	mov bx, d
    mul bx			;multiplying
    push cx			;saving cx
	mov cx, ax
	mov ax, b
	mov bx, n
	mul bx			;multiplying
	mov ax, 0
	add ax, bx
	add ax, cx		;making sum
	;xor cx,cx
		pop cx		;bringing back cx

	 				; 1st compare

	cmp ax, cx		;if equal
	jl nope
	jg nope 		;jump if all not
	mov ax, a
	mul ax ;result
	jmp exit

	 ; if not equal

	nope:				;jumppoint
	mov ax, a
	mov bx, n
	cmp ax, bx
	jle nopesecond
	mov ax, a
	and ax, n ;result
	jmp exit

	 ; if c<=a jump because it's not what we need

	nopesecond:			;jumppoint
	mov ax, b
	or ax, n
	mov bx, ax
	mov ax, a
	sub ax, bx ;result
	jmp exit

	exit:

    mov ax, 4c00h
    int 21h
end main

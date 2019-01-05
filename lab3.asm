.model small
.stack 100
.data
	digits_counter dw 0
    ten dw 10
    wrong_input db "...Incorrect input$"
    zero db "You tried to divide by zero...Nothing happened.$"
.code 

endl proc
	push dx
	push ax

	mov dl, 0AH
	mov ah, 02h
	int 21h
	
	pop ax
	pop dx
	ret
endl endp

input proc
	push si
	push dx
	push bx
	push cx

	scanf_prep:
	mov bx, 0
	mov dx, 0
	mov digits_counter, 0

	mov ah, 01h
	int 21h

	cmp al, '-'
	jz negative
	
	; positive
	mov si, 0
	jmp skip_reading

	negative:
		mov si, 1
	
	reading:
		mov ah, 01h
		int 21h

		skip_reading:

		cmp al, 8 ; backspace 
		jz backspace

		cmp al, 13
		jz good_input

		cmp al, 48 ; '0' = 48 '9' = 57 
		jc bad_input 

		cmp al, 58
		jnc bad_input

		mov cl, al ; bx = bx * 10 + al - 48

		mov ax, bx
		mul ten
		mov bx, ax

		cmp dx, 0 ; dx == 0 else too large
		jnz bad_input 

		sub cl, 48
		mov ch, 0
		add bx, cx ; if overflow CF = 1

		inc digits_counter

		jc bad_input
	jmp	reading

	backspace:
		cmp digits_counter, 0
		jz erase_minus ; -\b

		mov ax, bx
		div ten
		mov bx, ax

		mov dl, ' '
		mov ah, 02h
		int 21h

		mov dl, 8
		mov ah, 02h
		int 21h
		
		mov dl, 0
		dec digits_counter
		jmp reading

	erase_minus:
		mov dl, ' '
		mov ah, 02h
		int 21h

		mov dl, 8
		mov ah, 02h
		int 21h

		mov dl, 0
		jmp scanf_prep

	good_input:
		cmp digits_counter, 0
		jz jump_scanf_prep ; too long jump 

		mov ax, bx
		jmp validate_range

	jump_scanf_prep:
		jmp scanf_prep

	bad_input:
		lea dx, wrong_input
		mov ah, 09h
		int 21h

		mov ax, 0
		call endl
		jmp scanf_prep

	validate_range:
		; ax > 32767 + si
		; -[1, 2, 3, 4, 32768]
		; -[65535, 65534, 65533, 65532]
		add si, 32767
		cmp ax, si
		ja bad_input ; <= for unsigned

		sub si, 32767
		cmp si, 1

		jnz scanf_finish
		neg ax

	scanf_finish:
		pop cx
		pop bx
		pop dx
		pop si
	ret
input endp

;unsigned output
u_output proc
	push ax
	push cx
	push dx

	mov cx, 0
	mov dx, 0 

	division :
	    div ten
	    push dx
	    mov dx, 0
	   	inc cx

	    cmp ax, 0
	    jnz division

	cmp cx, 0
	jnz non_zero_came
	
	push 0
	mov cx, 1
	
	non_zero_came:
		pop dx
		add dx, '0'
		mov ah, 02h
		int 21h
	loop non_zero_came

	pop dx
	pop cx
	pop ax
	ret
u_output endp

output proc 
	push bx
	push dx
	push ax

	cwd
	cmp dx, 0
	jz plus

	mov bx, ax

	mov dx, '-'
	mov ah, 02h
	int 21h

	mov ax, bx
	neg ax

	plus:
	call u_output

	pop ax
	pop dx
	pop bx
	ret
output endp
	
main:
	mov ax, @data
	mov ds, ax

	call input
	call output
	call endl

	mov cx, ax

	call input
	call output
	call endl

	mov dx, cx ;swap ax cx
	mov cx, ax
	mov ax, dx

	mov dx, 0  
	cmp cx, 0
	jz div_by_zero

	cmp ax, 8000h ;-32768 
	jnz save_division
	cmp cx, 0FFFFh ;-1
	jnz save_division

	lea dx, wrong_input
	mov ah, 09h
	int 21h
	jmp end_main

	save_division:
		cwd
		idiv cx
		call output
		call endl
	jmp end_main 

	div_by_zero:
		lea dx, zero
		mov ah, 09h
		int 21h

	end_main:
	    mov ax, 4c00h
	    int 21h

end main
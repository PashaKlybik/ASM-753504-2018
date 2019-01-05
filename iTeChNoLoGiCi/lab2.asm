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
	push bx
	push cx
	push dx

	mov bx, 0
	mov dx, 0
	mov digits_counter, 0

	reading:
		mov ah, 01h
		int 21h

		cmp al, 8 ; backspace 
		jz backspace

		cmp al, 13
		jz good_input

		cmp al, 48 ; '0' = 48 
		jc bad_input

		cmp al, 58 ; 
		jnc bad_input

		mov cl, al ; bx = bx * 10 + al - 48

		mov ax, bx
		mul ten
		mov bx, ax

		cmp dx, 0 ; dx == 0 else too large
		jnz bad_input 

		sub cl, 48
		mov ch, 0
		add bx, cx

		inc digits_counter

		jc bad_input
	jmp	reading

	backspace:
		cmp digits_counter, 0
		jz reading

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

	good_input:
		cmp digits_counter, 0
		jz reading

		mov ax, bx
		jmp finish

	bad_input:
		lea dx, wrong_input
		mov ah, 09h
		int 21h

		mov bx, 0
		mov dx, 0
		mov ax, 0
		mov digits_counter, 0
		call endl
	jmp reading
		
	finish:
		pop dx
		pop cx
		pop bx
	ret
input endp

output proc
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

    mov dx, cx
    mov cx, ax
    mov ax, dx

    mov dx, 0  
    cmp cx, 0
    jz div_by_zero

    div cx

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

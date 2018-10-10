.model small
.stack 256
.data
ten dw 10
dividend_message db 10,13,"Enter a dividend.	 " ,10,13, "$"
too_big_message db "Oh no! (T___T) This number is too big!  Try again." ,10,13, "$"
wrong_symbols_message db "Oh no! (T___T) There are some wrong symbols! Try again. " ,10,13, "$"
divisor_message db 10,13, "Enter a divisor. ",10,13, "$" 
result_message db 10,13, "The result is: $"
reminder_message db 10,13, "The reminder is: $" 
blank_message db 10,13, "$" 
div_zero_message db 10,13, "Can't divide by zero! $"
.code

delete PROC 	;for erasing a symbol
	push ax
	push bx	
	push cx		 

	mov bh, 0
	mov cx, 1	 ;number of spaces
	mov al, ' ' 
	mov ah, 0AH 	;write character at the cursor's position
	int 10h 

	pop cx
	pop bx
	pop ax
	ret 
delete ENDP

printminus proc
	push ax
	push dx	
	
	mov dl,'-'
	mov ah,02h
	int 21h
	
	pop dx
	pop ax
	ret 
printminus ENDP

;for printing the number from ax
print PROC	
	push ax
	push bx	
	push cx	
	push dx	
		
	mov bx,ten
	xor cx,cx
	
	test ax, 1000000000000000b
	jz cycle1
	call printminus
	neg ax

	cycle1:
	xor dx,dx
	div bx
	inc cx
	push dx
	cmp ax,0
	JNZ cycle1

	cycle2:
	pop dx
	add dl,'0'
	mov ah,02h
	int 21h
	loop cycle2

	pop dx
	pop cx
	pop bx
	pop ax
	RET
print endp

print_wrong_symbols_message PROC
	push ax	
	push dx	
	
	mov dx,offset wrong_symbols_message
	mov ah,09h
	int 21h	
	
	pop dx
	pop ax
	RET
print_wrong_symbols_message endp

enter_number PROC	;procedure for entering a number from the keyboard
	push bx	
	push cx	
	push dx	

	xor bx,bx
	xor si,si

continue_entering:
	mov ah,01h
	int 21h
	xor di,di
	cmp al,13 	;enter
	jz next	
	cmp  al,8	;backspace
	jz bckspace
	cmp al,27
	jz escape	;escape
	cmp al,'-'
	jz minus	;minus
	sub al,'0'
	cmp al,9	;not numbers:
	ja wrong_symbol	;letter/symbol
	xor cx,cx	
	mov cl,al
	mov ax,bx
	mul ten
	cmp dx,0	;overflow?
	jnz endpr
	add ax,cx
	jc endpr	;overflow[2]
	cmp si,1	;overflow[3]
	jz negative
	cmp ax,32767
	ja endpr
	here:
	mov bx,ax
	jmp continue_entering

negative:
	cmp ax,32768
	ja endpr
	jmp here

escape:
	xor si,si
	xor bx,bx
	mov cx,6
	cycle3:
	mov dl,8
	mov ah,02h	; print backspace
	int 21h
	call delete
	loop cycle3	
	cmp di,1
	jz continue_processing_wrong_symbols
	cmp di,2
	jz continue_processing_overflow
	jmp continue_entering

next: 
	jmp newnext
	
minus:
	cmp bx,0
	jnz wrong_symbol
	cmp si,0
	jnz wrong_symbol
	mov si,1
	jmp continue_entering	
	
bckspace:
	xchg bx,ax
	xor dx,dx
	div ten
	xchg bx,ax
	cmp bx,0
	jnz cont
	xor si,si
	cont:
	call delete
	jmp continue_entering
	
wrong_symbol:
	mov di,1
	jmp escape
	continue_processing_wrong_symbols:
	call print_wrong_symbols_message
	jmp continue_entering
	
endpr:
	mov di,2
	jmp escape
	continue_processing_overflow:
	mov dx,offset too_big_message
	mov ah,09h
	int 21h
	xor bx,bx
	xor si,si
	jmp continue_entering
	
newnext:
	mov ax,bx
	cmp si,1
	jnz endit
	neg ax
	endit:
	pop dx
	pop cx
	pop bx
	RET
enter_number endp

main:

	mov ax, @data
	mov ds, ax

	;enter and print a dividend
	mov dx,offset dividend_message
	mov ah,09h
	int 21h
	call enter_number
	call print
	mov bx,ax

	;enter and print a divisor
	mov dx,offset divisor_message
	mov ah,09h
	int 21h
	call enter_number
	call print
	xchg bx,ax

	cmp bx,0
	jz show_error_mess
	
	xchg cx,ax
	mov dx,offset result_message
	mov ah,09h
	int 21h

	;print result
	xchg cx,ax
	xor dx,dx
	cwd
	idiv bx
	call print

	xchg cx,dx
	mov dx,offset reminder_message
	mov ah,09h
	int 21h

	;print reminder
	xchg cx,ax
	test ax, 1000000000000000b
	jz print_it
	neg ax
	print_it:
	call print
	jmp exit
	
	show_error_mess:
	mov dx,offset div_zero_message
	mov ah,09h
	int 21h
	
	exit:
	mov dx,offset blank_message
	mov ah,09h
	int 21h

	mov ax, 4c00h
	int 21h

end main
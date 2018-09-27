.model small
.stack 256
.data
ten dw 10
divfmessage db 10,13,"Enter a dividend.	 " ,10,13, "$"
errormessage db 10,13, "Oh no! (T___T) This number is too big!  Try again." ,10,13, "$"
errormessagefl db 10,13, "Oh no! (T___T) There are some wrong symbols! Try again. " ,10,13, "$"
divisfmessage db 10,13, "Enter a divisor. ",10,13, "$" 
resmessage db 10,13, "The result is: $"
res2message db 10,13, "The reminder is: $" 
endmessage db 10,13, "$" 
er2message db 10,13, "Can't divide by zero! $"
.code

delete PROC ;процедура для удаления символа
	push ax
	push bx	
	push cx	
	push dx	 

	mov bh, 0
	mov cx, 1 ;количество пробелов
	mov al, ' ' 
	mov ah, 0AH ;записать символ на позиции курсора
	int 10h 

	pop dx 
	pop cx
	pop bx
	pop ax
	ret 
delete ENDP

;процедура для вывода числа из AX на экран
printfromax PROC	
	push ax
	push bx	
	push cx	
	push dx	
		
	mov bx,10
	xor cx,cx

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

	mov ax,dx
	pop dx
	pop cx
	pop bx
	pop ax
	RET
printfromax endp

errormessageforlet PROC
	push ax
	push bx	
	push cx	
	push dx	
	mov dx,offset errormessagefl   
	mov ah,09h
	int 21h	
	pop dx
	pop cx
	pop bx
	pop ax
	RET
errormessageforlet endp

entertoax PROC	;процедура для ввода числа с клавиатуры в регистр AX

	push bx	
	push cx	
	push dx	

	xor bx,bx

continuemark:
	mov ah,01h
	int 21h
	cmp al,13 	;enter
	jz next	
	cmp  al,8	;backspace
	jz bckspace
	cmp al,27
	jz escape	;escape
	sub al,'0'
	cmp al,9	;not numbers:
	ja letter	;letter/symbol
	xor cx,cx	
	mov cl,al
	mov ax,bx
	xor dx,dx
	mul ten
	cmp dx,0	;переполнение?
	jnz endpr
	add ax,cx
	jc endpr	;переполнение?
	mov bx,ax
	jmp continuemark

escape:
	xor bx,bx
	mov cx,6
	cycle3:
	mov dl,8
	mov ah,02h	; вывод backspace'a
	int 21h
	call delete
	loop cycle3	
	jmp continuemark

next: 
	jmp newnext

bckspace:
	xchg bx,ax
	xor dx,dx
	div ten
	xchg bx,ax
	call delete
	jmp continuemark
	
letter:
	call errormessageforlet
	xor bx,bx
	jmp continuemark
	
endpr:
	mov dx,offset errormessage       
	mov ah,09h
	int 21h
	xor bx,bx
	jmp continuemark
	
newnext:
	mov ax,bx

	pop dx
	pop cx
	pop bx
	RET
entertoax endp

main:

	mov ax, @data
	mov ds, ax

	;ввод и вывод делимого
	mov dx,offset divfmessage
	mov ah,09h
	int 21h
	call entertoax
	call printfromax
	mov bx,ax

	;ввод и вывод делителя
	mov dx,offset divisfmessage
	mov ah,09h
	int 21h
	call entertoax
	call printfromax
	xchg bx,ax

	cmp bx,0
	jz	errormess
	
	xchg cx,ax
	mov dx,offset resmessage
	mov ah,09h
	int 21h

	;вывод целой части от деления
	xchg cx,ax
	xor dx,dx
	div bx
	call printfromax

	xchg cx,dx
	mov dx,offset res2message
	mov ah,09h
	int 21h

	;вывод остатка от деления
	xchg cx,ax
	call printfromax
	jmp endprog
	
	errormess:
	mov dx,offset er2message
	mov ah,09h
	int 21h
	
	endprog:
	mov dx,offset endmessage
	mov ah,09h
	int 21h

	mov ax, 4c00h
	int 21h

end main
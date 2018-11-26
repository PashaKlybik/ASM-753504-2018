.model small
.stack 256
.data
    
	divChar db '/',13,10,'$'
	equalityChar db '=',13,10,'$'
	endlSymbol db 13,10,'$'
	errorBlockMessage db 13,10,'Something go wrong',13,10,'$'
	exceptionMessage db 13,10,'Print something',13,10,'$'
	decimalConst dw 10
	
.code

PrintString proc

	push ax
	
	mov ah,9 
	int 21h
	
	pop ax
	
	ret
PrintString endp

RemoveSymbol proc

	push ax 
	push bx 
	push cx 

	mov ah, 0AH  
	mov bh, 0 
	mov al, ' ' 
	mov cx, 1 
	int 10h 

	pop cx 
	pop bx 
	pop ax
	
	ret 
RemoveSymbol endp

EnterNumber proc

	push bx
	push cx
	push dx
	
	xor bx,bx
	xor cx,cx
	xor ax,ax
entering:	
	mov ah,01h
	int 21h
	cmp al,8
	jle backspaceChar
	cmp al,13
	jle enterChar
	cmp al,'0'
	jb badChar
	cmp al,'9'
	ja badChar
	
	xor ah,ah
	sub ax,'0'
	mov cx,ax
	mov ax,bx
	xor dx,dx
	mul decimalConst
	cmp dx,0
	jnz errorBlock 
	add ax,cx
	jc errorBlock
	mov bx,ax
	jmp entering
	
backspaceChar:
	xchg bx,ax 
	xor dx,dx 
	div decimalConst
	xchg bx,ax 
	call RemoveSymbol
	jmp entering 
	
badChar:
	mov dl,8 
	mov ah,02h 
	int 21h
	call RemoveSymbol
	jmp entering
	
errorBlock:
	xor bx,bx
	mov dx, offset errorBlockMessage
	call PrintString
	jmp entering
	
exception:
	mov dx, offset exceptionMessage
	call PrintString
	jmp entering
	
enterChar:
	test bx,bx
	je exception 
	mov ax,bx
	
	pop dx
	pop cx
	pop bx
		
	ret
EnterNumber endp

ConvertToStr proc
	
	push bx
	push cx
	push dx

	xor cx,cx
	
convertingFromNumber:
	xor dx,dx
	div decimalConst
	push dx
	inc cx
	test ax,ax
	jnz convertingFromNumber
	
convertingToStr:
	mov ah,02h
	pop dx
	add dx,'0'
	int 21h
	loop convertingToStr
	
	mov dx,offset endlSymbol
	call PrintString
	
	pop dx
	pop cx
	pop bx

	ret
ConvertToStr endp

main:

	mov ax,@data
	mov ds,ax
		
	call EnterNumber
	xchg bx,ax
	mov dx, offset divChar 
	call PrintString
	call EnterNumber
	xchg bx,ax
	xor dx,dx 
	div bx
	mov dx,offset equalityChar
	call PrintString
	call ConvertToStr 
		
	mov ax, 4C00h
	int 21h
		
end main

	
	

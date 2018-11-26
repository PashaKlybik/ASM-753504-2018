.model small
.stack 256
.data
    
	divChar db '/',13,10,'$'
	equalityChar db '=',13,10,'$'
	endlSymbol db 13,10,'$'
	errorBlockMessage db 13,10,'Something go wrong',13,10,'$'
	exceptionMessage db 'Print something',13,10,'$'
	buffString db '     $'
	decimalConst dw 10
	
.code

PrintString proc

	push ax
	
	mov ah,9 
	int 21h
	xor dx,dx
	
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
	push si
	
	xor si,si
	xor bx,bx
	
entering:	
	mov ah,01h
	int 21h
	cmp al,8
	je backspaceChar
	cmp al,13
	je enterChar
	cmp al, '-'
	je minusChar	
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
	cmp si,1
	je checkForOverflow 
	cmp ax,32767
	jnbe errorBlock
endEntering:
	mov bx,ax
	jmp entering
	
signCheck:
	cmp si,0
	je clearSymbol
	mov si,0
	jmp clearSymbol
	
checkForOverflow:
	cmp ax,-32768
	jnbe errorBlock
	jmp endEntering
	
backspaceChar:
	test bx,bx
	je signCheck
clearSymbol:
	xchg bx,ax 
	xor dx,dx 
	div decimalConst
	xchg bx,ax 
	call RemoveSymbol
	jmp entering 

enterChar:
	test bx,bx
	je exception 
	cmp si,0
	je toExit
	neg bx
	jmp toExit
	
minusChar:
	cmp bx,0
	jne errorBlock
	cmp si,0
	jne errorBlock
	mov si,1
	jmp entering
	
badChar:
	mov dl,8 
	mov ah,02h 
	int 21h
	call RemoveSymbol
	jmp entering
	
errorBlock:
	xor bx,bx
	mov si,0
	mov dx, offset errorBlockMessage
	call PrintString
	jmp entering
	
exception:
	mov dx, offset exceptionMessage
	call PrintString
	jmp entering
	
		
toExit:
	mov ax,bx
	
	pop si
	pop dx
	pop cx
	pop bx
		
	ret
EnterNumber endp

Exceptions proc

	push dx
	
	cmp ax,-32768
	je overflowingexception
	jmp toExitExceptions
	
overflowingexception:
	cmp bx,-1
	jnz toExitExceptions
	mov dx,offset errorBlockMessage
	call PrintString
	mov ax,4c00h
	int 21h
	
toExitExceptions:
	
	pop dx
	ret
Exceptions endp

ConvertToStr proc
	
	push bx
	push cx
	push dx

	test ax,ax
	jns continue
	push ax
	mov ah,02h
	mov dx,'-'
	int 21h
	xor ah,ah
	pop ax
	neg ax
	
continue:
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
	xchg ax,bx
	
	mov dx,offset divChar
	call PrintString
	
	call EnterNumber
	xchg ax,bx
	call Exceptions
	xor dx,dx
	cmp ax,0
	jl convertDX
	jmp continueDIV
	convertDX:
	cwd
	continueDIV:
	idiv bx
	mov dx,offset equalityChar
	call PrintString
	call ConvertToStr
		
	mov ax, 4C00h
	int 21h
		
end main

	
	
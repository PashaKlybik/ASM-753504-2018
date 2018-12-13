.model small
.stack 256
.data
    
	N dw ?
	K dw ?
	M dw ?
	L dw ?
	columnShift dw ?
	lineShift dw ?
	flag dw 0
	tmp dw 0
	strLength dw ?
	decimalConst dw 10
	arrayA dw 50 dup(0)
	arrayB dw 50 dup(0)
	arrayC dw 50 dup(0)
	multiplyErrorMessage db 'Cant multiply this matrices',13,10,'$'
	printArrayAMessage db '-------Matrix [A]-------','$'
	printArrayBMessage db '-------Matrix [B]-------','$'
	printArrayCMessage db '-------Matrix [C]-------','$'
	printLine db '------------------------',13,10,'$'
	enterArrayAMessage db '----Enter matrix [A]----',13,10,'$'
	enterArrayBMessage db '----Enter matrix [B]----',13,10,'$'
	spaceChar db ' ','$'
	endlSymbol db 13,10,'$'
	errorBlockMessage db 'Something go wrong',13,10,'$'
	exceptionMessage db 'Print something',13,10,'$'
	enterColumnsNumberMessage db 'Print number of columns: ','$'
	enterLinesnumberMessage db 'Print number of lines: ','$'
	
.code

PrintStr proc

	push ax
	
	mov ah,9 
	int 21h
	xor dx,dx
	
	pop ax
	
	ret
PrintStr endp

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
	cmp al,32
	je enterChar
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
	call PrintStr
	jmp entering
	
exception:
	mov dx, offset exceptionMessage
	call PrintStr
	jmp entering
	
toExit:
	mov ax,bx
	
	pop si
	pop dx
	pop cx
	pop bx
		
	ret
EnterNumber endp

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
	
	pop dx
	pop cx
	pop bx

	ret
ConvertToStr endp

EnterMatrixSize proc

	push cx
	push dx

	xor bx,bx
	
repeatFirstNumber:
	xor ax,ax
	lea dx,enterLinesNumberMessage
	call PrintStr
	call EnterNumber
	cmp ax,0
	jle	repeatFirstNumber
	xchg ax,bx
	
repeatSecondNumber:
	xor ax,ax
	lea dx,enterColumnsNumberMessage
	call PrintStr
	call EnterNumber
	cmp ax,0
	jle repeatSecondNumber
	
	pop dx
	pop cx
	
	ret
EnterMatrixSize endp

EnterMatrix proc

	push ax
	push bx
	push dx
	
enteringArray:
	call EnterNumber
	mov [di],ax
	add di,2
	loop enteringArray
	
	pop dx
	pop bx
	pop ax

	ret
EnterMatrix endp

PrintMatrix proc

	push ax
	push bx
	push dx

printingArray:	
	xor ax,ax
	mov ax,cx
	div [strLength]
	cmp dx,0
	je printEndl
	xor dx,dx
continuePrinting:
	xor ax,ax
	mov ax,[di]
	call ConvertToStr
	lea dx,spaceChar
	call PrintStr
	add di,2
	loop printingArray
	
	jmp exitFromPrinting
	
printEndl:
	xor dx,dx
	lea dx,endlSymbol
	call PrintStr
	jmp continuePrinting	
	
	
exitFromPrinting:	
	lea dx,endlSymbol
	call PrintStr
	lea dx,printLine
	call PrintStr

	pop dx
	pop bx
	pop ax
	
	ret
PrintMatrix endp

MatrixMultiplication proc

	push ax
	push bx
	push dx
	push cx
	
	xor ax,ax
	xor bx,bx
	xor cx,cx
	mov ax,K
	mov bx,L
	cmp ax,bx
	je startMultiplication
	lea dx,multiplyErrorMessage
	call PrintStr
	mov ax,4c00h
	int 21h

startMultiplication:
	xor ax,ax
	mov ax,M
	mov bx,2
	mul bx
	mov columnShift,ax
	xor ax,ax
	mov ax,K
	mul bx
	mov lineShift,ax
	lea di,arrayA
	lea si,arrayB
	mov cx,M
nextLineMultiplication:

	push cx
	mov cx,K
	nextColumnPultiplication:

		push cx
		mov cx,K
		multiplication:
			xor ax,ax
			xor dx,dx
			xor bx,bx
			
			mov ax,[di]
			mov bx,[si]
			mul bx
			add tmp,ax
			add di,2
			add si,columnShift	
			loop multiplication
		
		push di
		mov ax,flag
		mov bx,2
		mul bx
		inc flag
		lea di,arrayC
		add di,ax
		mov ax,tmp
		mov tmp,0
		mov [di],ax
		pop di
		
		mov cx,K
		xoring:
			sub di,2
			sub si,columnShift
			loop xoring
		
		pop cx
		add si,2
		loop nextColumnPultiplication
	
	add di,lineShift
	lea si ,arrayB
	
	pop cx
	
	loop nextLineMultiplication

	pop cx
	pop dx
	pop bx
	pop ax

	ret
MatrixMultiplication endp

main:

	mov ax,@data
	mov ds,ax
	xor ax,ax
	
	lea dx,enterArrayAMessage
	call PrintStr
	call EnterMatrixSize
	mov N,bx
	mov K,ax
	xor dx,dx
	mul bx
	mov cx,ax
	lea di,arrayA
	call EnterMatrix
	
	lea dx,enterArrayBMessage
	call PrintStr
	call EnterMatrixSize
	mov L,bx
	mov M,ax
	xor dx,dx
	mul bx
	mov cx,ax
	lea di,arrayB
	call EnterMatrix
	
	lea dx,printArrayAMessage
	call PrintStr
	xor ax,ax
	xor bx,bx
	mov ax,K
	mov strLength,ax
	mov bx,N
	mul bx
	mov cx,ax
	lea di,arrayA
	call PrintMatrix
	
	lea dx,printArrayBMessage
	call PrintStr
	xor ax,ax
	xor bx,bx
	mov ax,M
	mov strLength,ax
	mov bx,L
	mul bx
	mov cx,ax
	lea di, arrayB
	call PrintMatrix
	
	call MatrixMultiplication
	
	lea dx,printArrayCMessage
	call PrintStr
	mov ax,M
	mov strLength,ax
	mov bx,N
	mul bx
	mov cx,ax
	lea di, arrayC
	call PrintMatrix
	
	mov ax, 4C00h
	int 21h

end main
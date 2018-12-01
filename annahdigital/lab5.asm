.model small
.stack 256
.data
ten dw 10
sum dw  0
enterRowsMessage db 10,13,"Enter a number of the rows (N). " ,10,13, "$"
enterColumnsMessage db 10,13, "Enter a number of the columns (M). ",10,13, "$" 
enteringSizeErrorMessage db 10,13, "The numbers of rows and columns can't be negative or zero. ",10,13, "$" 
enterArrayElement db 10,13, "Enter an element of the matrix. ",10,13, "$"  
rows dw 0
columns dw 0
array dw 100 dup(?)
tooBigMessage db "Oh no! (T___T) This number is too big!  Try again." ,10,13, "$"
wrongSymbolsMessage db "Oh no! (T___T) There are some wrong symbols! Try again. " ,10,13, "$"
resultMessage db 10,13, "The result is $"
blankMessage db 10,13, "$" 
.code

delete PROC     ;for erasing a symbol
    push ax
    push bx    
    push cx         
    mov bh, 0
    mov cx, 1     ;number of spaces
    mov al, ' ' 
    mov ah, 0AH     ;write character at the cursor's position
    int 10h 
    pop cx
    pop bx
    pop ax
    ret 
delete ENDP

printMinus proc
    push ax
    push dx    
    mov dl,'-'
    mov ah,02h
    int 21h
    pop dx
    pop ax
    ret 
printMinus ENDP

print PROC    ;for printing the number from ax
    push ax
    push bx    
    push cx    
    push dx           
    mov bx,ten
    xor cx,cx
    test ax, 1000000000000000b
    jz  processingNumbers
	call printMinus
    neg ax
    processingNumbers:
    xor dx,dx
    div bx
    inc cx
    push dx
    cmp ax,0
    JNZ processingNumbers
    printingNumbers:
    pop dx
    add dl,'0'
    mov ah,02h
    int 21h
    loop printingNumbers
    pop dx
    pop cx
    pop bx
    pop ax
    RET
print endp

printWrongSymbolsMessage PROC
    push ax    
    push dx        
    mov dx,offset wrongSymbolsMessage
    mov ah,09h
    int 21h      
    pop dx
    pop ax
    RET
printWrongSymbolsMessage endp

enterNumber PROC    ;procedure for entering a number from the keyboard
    push bx    
    push cx    
    push dx   
    xor bx,bx
    xor di,di
continueEntering:
    mov ah,01h
    int 21h
    ;xor di,di
    cmp al,13     ;enter
    jz next    
    cmp  al,8    ;backspace
    jz bckspace
    cmp al,27
    jz escape    ;escape
    cmp al,'-'
    jz minus    ;minus
    sub al,'0'
    cmp al,9    ;not numbers:
    ja wrongSymbolnext    ;letter/symbol
    continueProcessing:
    xor cx,cx    
    mov cl,al
    mov ax,bx
    mul ten
    cmp dx,0    ;overflow?
    jnz endpr
    add ax,cx
    jc endpr    ;overflow[2]
    cmp di,1    ;overflow[3]
    jz negative
    cmp ax,32767
    ja endpr
    here:
    mov bx,ax
    jmp continueEntering
negative:
    cmp ax,32768
    ja endpr
    jmp here
escape:
    xor di,di
    xor bx,bx
    mov cx,6
    cycle3:
    mov dl,8
    mov ah,02h    ; print backspace
    int 21h
    call delete
    loop cycle3    
    cmp di,1
    jz continueProcessingWrongSymbols
    cmp di,2
    jz continueProcessingOverflow
    jmp continueEntering
next: 
    jmp newnext    
minus:
    cmp bx,0
    jnz wrongSymbol
    cmp di,1
    jz wrongSymbol
    mov di,1
    jmp continueEntering     
wrongSymbolnext:
    jmp wrongSymbol    
bckspace:
    xchg bx,ax
    xor dx,dx
    div ten
    xchg bx,ax
    cmp bx,0
    jnz cont
    xor di,di
    cont:
    call delete
    jmp continueEntering    
wrongSymbol:
    mov di,1
    jmp escape
    continueProcessingWrongSymbols:
    call printWrongSymbolsMessage
    jmp continueEntering    
endpr:
    mov di,2
    jmp escape
    continueProcessingOverflow:
    mov dx,offset tooBigMessage
    mov ah,09h
    int 21h
    xor bx,bx
    xor di,di
    jmp continueEntering    
newnext:
    mov ax,bx
    cmp di,1
    jnz endit
    neg ax
endit:	
    pop dx
    pop cx
    pop bx
    RET
enterNumber endp

countSum proc		;for counting sum of elements in even columns
	push ax
	push bx
	push cx
	push si
	
	mov si,0		;rows
	processingArrayRows:
	mov bx,0		;columns
	processingArrayColumns:
	cmp bx,columns
	jae endProcessingColumns
	xor dx,dx
	mov cx,4
	mov ax,bx
	div cx
	cmp dx,0
	jz increaseColumnCount
	mov dx,array[si][bx]
	add sum,dx
	increaseColumnCount:
	add bx,2
	jmp processingArrayColumns
	endProcessingColumns:
	add si,columns
	cmp si,rows
	jae endProcessingRows
	jmp processingArrayRows
	endProcessingRows:
	pop si
	pop cx
	pop bx
	pop ax
	ret
countSum endp

printMessage PROC
    push ax        
    mov ah,09h
    int 21h        
    pop ax
    RET
printMessage endp

main:
    mov ax, @data
    mov ds, ax
	
	mov dx,offset enterRowsMessage		;entering the number of the rows
	call printMessage
	call enterNumber
	mov rows,ax
	cmp ax,0
	jz errorInArrayInput
	test ax, 1000000000000000b
    jnz errorInArrayInput	
	mov dx,offset enterColumnsMessage		;entering the number of the columns
	call printMessage
	call enterNumber
	mov columns,ax
	cmp ax,0
	jz errorInArrayInput
	test ax, 1000000000000000b
    jnz errorInArrayInput
	
	mov cx,2
	mov ax, columns
	mul cx
	mov columns,ax
	mov ax,rows
	mul columns
	mov rows,ax
	xor si,si
	xor bx,bx
	continueEnteringElements:
	cmp si,rows
	jz toTheSumCounting
	cmp bx,columns
	jz encreaseCurrentRowNumber
	mov dx,offset enterArrayElement
	call printMessage
	call enterNumber
	mov array[si][bx],ax
	add bx,2
	jmp continueEnteringElements
	encreaseCurrentRowNumber:
	add si,columns
	xor bx,bx
	jmp continueEnteringElements	
	
	toTheSumCounting:
	call countSum		;counting sum
	mov dx,offset resultMessage
	call printMessage
	mov ax,sum
	call print			;printing sum
	jmp exitFinally

	errorInArrayInput:
	mov dx,offset enteringSizeErrorMessage
	call printMessage
	
	exitFinally:
    mov dx,offset blankMessage
	call printMessage
    mov ax, 4c00h
    int 21h
end main
.model small
.stack 256
.data
ten dw 10
dividendMessage db 10,13,"Enter a dividend.     " ,10,13, "$"
tooBigMessage db "Oh no! (T___T) This number is too big!  Try again." ,10,13, "$"
wrongSymbolsMessage db "Oh no! (T___T) There are some wrong symbols! Try again. " ,10,13, "$"
divisorMessage db 10,13, "Enter a divisor. ",10,13, "$" 
resultMessage db 10,13, "The result is: $"
reminderMessage db 10,13, "The reminder is: $" 
blankMessage db 10,13, "$" 
divByZeroMessage db 10,13, "Can't divide by zero! $"
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

;for printing the number from ax
print PROC    
    push ax
    push bx    
    push cx    
    push dx    
        
    mov bx,ten
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

continueEntering:
    mov ah,01h
    int 21h
    xor di,di
    cmp al,13     ;enter
    jz next    
    cmp  al,8    ;backspace
    jz bckspace
    cmp al,27
    jz escape    ;escape
    sub al,'0'
    cmp al,9    ;not numbers:
    ja wrongSymbol    ;letter/symbol
    cmp al,0
    jz zeroProcessing
    continueProcessing:
    xor cx,cx    
    mov cl,al
    mov ax,bx
    mul ten
    cmp dx,0    ;overflow?
    jnz endpr
    add ax,cx
    jc endpr    ;overflow?[2]
    mov bx,ax
    jmp continueEntering

zeroProcessing:
    cmp bx,0
    jnz continueProcessing
    mov dl,8
    mov ah,02h    ; print backspace
    int 21h
    call delete
    jmp continueEntering
    
escape:
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

bckspace:
    xchg bx,ax
    xor dx,dx
    div ten
    xchg bx,ax
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
    jmp continueEntering
    
next:
    mov ax,bx

    pop dx
    pop cx
    pop bx
    RET
enterNumber endp

main:

    mov ax, @data
    mov ds, ax

    ;enter and print a dividend
    mov dx,offset dividendMessage
    mov ah,09h
    int 21h
    call enterNumber
    call print
    mov bx,ax

    ;enter and print a divisor
    mov dx,offset divisorMessage
    mov ah,09h
    int 21h
    call enterNumber
    call print
    xchg bx,ax

    cmp bx,0
    jz showErrorMessage
    
    xchg cx,ax
    mov dx,offset resultMessage
    mov ah,09h
    int 21h

    ;print result
    xchg cx,ax
    xor dx,dx
    div bx
    call print

    xchg cx,dx
    mov dx,offset reminderMessage
    mov ah,09h
    int 21h

    ;print reminder
    xchg cx,ax
    call print
    jmp exit
    
    showErrorMessage:
    mov dx,offset divByZeroMessage
    mov ah,09h
    int 21h    
    
    exit:
    mov dx,offset blankMessage
    mov ah,09h
    int 21h

    mov ax, 4c00h
    int 21h

end main
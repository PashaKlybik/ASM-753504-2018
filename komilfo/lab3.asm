.model small
.stack 256
.data
    buffer db 255 DUP (0)
    wrongSymbolMessage db 10,"wrong symbol error", 10, '$' 
    overflowMessage db 10,"overflow", 10, '$'
    dividingByZeroMessage db 10,"dividing by zero error", 10, '$'
    emptyOperandMessage db 10,"empty operand error" , 10, '$' 
    dividend db "dividend: $"
    divider db "divider: $"
    result db "result: $"
    separator db "------------------------", 10, '$'
.386
.code
newRow proc
    push dx
    push ax
    mov dl, 10
    mov ah, 02h
    int 21h
    pop ax
    pop dx
    ret
newRow endp

inputSignedWord proc
    push dx               
    call inputString  
    call stringToSignedWord
    pop dx                  
    ret 
inputSignedWord endp
 
; OUT: DX - addr str 
; AL - length str
inputString proc
    push cx         
    mov cx,ax   
    mov al, 7
    mov ah,0Ah      
    mov [buffer],al 
    mov byte[buffer+1],0   
    mov dx, offset buffer  
    int 21h         
    mov al,[buffer+1]  
    add dx,2           
    mov ah,ch          
    pop cx             
    ret
inputString endp
    
stringToUnsignedWord proc
    push bx
    mov si,dx          
    mov di,10          
    xor cx,cx
    mov cl,al          
    xor ax,ax          
    xor bx,bx       
    
    handlerLoop:
    mov bl,[si]     
    inc si          
    cmp bl,'0'      
    jl wrongSymbolError  
    cmp bl,'9'      
    jg wrongSymbolError  
    sub bl,'0'      
    mul di          
    jc overflowError  
    add ax,bx       
    jc overflowError  
    loop handlerLoop       
    
    pop bx      
    ret   
stringToUnsignedWord endp

stringToSignedWord proc
    push bx         
    push dx
    test al,al      
    jz emptyOperandError  
    mov bx,dx       
    mov bl,[bx]     
    cmp bl,'-'      
    jne unsigned      
    inc dx          
    dec al          
unsigned:
    call stringToUnsignedWord 
    cmp bl,'-'      
    jne positiveOperand  
    cmp ax,32768    
    ja overflowError  
    neg ax  
    jmp negativeOperand    
positiveOperand:
    cmp ax,32767    
    ja overflowError  
negativeOperand:
    clc          
    pop dx          
    pop bx
    ret
stringToSignedWord endp

printWord proc  
    push bx
    push cx
    push dx
  
    mov bx, 10
    xor cx,cx
    
    readerLoop:
    xor dx,dx
    div bx
    push dx
    inc cx
    cmp ax,0
    jnz readerLoop
        
    printLoop:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop printLoop

    pop dx
    pop cx
    pop bx
    
    ret
printWord endp

dividing proc
    push cx
    push dx
    
	cmp ax,0
	je positive
    mov cx, bx
    xor cx, ax
    cmp cx, 32768
    jc positive
    push ax
    mov dl, '-'
    mov ah, 02h
    int 21h    
    pop ax
    
    positive:
    cmp ax, 32768
    jc signedMagnitude_1
    neg ax
    signedMagnitude_1:
    cmp bx, 32768
    jc signedMagnitude_2
    neg bx
    signedMagnitude_2:
    xor dx,dx
    div bx
    
    pop dx
    pop cx
    
    ret
dividing endp

main:   
    mov ax, @data
    mov ds, ax
    
    lea dx, dividend
    mov ah, 09h
    int 21h    
	
    call inputSignedWord
    call newRow
    push ax
    
    lea dx, divider
    mov ah, 09h
    int 21h

    call inputSignedWord
    cmp ax, 0
    jz dividingByZeroError
    call newRow
    mov bx, ax
    pop ax
    
    push ax
    lea dx, result
    mov ah, 09h
    int 21h
    pop ax
    call dividing
    
    call printWord	
	call newRow    
    jmp mainExit
    
dividingByZeroError:
    lea dx, dividingByZeroMessage
    jmp showError
    
wrongSymbolError:
    lea dx, wrongSymbolMessage
    jmp showError
    
overflowError:
    lea dx, overflowMessage
    jmp showError

emptyOperandError: 
    lea dx, emptyOperandMessage    

showError:
    mov ah, 09h
    int 21h 
    
    lea dx, separator 
    mov ah, 09h
    int 21h
    
    jmp main
    
mainExit:    
    mov ax, 4c00h
    int 21h
end main

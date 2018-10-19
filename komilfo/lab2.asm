.model small
.stack 256
.data
    a dw 134
    buffer db 255 DUP (0)
    wrongSymbolMessage db 10,"wrong symbol error", 10, '$' 
    overflowMessage db 10,"overflow", 10, '$'
    dividingByZeroMessage db 10,"dividing by zero error", 10, '$'
    dividend db "dividend: $"
    divider db 10,"divider: $"
    result db 10,"result: $"
    separator db "------------------------", 10, '$'
.code
        
printWord proc    
    mov bx, 10
    xor cx,cx
    
    readerLoop:
    xor dx,dx
    div bx
    push dx
    inc cx
    cmp ax,0
    jnz readerLoop
        
    printingLoop:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop printingLoop
        
    ret
printWord endp

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
 
; OUT: DX - addr str 
; AL - length str
input proc    
    mov ah, 0Ah
    mov byte [buffer],253
    mov dx, offset buffer + 1
    int 21h
    add dx, 2
    mov al, [buffer+2]
    ret       
input endp

strToWord proc
    mov si,dx          
    mov di,10          
    xor cx,cx
    mov cl,al          
       
    xor ax,ax          
    xor bx,bx          
    ret
strToWord endp

strHandler proc
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
    ret
strHandler endp

main:   
    mov ax, @data
    mov ds, ax
        
    lea dx, dividend
    mov ah, 09h
    int 21h
    
    call input
    call strToWord
    call strHandler
    push ax
    
    lea dx, divider
    mov ah, 09h
    int 21h
    call input
    call strToWord
    call strHandler    
    
    cmp ax,0
    jz dividingByZeroError
    push ax
    
    lea dx, result
    mov ah, 09h
    int 21h
    
    pop ax    
    mov bx, ax
    pop ax
    xor dx,dx
    div bx
    call printWord
    call newRow
    jmp exit
    
    dividingByZeroError:
    lea dx, dividingByZeroMessage
    jmp showError
    
    wrongSymbolError:
    lea dx, wrongSymbolMessage
    jmp showError
    
    overflowError:
    lea dx, overflowMessage
    
    showError:
    mov ah, 09h
    int 21h 
    lea dx, separator
    mov ah, 09h
    int 21h 
    jmp main    
    
    exit:          
    mov ax, 4c00h
    int 21h
end main
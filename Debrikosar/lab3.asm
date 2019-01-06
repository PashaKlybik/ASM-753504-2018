.model small
.stack 256
.data
    numberSystem dw 10
    errorStr db 'Error$'
    endLine db 13, 10, '$'
    outputBuffer db '      ', 13, 10,'$'
    divider db '/', 13, 10,'$'
    intMessage db 'Integer:', 13, 10,'$'
    remainderMessage db 'Remainder:', 13, 10,'$'
    errorStrZero db 'Number cant start from zero', 13, 10,'$'
    errorStrOverflow db 'Number is too large', 13, 10,'$'
    errorStrInvalidSymbol db 'Wrong Symbol', 13, 10,'$'
.code
cleanScreen PROC     ;Screen cleaning procedure 
    mov ax, 0600h
    mov bh, 07
    mov cx, 0000
    mov dx, 184Fh
    int 10h
  
    mov ax, 02h
    xor dx, dx  
    int 10h
cleanScreen ENDP

wordToStr PROC              ;Convert word to string
    push ax
    push bx
    push cx
    push dx
    push di
     
    xor cx, cx
    mov bx, 10
    remainder:               ;remainder cycle
        xor dx, dx
        div bx
        add dl,'0'
        push dx                 
        inc cx
        test ax, ax
        jnz remainder

    extraction:              ;extract from stack
        pop dx 
        mov [di], dl
        inc di
        loop extraction         
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret     
wordToStr ENDP

signWordToStr PROC
    push ax
     mov di, offset outputBuffer
    test ax, ax
    jns notSign 
    mov [di], '-'
    inc di
    neg ax
    notSign:
        call wordToStr
        pop ax
    ret
signWordToStr ENDP

printStr PROC
    push ax     
    mov ah,9                 
    int 21h  
    pop ax
    ret
printStr ENDP

clear PROC
    push cx
    mov cx, 7 
    following:            ;Clear Buff
        mov [di], ' '        
        inc di              
        loop following      
    pop cx
    ret     
clear ENDP

remove PROC        ;Delete symbol procedure
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
remove ENDP

wordEnter PROC                    ;Console Enter
  push bx
  push cx
  push dx
  push di
  push si
  
  xor bx, bx
  xor si, si
  
  jmp iterate  
zero:
    cmp bx, 0
    jnz continue
    mov dl, 8
    mov ah, 02h
    int 21h
    call remove
    jmp iterate
     
signDelete:
    cmp si, 0
     je positive
     mov si, 0
     jmp positive
  
iterate:
    xor di, di
    mov ah, 01h 
    int 21h                       
    cmp  al, 8                  ;is Backspace?
    je backspaceLogic
    cmp al, 13                  ;is Enter?
    je enterLogic 
    cmp al, 27                  ;is Escape?
    je escapeLogic
    cmp al, '-'
    je minus   
    sub al, '0'                 ;ASCII to number 
    cmp al, 9                   ;is decimal?
    ja exceptionInvalidSymbol 
    test al, al                 ;is zero? 
    je zero 
continue:
    xor ch, ch                  
    mov cl, al   
    mov ax, bx
    mul numberSystem
    cmp dx, 0
    jne exceptionOverflow
    add ax, cx
    jb  exceptionOverflow
    cmp si, 1
    je negative
    cmp ax, 32767
    jnbe exceptionOverflow 
back:
    mov bx, ax
    jmp iterate

enterLogic:
    test bx, bx
    je exceptionNull
    mov ax, bx
    cmp si, 1
    jne endWordEnter
    neg ax
    jmp endWordEnter

backspaceLogic:
    test bx, bx
    je signDelete
    positive:
    xchg bx, ax
    xor dx, dx
    div numberSystem
    xchg bx, ax
    call remove
    jmp iterate
     
escapeLogic:
    xor bx, bx
    xor si, si
    mov cx, 7
    cleaning:
    mov dl, 8
    mov ah, 02h
    int 21h
    call remove
    loop cleaning    
    cmp di, 1
    je InvalidSymbol              
    cmp di, 2
    je Overflow
    jmp iterate
     
minus:
    cmp bx, 0
    jne exceptionInvalidSymbol
    cmp si, 0
    jne exceptionInvalidSymbol
    mov si, 1
    jmp iterate

negative:
    cmp ax, 32768
    jnbe exceptionOverflow
    jmp back

exceptionInvalidSymbol:
    mov di, 1
    jmp escapeLogic
    InvalidSymbol:
    mov dx, offset errorStrInvalidSymbol
    call printStr
    jmp iterate
     
exceptionOverflow:
    mov di, 2
    jmp escapeLogic
    Overflow:
    mov dx, offset errorStrOverflow      
    call printStr
    jmp iterate
     
exceptionNull:     
    mov dx, offset errorStrZero
    call printStr
    jmp iterate
     
endWordEnter:
    pop si 
    pop di     
    pop dx
    pop cx
    pop bx
    ret
wordEnter ENDP     

exception PROC
    cmp bx, -1
    jnz notException
    lea dx, errorStr
    call printStr
    mov ax, 4c00h
    int 21h
ret
exception ENDP

main:
    mov ax, @data
    mov ds, ax
 
    call cleanScreen 
    call wordEnter              ;entering first number
    xchg ax, bx

    push dx
    lea dx, divider       ;print divider
    call printStr
    pop dx
     
    call wordEnter              ;entering second number
    xchg ax, bx
    
    cmp ax, -32768
    je exception
    notException:
  
    cmp ax, 0
    jl point1
    jmp point2
    point1:
    cwd
    point2:
    idiv bx 

    mov bx, dx
 
    lea dx, intMessage           
    call printStr
    call signWordToStr
    lea dx, outputBuffer
    call printStr

    lea di, outputBuffer
    call clear
     
    lea dx, remainderMessage
    call printStr
    mov ax, bx
    test ax, ax
    jns allGood
    neg ax
    allGood:
    lea di, outputBuffer    
    call wordToStr
    lea dx, outputBuffer
    call printStr 
     
    mov ax, 4c00h
    int 21h
end main
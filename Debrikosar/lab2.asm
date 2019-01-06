.model small
.stack 256
.data
    numberSystem dw 10
    errorStr db 'Error$'
    endLine db 13, 10, '$'
    outputBuffer db '     ', 13, 10,'$'
    divider db '/', 13, 10,'$'
    intMessage db 'the integer part:', 13, 10, '$'
    remainderMessage db 'Remainder:', 13, 10, '$'
    errorStrZero db 'Number cant start from zero', 13, 10, '$'
    errorStrOverflow db 'Number is too large',13, 10,'$'
    errorStrInvalidSymbol db 'Wrong Symbol',13, 10,'$'
.code
сleanScreen PROC             ;Screen cleaning procedure 
    mov ax, 0600h
    mov bh, 07
    mov cx, 0000
    mov dx, 184Fh
    int 10h
  
    mov ax, 02h
    xor dx, dx  
    int 10h
сleanScreen ENDP

wordToStr PROC              ;Convert word to string
    push ax
    push bx
    push cx
    push dx
    push di

    mov di, offset outputBuffer
    xor cx, cx
    remainder:               ;remainder cycle
        xor dx, dx
        div numberSystem
        add dl, '0'
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

printStr PROC
    push ax
    mov ah, 9                 
    int 21h  
    pop ax
    ret
printStr ENDP

clear PROC
    push cx
    mov cx, 6 
    following:            ;Clear Buff
        mov [di], ' '        
        inc di              
        loop following 
    pop cx
    ret
clear ENDP

remove PROC       ;Delete symbol procedure
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

wordEnter PROC                          ;Console Enter
    push bx
    push cx
    push dx
  
    xor bx, bx
  
    iterate:
        xor di, di 
        mov ah, 01h
        int 21h                      
        cmp  al, 8                      ;is Backspace?
        je backspaceLogic
        cmp al, 13                      ;is Enter?
        je enterLogic
        cmp al, 27                      ;is Escape?
        je escapeLogic
        sub al, '0'                     ;ASCII to number 
        cmp al, 9                       ;is decimal?
        ja exceptionInvalidSymbol 
        test al, al                     ;is zero? 
        je zero
    continue:
        xor cx, cx    
        mov cl, al   
        mov ax, bx
        mul numberSystem
        cmp dx, 0
        jnz exceptionOverflow
        add ax, cx
        jc  exceptionOverflow 
        mov bx, ax
        jmp iterate

    enterLogic:
        test bx, bx
        je exceptionNull
        mov ax, bx
        jmp endWordEnter
 
    backspaceLogic:
        xchg bx, ax
        xor dx, dx
        div numberSystem
        xchg bx, ax
        call remove
        jmp iterate
 
    escapeLogic:
        xor bx, bx
        mov cx, 6
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

    zero:
        cmp bx, 0
        jnz continue
        mov dl, 8
        mov ah, 02h
        int 21h
        call remove
        jmp iterate

    exceptionNull:
        mov dx, offset errorStrZero
        call printStr
        jmp iterate

    endWordEnter:
        pop dx
        pop cx
        pop bx
        ret
wordEnter ENDP

main:
    mov ax, @data
    mov ds, ax
 
    call сleanScreen
    call wordEnter              ;entering first number
    xchg ax, bx

    push dx
    mov dx, offset divider       ;print divider
    call printStr
    pop dx 

    call wordEnter              ;entering second number
    xchg ax, bx
    div bx
    mov bx, dx 
 
    mov dx, offset intMessage           
    call printStr
    call wordToStr
    mov dx, offset outputBuffer
    call printStr

    mov di, offset outputBuffer
    call clear

    mov dx, offset remainderMessage
    call printStr
    mov ax, bx
    call wordToStr
    mov dx, offset outputBuffer
    call printStr 
 
    mov ax, 4c00h
    int 21h
end main
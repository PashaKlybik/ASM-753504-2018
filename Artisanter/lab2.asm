.model small
.stack 256
.data
    inputErrorMes db 10, "Invalid input", 13, 10, '$'   
    divByZeroErrorMes db 10, "Division by zero is not allowed", 13, 10, '$'
.code

proc output
    push ax
    push bx
    push cx
    push dx
    
    xor cx, cx
    mov bx, 10

toChar:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx 
    test ax, ax
    jnz toChar
    
    mov ah, 02h
outChar:
    pop dx
    int 21h
    loop outChar
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp

proc input
    push dx
    push bx
    push cx
    
    mov bx, 10    ;Основание системы счисления
    mov ch, 1    ;Флаг начала строки
    xor dx, dx    ;Результат
    
getDigit:
    mov ah, 01h
    int 21h
    
    cmp al, 13
    je endOfLine
    
    cmp al, 8
    jne notBackspace
    test ch, ch
    jne getDigit
    push dx
    mov dl, ' '    ;Затираем предыдущий символ
    mov ah, 02h
    int 21h
    mov dl, 13
    int 21h
    pop ax
    xor dx, dx
    div bx
    call output
    mov dx, ax
    jmp getDigit
    
notBackspace:
    xor ch, ch
    cmp al, '0'
    jb inputError
    cmp al, '9'
    ja inputError
    sub al, '0'
    mov cl, al
    mov ax, dx 
    mul bx
    jc inputError
    mov dx, ax
    add dx, cx
    jc inputError
    jmp  getDigit  
    
endOfLine:  
    test ch, ch
    jne inputError    ;DH=1, пустая строка
    clc    ;CF=0    
    mov ax, dx
    jmp endInput
    
inputError:
    stc    ;CF=1
    
endInput:
    pop cx
    pop bx
    pop dx
    ret
endp

main:
    mov ax, @data
    mov ds, ax
retry:
    mov dl, 10
    mov ah, 02h
    int 21h
    call input  
    jc invalidInputError
    mov cx, ax
    mov ah, 02h
    mov dl, '/'
    int 21h
    
    call input
    jc invalidInputError
    test ax, ax
    je divByZeroError    
    mov bx, ax    
    
    mov dl, '='
    mov ah, 02h
    int 21h
    mov ax, cx
    xor dx, dx
    div bx
    call output
    
    mov ah, 02h
    mov dl, 10
    int 21h
    jmp endAll
    
divByZeroError:
    mov dx, offset divByZeroErrorMes
    mov ah, 09h
    int 21h
    jmp retry
    
invalidInputError:
    mov dx, offset inputErrorMes
    mov ah, 09h
    int 21h
    jmp retry
    
endAll:
    mov ax, 4c00h
    int 21h
end main
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

    test ax,ax
    jns toChar
    neg ax
    mov ch, 1
    
toChar:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cl 
    test ax, ax
    jnz toChar
    
    mov ah, 02h   
    test ch,ch
    jz outChar
    mov dl, '-' 
    int 21h
    xor ch,ch
    
outChar:
    pop dx
    int 21h
    loop outChar
    
    mov dl, 10
    int 21h
    
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
    
    mov ah, 01h
    int 21h
    cmp al, '-'
    jne pass
    or ch, 2
    
getDigit:
    mov ah, 01h
    int 21h
pass:
    cmp al, 13
    je endOfLine
    
    and ch, 2
    cmp al, '0'
    jb inputError
    cmp al, '9'
    ja inputError
    sub al, '0'
    mov cl, al
    mov ax, dx 
    mul bx
    jc inputError
    js inputError
    mov dl, cl
    add dx, ax
    js maxCheck
    jmp  getDigit  
    
maxCheck:
    neg  dx
    js inputError
    test  ch, 2
    jz inputError
    mov ah, 01h
    int 21h
    cmp al, 13
    jne inputError
    mov ax, dx
    jmp noError
    
endOfLine:  
    test ch, 1
    jnz inputError    ;пустая строка    
    mov ax, dx
    test ch, 2
    jz noError
    neg ax
    jno noError

inputError:
    stc    ;CF=1 
    jmp endInput     
noError:
    clc    ;CF=0  
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
    mov dl, '/'
    mov ah, 02h
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
    test ax,ax
    jns positive
    sub dx, 1
    cmp bx, -1
    jne positive
    neg ax
    js invalidInputError
    call output
    jmp endAll 
positive:
    idiv bx
    ;jc invalidInputError
    call output
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
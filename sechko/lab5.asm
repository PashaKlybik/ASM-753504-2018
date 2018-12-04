.model small
.stack 256
.data
    inFile db "element.txt", 0
    inArray1 dw 10*10 dup (?)
    inArray2 dw 10*10 dup (?)
    finArray dw 10*10 dup (?)
    buffer db ?
    finiteFile db "finite.txt", 0
    stock dw ?
    rows dw ?
    columns dw ?
.code

proc writeChar      ;символ в текст
    push ax 
    push bx
    push cx
    
    mov cx, 1
    mov bx, stock
    mov buffer, dl
    lea dx, buffer
    mov ah, 40h
    int 21h

    pop cx
    pop bx
    pop ax
    ret
endp
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
       
    test ch,ch
    jz outChar
    mov dl, '-' 
    call writeChar
    xor ch,ch
    
outChar:
    pop dx
    call writeChar
    loop outChar
    
    mov dl, 9
    call writeChar
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp

proc readChar     ; считывает символ
    push ax
    push bx
    push cx
    
    mov cx, 1
    mov bx, stock
    lea dx, buffer
    mov ah, 3fh
    int 21h
    jc last
    xor dx, dx
    mov dl, [buffer]
    cmp dl, '0'
    jb last
    cmp dl, '9'
    jnb last
    test ax, ax
    jz last
    clc
    jmp notLast
last:
    stc
notLast:
    pop cx
    pop bx
    pop ax
    ret
endp

proc input ; строка-число
    push dx
    push bx
    push cx
    
    mov bx, 10    ; Основание системы счисления
    xor ch, ch    ; Флаг знака
    xor ax, ax    ; Результат
    
    call readChar
    cmp dl, '-'
    jne pass
    inc ch
    
getDigit:
    call readChar
pass:
    jc endOfLine
    sub dl, '0'
    mov cl, dl
    mul bx
    mov dl, cl
    add ax, dx
    jmp  getDigit  
    
endOfLine:     
    test ch, ch
    jz endInput
    neg ax
endInput:
    pop cx
    pop bx
    pop dx
    ret
endp

proc readArray    ; читает массив
    push ax    
    push dx
    push cx
    
    mov di, dx
    call input
    mov rows, ax
    mov cx, ax
    call input
    mov columns, ax
    mov bx, ax
    call readChar
    
toArray:
    call input
    mov [di], ax
    add di, 2
    dec bx
    test bx, bx
    jnz toArray
    mov bx, columns
    call input
    loop toArray
    
    pop cx
    pop dx
    pop ax
    ret
endp

proc compare       ; расчеты 
    push ax
    push bx
    push dx
    push cx
    
    mov bx, dx
    mov ax, columns
    mul rows
    mov cx, ax

    lea di, inArray1
    lea si, inArray2

toOutArray:   
    mov ax, [di]
    mul word ptr[si]    
    mov word ptr[bx], ax

    add bx, 2
    add si, 2
    add di, 2
    loop toOutArray
    
    pop cx
    pop dx
    pop bx
    pop ax
    ret
endp

proc writeArray    ; запись массива
    push ax
    push dx
    push cx
    
    mov di, dx
    mov cx, rows
    mov bx, columns
    
fromArray:
    mov ax, [di]
    call output 
    add di, 2
    dec bx
    test bx, bx
    jnz fromArray
    mov bx, columns
    mov dl, 10
    call writeChar
    loop fromArray
    
    pop cx
    pop dx
    pop ax
    ret
endp

proc openFile
    push ax
    
    mov al, 2
    mov ah, 3dh
    int 21h
    jc fileError
    mov stock, ax
    
    pop ax
    ret
endp

proc closeFile
    push ax
    push bx
    
    mov bx, stock
    mov ah, 3eh
    int 21h
    jc fileError
    
    pop bx
    pop ax
    ret
endp

main:
    mov ax, @data
    mov ds, ax
    
    lea dx, inFile
    call openFile
    
    lea dx, inArray1
    call readArray
    lea dx, inArray2
    call readArray
    call closeFile
    
    lea dx, finArray
    call compare
    lea dx, finiteFile
    call openFile
    lea dx, finArray
    call writeArray
    call closeFile
    
fileError:
endAll:
    mov ax, 4c00h
    int 21h
end main
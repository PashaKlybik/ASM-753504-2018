.model small
.stack 256
.data
    inFile db "input.txt", 0
    outFile db "output.txt", 0
    inArray1 dw 10*10 dup (?)
    inArray2 dw 10*10 dup (?)
    finArray dw 10*10 dup (?)
    buffer db ?
    row dw ?
    column dw ?
    stock dw ?
.code

proc Out         ; çàïèñü ÷èñëà â ôàéë
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

proc writeChar    ; ñèìâîë â òåêñò 
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


proc readChar     ; ñ÷èòûâàåò ñèìâîë èç ôàéëà
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

proc In           ; ñòðîêà=÷èñëî 
    push dx
    push bx
    push cx
    
    mov bx, 10    ; Îñíîâàíèå ñèñòåìû ñ÷èñëåíèÿ
    xor ch, ch    ; Ôëàã çíàêà
    xor ax, ax    ; Ðåçóëüòàò
    
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
    jz endIn
    neg ax
endIn:
    pop cx
    pop bx
    pop dx
    ret
endp

proc readArray     ; ÷èòàåò ìàññèâ
    push ax
    push dx
    push cx
    
    mov di, dx
    call In
    mov row, ax
    mov cx, ax
    call In
    mov column, ax
    mov bx, ax
    call readChar
    
toArray:
    call In
    mov [di], ax
    add di, 2
    dec bx
    test bx, bx
    jnz toArray
    mov bx, column
    call In
    loop toArray
    
    pop cx
    pop dx
    pop ax
    ret
endp

proc compare        ; ðàñ÷åò
    push ax
    push bx
    push dx
    push cx
    
    mov bx, dx
    mov ax, column
    mul row
    mov cx, ax
    
    lea di, inArray1
    lea si, inArray2

tofinArray:   
    mov ax, [di]
    cmp ax, word ptr[si]
    jg aIsBigger
    mov ax, [si]
aIsBigger:
    mov word ptr[bx], ax

    add bx, 2
    add si, 2
    add di, 2
    loop tofinArray
    
    pop cx
    pop dx
    pop bx
    pop ax
    ret
endp

proc writeArray      ; çàïèñü ìàññèâà
    push ax
    push dx
    push cx
    
    mov di, dx
    mov cx, row
    mov bx, column
    
fromArray:
    mov ax, [di]
    call Out 
    add di, 2
    dec bx
    test bx, bx
    jnz fromArray
    mov bx, column
    mov dl, 10
    call writeChar
    loop fromArray
    
    pop cx
    pop dx
    pop ax
    ret
endp

proc openFile       ; îòêðûòèå ôàéëà 
    push ax
    
    mov al, 2
    mov ah, 3dh
    int 21h
    jc fileError
    mov stock, ax
    
    pop ax
    ret
endp

proc closeFile      ; çàêðûòèå ôàéëà
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
    lea dx, outFile
    call openFile
    lea dx, finArray
    call writeArray
    call closeFile
    
fileError:
endAll:
    mov ax, 4c00h
    int 21h
end main

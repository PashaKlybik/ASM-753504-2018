model small
stack 256
dataseg
    messageBadInput db 10, 13, "Try again", 10, 13, '$'
    messageColumns db "Enter the number of columns: ", 10, 13, '$'
    messageRows db "Enter the number of rows: ", 10, 13, '$'
    messageWriteRows db "Enter rows: ", 10, 13, '$'
    array dw 6555 dup(?)
    ten dw 10
    Rows dw ?
    Columns dw ?
    Pos dw ?
    Max dw -5000
    MaxPos dw ?
    Min dw 5000
    MinPos dw ?
codeseg

;-----MESSAGE OUTPUT-----
MessageOutput proc
    push ax
        mov ah, 09h
        int 21h
    pop ax
    ret
MessageOutput endp

;-----READ INTEGER-----
ReadInteger proc ;Input of
    push bx
    push cx
    push si
    Start1:
    xor si, si
    mov cx, 0
        mov ah, 01h             
        int 21h
        cmp al, '-'
        jne IsPositive
        inc si
    ReadLoop:
        mov ah, 01h             
        int 21h
        IsPositive:
        cmp al, 13
        je Finish
        cmp al, ' '
        je Finish
        cmp al, '0'
        jl IntegerInputError
        cmp al, '9'
        jg IntegerInputError
        xor ah, ah
        sub ax, '0'
        mov cx, ax
        mov ax, bx
        mul ten
        cmp si, 0
        jne IsNegative
            add ax, cx
            mov bx, ax
            cmp ax, 0
            jl IntegerInputError
        jmp ReadLoop
        IsNegative:
            sub ax, cx
            mov bx, ax
            cmp ax, 0
            jg IntegerInputError
        jmp ReadLoop
    Finish:
    mov ax, bx
    pop si
    pop cx
    pop bx
    ret
    IntegerInputError:
        lea dx, messageBadInput
        mov ah, 09h
        int 21h 
        jmp Start1
ReadInteger endp

;-----NEW LINE-----
NewLine proc
    push ax
    push dx
        mov dx, 10
        mov ah, 2   
        int 21h 
        mov dx, 13
        mov ah, 2   
        int 21h 
    pop dx
    pop ax
    ret
NewLine endp

;-----SPACE-----
Space proc
    push ax
    push dx
        mov dx, ' '
        mov ah, 2   
        int 21h 
    pop dx
    pop ax
    ret
Space endp

;-----TWO DEMENSION ARRAY READ-----
TwoDemensionArrayRead proc
    push si
    push di
    push cx
    xor di, di
    xor cx, cx
    FirstLoop1:
        xor si, si
        SecondLoop1:
            push di
            add di, si
            push ax
            mov ax, 2
            mul di
            mov di, ax
            pop ax
            call ReadInteger
            mov array[di], ax
            pop di
            inc si
            cmp si, Columns
        jne SecondLoop1
        add di, Columns
        call NewLine
        inc cx
        cmp cx, Rows 
    jne FirstLoop1   
    pop cx
    pop di
    pop si
    ret
TwoDemensionArrayRead endp

;-----TWO DEMENSION ARRAY PRINT-----
TwoDemensionArrayPrint proc
    push si
    push di
    push cx
    xor di, di
    xor cx, cx
    FirstLoop2:
        xor si, si
        SecondLoop2:
            push di
            add di, si
            push ax
            mov ax, 2
            mul di
            mov di, ax
            pop ax
            mov ax, array[di]
            pop di
            call PrintInteger
            call Space
            inc si
            cmp si, Columns
        jne SecondLoop2
        add di, Columns
        call NewLine
        inc cx
        cmp cx, Rows 
    jne FirstLoop2   
    pop cx
    pop di
    pop si
    ret
TwoDemensionArrayPrint endp

;-----PRINT INTEGER-----
PrintInteger proc
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
    cmp ax, 0
    jge DivideAndPush
        push ax
        mov dx, '-'
        mov ah, 2   
        int 21h
        pop ax
        neg ax
    DivideAndPush:
        xor dx, dx
        div bx
        push dx
        inc cx
        test ax, ax
        jnz DivideAndPush
    PopAndPrint:
        pop ax
        add ax, '0'
        mov dx, ax
        mov ah, 2
        int 21h
    loop PopAndPrint
    pop dx
    pop cx
    pop bx
    ret
PrintInteger endp

;-----SUBTRACT MIN FROM MAX-----
SubtractMinFromMax proc ;Searches for max & min, subtracts min from max
    push si
    push di
    push cx
    push dx
    xor di, di
    xor cx, cx
    FirstLoop3:
        xor si, si
        SecondLoop3:
            push di
            add di, si
            push ax
            mov ax, 2
            mul di
            mov di, ax
            pop ax
            mov ax, array[di]
            mov Pos, di
            pop di            
            ;Check whether number is lower or higher than the side diagonal of the matrix
            mov dx, Columns
            sub dx, cx
            cmp dx, si
            ja IsGreaterOrOn
            IsLower:
            ;if lower - comare with min
                cmp ax, Min
                jg Continue
                mov Min, ax
                push Pos
                pop MinPos
                jmp Continue
            IsGreaterOrOn:
            ;if higher, compare with max
                cmp ax, Max
                jl Continue
                mov Max, ax
                push Pos
                pop MaxPos
            Continue:
            inc si
            cmp si, Columns
        jne SecondLoop3
        add di, Columns
        call NewLine
        inc cx
        cmp cx, Rows 
    jne FirstLoop3
    ;subtract min from max
    push ax
        mov di, MinPos
        mov cx, array[di]
        mov di, MaxPos
        mov ax, array[di]
        sub ax, cx
        mov array[di], ax
    pop ax
    pop dx
    pop cx
    pop di
    pop si
    ret
SubtractMinFromMax endp

;-----MAIN-----
main:
    mov ax, @data
    mov ds, ax
    mov es, ax
    lea dx, messageColumns
    call MessageOutput
    call ReadInteger
    mov Columns, ax
    lea dx, messageRows
    call MessageOutput
    call ReadInteger
    mov Rows, ax
    lea dx, messageWriteRows
    call MessageOutput
    call TwoDemensionArrayRead
    call SubtractMinFromMax
    call TwoDemensionArrayPrint
    mov ah, 4ch
    int 21h
end main

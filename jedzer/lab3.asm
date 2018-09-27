model small
stack 256
dataseg
    errorNotDigit db  13, 10, 'Entered symbol is not in [0, 9] or number is not in [-32768..32767]', 13, 10, '$'
    a dw ?
    b dw ?
    ten dw 10
codeseg

;number input porcedure. Reads number from console and saves it in AX
;saves bx, cx, si 
EnterInt proc
    push bx
    push cx
    push si
    xor si, si
    mov cx, 0
        mov ah, 01h             
        int 21h
        cmp al, '-'
        jne positiveCheck
        inc si
    ReadLoop:
        mov ah, 01h             
        int 21h
        positiveCheck:
        cmp al, 13
        je finish
        cmp al, '0'
        jl intErr
        cmp al, '9'
        jg intErr
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
            jl intErr
        jmp ReadLoop
        IsNegative:
            sub ax, cx
            mov bx, ax
            cmp ax, 0
            jg intErr
        jmp ReadLoop
finish:
    mov ax, bx
    pop si
    pop cx
    pop bx
    ret
EnterInt endp

;finishes programm if an input error occured  
intErr:
    lea dx, errorNotDigit
    mov ah, 09h
    int 21h
    mov ax, 4c00h
    int 21h

;number output porcedure. Gets number from ax and outputs it in console
;saves bx, cx, dx 
OutInt proc
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
    cmp ax, 0
    jg SplitAndPush
    je SplitAndPush 
        push ax
        mov dx, '-'
        mov ah, 2   
        int 21h
        pop ax
        neg ax
    SplitAndPush:
        xor dx, dx
        div bx
        push dx
        inc cx
        test ax, ax
        jnz SplitAndPush
    PopAndDisplay:
        pop ax
        add ax, '0'
        mov dx, ax
        mov ah, 2
        int 21h
    loop PopAndDisplay
    pop dx
    pop cx
    pop bx
    ret
OutInt endp

;procedure used to display new line symbol
;saves ax and dx
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

main:
    mov ax, @data
    mov ds, ax  
    call EnterInt 
    mov a, ax
    call OutInt
    call NewLine

    call EnterInt 
    mov b, ax
    call OutInt
    call NewLine

    xor dx, dx
    mov ax, a
    cwd
    idiv b
    call OutInt
    call NewLine
    
    mov ax, 4c00h
    int 21h
end main
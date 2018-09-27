model small
stack 256
dataseg
    errorNotDigit db  13, 10, 'Entered symbol is not in [0, 9] and greater than 65535', 13, 10, '$'
    a dw ?
    b dw ?
    ten dw 10
codeseg

;number input porcedure. Reads number from console and saves it in AX
;saves bx, cx, dx, si 
EnterInt proc
    push bx
    push cx
    push dx
    push si
    mov cx, 0
    mov si, 0
     readInt:
        mov ah, 01h             
        int 21h
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
        add ax, cx
        mov bx, ax
        jc intErr
        jmp readInt
finish:
    mov ax, bx
    pop si
    pop dx
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

;number input porcedure. Gets number from ax and outputs it in console
;saves bx, cx, dx 
OutInt proc
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
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
    div b

    call OutInt
    call NewLine

    mov ax, 4c00h
    int 21h
end main
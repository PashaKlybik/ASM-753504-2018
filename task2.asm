model small
stack 256
dataseg
    integer db 8 dup(?)
    errorNotDigit db  13, 10, 'Entered symbol is not in [0, 9] and greater than 65535', 13, 10, '$'
    toAxThing dw 6 dup(?)
    a dw ?
    b dw ?
    ten dw 10
codeseg

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

intErr:
    lea dx, errorNotDigit
    mov ah, 09h
    int 21h
    mov ax, 4c00h
    int 21h

OutInt proc
    push bx
    push cx
    push dx
    push si
    xor bx, bx
    xor dx, dx
    xor cx, cx
    mov bx, 10
    notDone:
        xor dx, dx
        div bx
        push dx
        inc cx
        test ax, ax
        jnz notDone
    finish2:
        mov si, 0
        lopyLoop:
            pop ax
            add ax, '0'
            mov integer[si], al 
            inc si
        loop lopyLoop
        mov integer[si], 13
        inc si
        mov integer[si], 10
        inc si
        mov integer[si], '$'
    lea dx, integer
    mov ah, 09h
    int 21h
    pop si
    pop dx
    pop cx
    pop bx
    ret
OutInt endp

main:
    mov ax, @data
    mov ds, ax  
    call EnterInt 
    mov a, ax
    call OutInt
    call EnterInt 
    mov b, ax
    call OutInt
    xor dx, dx
    mov ax, a
    div b
    call OutInt
    mov ax, 4c00h
    int 21h
end main
model small
.stack 100h

.data
    a dw 13
    b dw 21
    c dw 45
    d dw 17
.code


start:
    mov ax, @data
    mov ds, ax
    
    mov ax, a  
    mov bx, b
    mov cx, c
    mov dx, d

    and bx, ax
    mov ax, c
    mul c
    mul c
    mul c
    cmp ax, bx
        ;if (a AND b = c ^ 4) is false
        jne Else1
        ;if it is true we do: (ax = с / d / b + a) and jump to the end
        mov ax, c
        div d
        div b
        add ax, a
        jmp return


    Else1:
        mov cx, c
        add cx, b

        mov ax, a
        mul a
        mul a
        mov bx, ax
        mov ax, b
        mul b
        mul b

        add ax, bx
        cmp ax, cx

            ;if (c + b = a ^ 3 + b ^ 3) is false
            jne Else2

            ;if it is true we do: (AX = a XOR (b + c)) and jump to the end
            mov ax, a
            mov bx, b
            add bx, c
            xor ax, bx
            jmp return

        Else2:
            ;here we do: (AX = b >> 3)
            mov bx, b
            shr bx, 3
            mov ax, bx



return:
    mov ah, 4ch
    int 21h
end start

;2) Если a AND b = c ^ 4 то
;        Результат = с / d / b + a
;     Иначе
;        Если c + b = a ^ 3 + b ^ 3 то
;           Результат = a XOR (b + c)
;        Иначе
;           Результат = b >> 3 (сдвинуть с три раза вправо)
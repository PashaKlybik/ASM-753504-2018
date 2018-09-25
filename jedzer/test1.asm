;.386
model small
.stack 100h

.data
    a dw 13
    b dw 21
    c dw 45
    d dw 17
.code
;20 

start:
    mov ax, @data
    mov ds, ax

    xor ax, ax
    
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
        jne NotEqual1
        
        mov ax, c
        div d
        div b
        add ax, a
        jmp all


    NotEqual1:
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

            jne NotEqual2

            mov ax, a
            mov bx, b
            add bx, c
            xor ax, bx
            jmp all

        NotEqual2:
            mov bx, b
            shr bx, 3
            mov ax, bx



all:
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
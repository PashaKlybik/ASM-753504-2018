; 1 вариант
.model small
.stack 256
.data
    a dw 12
    b dw 2
    c dw 3
    d dw 2
.code



main:
    mov ax, @data
    mov ds, ax
    
    mov ax, a ; возведение а в куб
    mul a
    mul a
    mov bx, ax

    mov ax, b
    mul b

    cmp ax, bx
    jbe greater ; если больше операнд в bx
    
     mov ax, c
     mul d
     adc ax, b
     jmp exit

    greater:
        mov ax, c
        mul d
        xor dx, dx
        mov bx, ax
        mov ax, a
        div b
        cmp bx, ax
        jz equal
        mov ax, c
        jmp exit
        equal:
            mov ax, a
            and ax, b 
            
   exit:
    mov ax, 4c00h
    int 21h
end main
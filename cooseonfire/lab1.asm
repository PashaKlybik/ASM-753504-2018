; 1 вариант
.model small
.stack 256
.data
    a dw 3
    b dw 13
    c dw 14
    d dw 17
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

    cmp bx, ax
    jz then ; в условии строгое неравенство
    jnc greater ; если больше
    
    then:
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
        jmp next
        equal:
            mov ax, a
            and ax, b 
            jmp exit
        next:
            mov ax, с
            
   exit:
    mov ax, 4c00h
    int 21h
end main

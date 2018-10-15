model small
.stack 100h
.code

start:
		a dw 2
		b dw 1
		c dw 4
		d dw 6
cmp1:
        mov ax, a ;a ^ 2 = b * c
        mov bx, a
        mul bx

        mov cx, ax

        mov ax, b
        mov bx, c
        mul bx

        cmp cx,ax
        jg cmp2
        jmp res3

cmp2:
        mov ax,c ;c * b = d / b
        mov bx,b
        mul bx

        mov cx, ax

        mov ax,d
        xor dx,dx
        mov bx,b
        div bx

        cmp cx, ax
        je res1
        jmp res2

res1:
        mov ax, a ;a OR b
        mov bx, b
        or ax, bx
   
        jmp finish

res2:
        mov ax, c   ;c

        jmp finish

res3:
        mov ax, c  ; c*a-b
        mov bx, a
        mul bx

        mov bx,b
        sub ax, bx

        jmp finish

finish:
    mov ax, 4c00h    
    int 21h
end start
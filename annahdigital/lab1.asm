.model small
.stack 256
.data
a dw 10
b dw 12
c dw 13
d dw 0
.code

main:
;var. 1
mov ax, @data
mov ds, ax

;a^3
mov ax, a 
mul ax
mul a
mov bx, ax

;b^2
mov ax, b
mul ax

;сравнение a^3 с b^2
cmp bx, ax
JA acubedisbigger
JNA acubedissmaller

;если а^3 > b^2
acubedisbigger:
mov ax, c
mul d
mov bx, ax
mov ax, a
mov dx, 5
div b
cmp bx, ax
JZ equal
mov ax,c
JMP next
equal:
mov ax, a
and ax, b
JMP next


; если а^3 <= b^2
acubedissmaller:
mov ax, c
mul d
add ax, b

next:

mov ax, 4c00h
int 21h

end main
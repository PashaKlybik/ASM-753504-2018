.model small
.stack 256
.data
a dw 2
b dw 3
c dw 4
d dw 5
.code
main:
mov ax, @data 
mov ds, ax 
mov es, ax 
mov ax,a
mov si,a
mov bx,b
cmp ax,bx
ja L2
mov ax,bx
jmp next1
L2:cmp si,bx
ja P0
mov si,si
jmp net
P0:mov si,bx
next1:
mov cx,c
cmp ax,cx
ja L3
mov ax,cx
L3: mov ax,ax
cmp cx,si
ja P1
mov si,cx
jmp next2
P1:mov si,si
next2:
mov dx,d
cmp ax,dx
ja L4
mov ax,dx
jmp next3
L4: mov ax,ax
cmp si,dx
ja N
mov si,si
jmp next4
N: mov si,dx
next4:
next3:
sub ax,si
mov ax,4c00h 
int 21h
end main


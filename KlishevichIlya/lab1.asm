.model small
.stack 256
.data
a dw 1
b dw 6
c dw 4
d dw 5
.code
main:
    mov ax, @data 
    mov ds, ax 
       
    mov ax,a
    mov si,b
    mov bx,b
    cmp ax,bx
    ja goToC
    mov si, ax
    mov ax,bx
    
goToC:
    mov cx,c
    cmp ax,cx
    ja ifKicker
    mov ax,cx
ifKicker: 
    cmp cx,si
    ja goToD
    mov si,cx
    
goToD:
    mov dx,d
    cmp ax,dx
    ja ifAMax
    mov ax,dx
    jmp goToSplit
ifAMax: 
    cmp si,dx
    jna goToSplit
    mov si,dx
       
goToSplit:
    sub ax,si
    
    mov ax,4c00h 
    int 21h
 end main


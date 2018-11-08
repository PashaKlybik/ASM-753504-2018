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
        
    mov ax,a
    mov si,a
    mov bx,b
    cmp ax,bx
    ja ifAKicker
    mov ax,bx
    jmp goToC
    ifAKicker:cmp si,bx
    ja compareMin
    mov si,si
    compareMin:mov si,bx
    
    goToC:
    mov cx,c
    cmp ax,cx
    ja ifKicker
    mov ax,cx
    ifKicker: mov ax,ax
    cmp cx,si
    ja ifMinRest
    mov si,cx
    jmp goToD
    ifMinRest:mov si,si
    
    goToD:
    mov dx,d
    cmp ax,dx
    ja ifAMax
    mov ax,dx
    jmp goToSplit
    ifAMax: mov ax,ax
    cmp si,dx
    ja ifDxMin
    mov si,si
    jmp split
    ifDxMin: mov si,dx
    
    split:
    goToSplit:
    sub ax,si
    
    mov ax,4c00h 
    int 21h
 end main


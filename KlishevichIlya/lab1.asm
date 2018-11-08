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
    ifAKicker:
    cmp si,bx
    ja compareMin
    compareMin:
    mov si,bx
    
    goToC:
    mov cx,c
    cmp ax,cx
    ja ifKicker
    mov ax,cx
    ifKicker: 
    cmp cx,si
    ja ifMinRest
    mov si,cx
    jmp goToD
    ifMinRest:
        
    goToD:
    mov dx,d
    cmp ax,dx
    ja ifAMax
    mov ax,dx
    jmp goToSplit
    ifAMax: 
    cmp si,dx
    ja ifDxMin
    ifDxMin:
    mov si,dx
    
    goToSplit:
    sub ax,si
    
    mov ax,4c00h 
    int 21h
 end main


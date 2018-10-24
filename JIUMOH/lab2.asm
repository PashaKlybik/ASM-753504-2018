model small
.STACK 100h
.DATA
    a dw -7765
.CODE
START:
    mov ax, @data
    mov ds, ax

    mov ax, a
    call output
    
    JMP EndProgramm

    
output proc
    push cx
    push dx
    push bx
    push ax

    mov bx, 10
    xor cx,cx 
    
    test ax, ax

    for1:
    xor dx, dx 
    div bx

    push dx 
    inc cx  
    test ax,ax  
    jnz for1
    mov ah, 02h 

    for2:
    pop dx  
    add dl, 30h 
    int 21h
    loop for2

    pop ax  
    pop bx
    pop dx
    pop cx
    ret

output endp

EndProgramm :
    mov ax,4c00h
    int 21h

END START
;Variant 8

.model small
.stack 256
.data
    a dw 8
    b dw 4
    c dw 12
    d dw 3  
.code

main:
    mov ax, @data
    mov ds, ax
    
    mov ax,a   ;max
   
    cmp b,ax
    JC skip1
    mov ax,b
    skip1:    
    
    cmp c,ax
    JC skip2
    mov ax,c
    skip2:
    
    cmp d,ax
    JC skip3
    mov ax,d
    skip3:
    
    mov bx,a   ;min
    
    cmp bx,b
    JC skip4
    mov bx,b
    skip4:    
    
    cmp bx,c
    JC skip5
    mov bx,c
    skip5:
    
    cmp bx,d
    JC skip6
    mov bx,d
    skip6:
       
    sub ax,bx
    
    mov ax, 4c00h
    int 21h
end main
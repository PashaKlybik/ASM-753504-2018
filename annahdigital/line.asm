.model small
.stack 256
.data
lineForTrying db "A smell of petroleum prevails throughout." ,10,13, "$"
.code

main:
mov ax, @data
mov ds, ax

    mov dx,offset lineForTrying
    mov ah,09h
    int 21h 
    
mov ax, 4c00h
int 21h

end main
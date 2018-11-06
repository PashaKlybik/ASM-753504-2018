.model small
.stack 256
.data
    a dw 26
    b dw 25
    c dw 3
    d dw 7
.code
main:
    mov ax, @data
    mov ds, ax
    mov ax,a
    dec ax
    and ax,a
    cmp ax,b    
    jc firstBranch

    mov ax,c
    add ax,b
    cmp d,ax
    jc secondBranch
 
    mov ax,c
    div d
    add ax,dx
    jmp endBranch

    secondBranch:
    mov ax,c
    XOR ax,d
    jmp endBranch

    firstBranch:
    mov bx,b
    inc bx
    mov ax,b
    OR ax,bx
	    
    endBranch:
    mov ax,4c00h
    int 21h
end main

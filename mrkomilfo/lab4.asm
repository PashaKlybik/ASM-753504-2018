;variant 7
.model small
.stack 256
.data
    n dw 4
    buffer db 255 DUP (0)
.code

;OUT: al - size, bx - adress
input proc    
    mov ah, 0Ah
    mov byte [buffer],253
    mov dx, offset buffer + 1
    int 21h
    mov bx, dx
    add bx, 2
    mov al, [buffer+2]
    ret
input endp

main:
    mov ax, @data
    mov ds, ax    

    call input
    
    add bl, al
    mov cl, al
    xor si, si
    
    looper:
    dec bx
    mov dl, byte[bx-1]
    push dx       
    xor di, di
    mov ah, [bx]
    cmp ah, ' '
    jne notSpace
    cmp si, n
    jge saveWord
    inc si
    sub ax, si
    mov dx, cx
    mov cx, si
    popWord:
    pop di
    loop popWord
    mov cx, dx
    saveWord:
    xor si, si
    loop looper
    notSpace:      
    inc si
    loop looper
    
    cmp si, n
    jge saveFirstWord
    inc si
    mov dx, cx
    mov cx, si
    sub ax, si

    popFirstWord:
    pop di
    loop popFirstWord
    mov cx,dx
    saveFirstWord:
    
    ;new row
    push ax
    mov dl, 10
    mov ah, 02h
    int 21h
    pop ax
        
    cmp al,0
    jle exit 
    
    ;printing
    mov cl, al  
    loop2:
    pop dx
    mov ah, 02h
    int 21h
    loop loop2
    
    exit:    
    mov ax, 4c00h
    int 21h
end main

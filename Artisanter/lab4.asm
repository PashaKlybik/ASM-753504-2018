;v:6
;Удалить из строки все повторяющиеся символы 
;(Оставить только первый символ из повторяющихся).
.model small
.stack 256
.data
    string db "aajd ad dfffd 4ofkLLpaec",10,13,'$'
.code

proc process
    push cx
    push bx
    push ax
    
    xor bx, bx
    mov si, dx
    mov di, dx
forChar:
    mov al, [si]
    mov cx, bx
    repne scasb
    je found
    mov di, dx
    add di, bx
    mov [di], al
    inc bx  
found:
    inc si  
    cmp byte ptr [si], '$'
    je endProcess   
    mov di, dx
    jmp forChar
    
endProcess: 
    mov [di], '$'   
    pop ax
    pop bx
    pop cx
    ret
endp

main:
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    lea dx, string
    mov ah, 09h
    int 21h     
    call process
    int 21h
    
    mov ax, 4c00h
    int 21h
end main
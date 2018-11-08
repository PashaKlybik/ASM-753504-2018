;v:6
;Удалить из строки все повторяющиеся символы 
;(Оставить только первый символ из повторяющихся).
.model small
.stack 256
.data
    string db 250, 250 dup('$')
.code

proc process
    push cx
    push bx
    push ax
    
    xor bx, bx
    mov si, dx
    mov di, dx
forChar:
    mov al, [si]    ;Символ для сравнения
    mov cx, bx    ;Счетчик
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
    mov byte ptr [di], '$'   
    pop ax
    pop bx
    pop cx
    ret
endp

proc newLine
    push ax
    push dx

    mov ah, 02h
    mov dl, 10
    int 21h
    
    pop dx
    pop ax
    ret
endp

main:
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    lea di, string    
    mov dx, di
    mov ah, 0ah
    int 21h
    call newLine
    inc dx
    call process
    mov ah, 09h   
    int 21h
    call newLine
    
    mov ax, 4c00h
    int 21h
end main
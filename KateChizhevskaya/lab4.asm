.model small; вариант 4, найти и показать самое длинное слово
.stack 256
.data
    length_max  db 100
    length_real db ?
    first_position dw ?
    last_position dw ?
    result db ?
    char db ?
    word_max db 100 dup('$'),'$'
    word_max_length dw 0
    string db 100 dup ('$')
    new_line db 13, 10, '$'
.code

output proc
    push ax
    push dx
    mov dx,offset word_max
    mov ah,9
    int 21h
    pop dx
    pop ax
    ret
endp

input proc 
    push ax
    push dx
    push bx
    lea bx,length_max
    mov ah,0ah
    lea dx,string
    int 21h
    mov ah, 9
    mov dx, offset new_line
    int 21h 
    pop bx
    pop dx
    pop ax
    ret
input endp

check proc
    push di
    push bx
    push ax
    dec di
    mov last_position, di
    mov ax,last_position
    mov bx, first_position
    sub ax,bx
    cmp ax, word_max_length
    JLE end_check
    call change
    end_check:
    pop ax
    pop bx
    pop di
    ret
check endp

change proc
    push cx
    push di
    push ax
    push dx
    push si
    mov cx,last_position
    sub cx,first_position
    mov word_max_length,cx
    mov si,di
    sub si, cx
    inc cx
    cld
    lea di, word_max
    cld
    cycle1:
        lodsb
		stosb
		xor al,al
    loop cycle1
    pop si
    pop dx
    pop ax
    pop di
    pop cx
    ret
change endp

main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    call input
    xor ax,ax
    lea di, string
    inc di
    mov al, [di]
    mov length_real,al
    inc di
    xor cx,cx
    mov cl, length_real
    mov al,' '
    cld
    begin_analysis:
		mov first_position, di
		repne scasb
		jmp found
    return:
		cmp cx,0
		JZ to_output
    jmp begin_analysis
    to_output:
    call output
    jmp end_programm

found:
    call check
    jmp return
end_programm:
    mov ax, 4c00h
    int 21h   
end main	
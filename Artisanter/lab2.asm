.model small
.stack 256
.data
    buff db 6, 8 dup(?)
    error db "invalid input",10,'$'

.code
main:
    mov ax, @data
    mov ds, ax
    
    call InputInt
	push ax
	mov dl,'/'
	call OutDL
	call SlashN
	call InputInt

	mov bx,ax
	pop ax
	xor dx,dx
	div bx
	mov dl,'='
	call OutDL	
	call SlashN
	call OutputInt
end_all:	
    mov ax, 4c00h
    int 21h
	
OutDL proc
	push ax
	
    mov ah,02h
    int 21h
	
	pop ax
	ret
OutDL endp
SlashN proc
	push dx
	mov dl,10
	call OutDL
	pop dx
	ret
SlashN endp

InputInt proc
	push dx
    push cx
    push bx
    
    xor di,di
    mov dx, offset buff
	
    mov ah,0Ah
    int 21h
    
    mov si,offset buff+2
pos:
    xor ax,ax
    mov bx,10
loop1:
    mov cl,[si]
    cmp cl,0dh
    jz end_input
    
    cmp cl,'0'
    jc er
    cmp cl,'9'
    ja er
    
    sub cl,'0'
    mul bx
	jc er
    add ax,cx
	jc er
    inc si
    jmp loop1
er:
    mov dx, offset error
    mov ah,09h
    int 21h
	jmp end_all
    
end_input:
    cmp di,'1'
    jnz end_input_int
    neg ax
    
end_input_int:	
	push ax
	
    mov ah,02h
	mov dl,10
    int 21h
	
	pop ax
    pop bx
    pop cx
    pop dx
    ret
InputInt endp

OutputInt proc
	push bx
	push cx
	push dx
	
	xor cx,cx
	mov bx, 10
oi1:
	xor dx,dx
	div bx
	push dx
	inc cx
	test ax,ax
	jnz oi1
	
	mov ah,02h
oi2:
	pop dx
	add dl,'0'
	int 21h
	loop oi2
	
	push ax
	
    mov ah,02h
	mov dl,10
    int 21h
	
	pop ax
	pop dx
	pop cx
	pop bx
	ret
OutputInt endp
end main
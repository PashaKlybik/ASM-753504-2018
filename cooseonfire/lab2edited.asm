.model small
.stack 256
.data
message1 db 'Eneter divinded:', 10, 13, '$'
message2 db 'Enter divider: ', 10, 13, '$'
error_message db 'Invalid input! ', 10, 13, '$'
division_by_zero db 'Error! Division by zero.', 10,13, '$'


.code

proc print
	push ax
	push bx   ;сохраняем содержимое регистов
	push cx
	push dx
	xor cx,cx  
	mov bx, 10

remains:
	xor dx, dx 
	div bx
	add dl, '0' ;получаем очередную цифру и преобразуем в код символа, кладём в стек
	push dx
	inc cx
	test ax, ax ;проверка, есть ли ещё разряды в ax
	jnz remains

output:
	pop dx
	mov ah, 02h
	int 21h
	loop output
	mov dl, 10 ;перевод каретки на новую строку
	mov ah, 02h
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

proc scan
	push bx
	push cx
	push dx

	mov cx, 1 ; для loop после 1 итерации
	xor dx, dx ; готовим результат

get_char:
	mov ah, 01h
	int 21h
	inc cx

	cmp al, 13
	jz enter_case

	clc
	cmp al, '0'
	jb fail
	cmp al, '9'
	ja fail
	sub al, '0'
	mov bx, dx ; умножаем на 10 и прибавляем цифру
	shl dx, 2
	add dx, bx
	shl dx, 1
	jc fail
	xor ah, ah
	add dx, ax
	jc fail
	loop get_char


fail:
	stc ; устанавливаем флаг ошибки
	pop dx
	pop cx
	pop bx
	ret

enter_case:
	dec cx ; инкремент для enter и до loop
	dec cx
	test cx, cx ; пустая строка
	jz fail
	clc
	mov ax, dx
	pop dx
	pop cx
	pop bx
	ret
endp


main:
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    mov dx, offset message1
    int 21h

    call scan
    jc error
    call print
    push ax

    mov ah, 09h
    mov dx, offset message2
    int 21h
    call scan
    jc error
    call print
    test ax, ax
    jz div_error

    mov bx, ax
    xor dx, dx
    pop ax
    div bx
    call print
    jmp finish

div_error:
	mov ah, 09h
	mov dx, offset division_by_zero
	int 21h
	jmp finish

error:
	mov ah, 09h
	mov dx, offset error_message
	int 21h

finish:
    mov ax, 4c00h
    int 21h
end main
.model small
.stack 256
.data
message1 db 'Eneter divinded:', 10, 13, '$'
message2 db 'Enter divider: ', 10, 13, '$'
errorMessage db 'Invalid input! ', 10, 13, '$'
divisionByZero db 'Error! Division by zero.', 10,13, '$'
maxlen db 21
len db 0
buffer db 20 dup(0)


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
	push si
	
	mov ah, 0ah    ; получаем строку не более максимальной длины
	lea dx, maxlen
	int 21h

	xor dx, dx ; подготавливаем результат

	xor ch, ch ; заносим фактическую длину в счётчик
	mov cl, len
	test cl, cl ; пустая строка
	jz fail
	cmp cl, 5 ; не больше 5 символов
	ja fail
	lea si, buffer ;настраиваем указатель в начало строки
	cld ; сбрасываем флаг направления для того, чтобы прибавлять индекс
	clc

	char:
	lodsb ; берём очередной символ строки и передвигаемся на позицию вперёд
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
	loop char

	mov ax, dx
	jmp ok

fail:
	stc ; устанавливаем флаг ошибки
	pop si
	pop dx
	pop cx
	pop bx
	ret

ok:
	pop si
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
    jz divisionError

    mov bx, ax
    xor dx, dx
    pop ax
    div bx
    call print
    jmp finish

divisionError:
	mov ah, 09h
	mov dx, offset divisionByZero
	int 21h
	jmp finish

error:
	mov ah, 09h
	mov dx, offset errorMessage
	int 21h

finish:
    mov ax, 4c00h
    int 21h
end main
.model small
.stack 256
.data
message1 db 'Eneter divinded:', 10, 13, '$'
message2 db 'Enter divider: ', 10, 13, '$'
errorMessage db 'Invalid input! ', 10, 13, '$'
divisionByZero db 'Error! Division by zero.', 10,13, '$'
maxLen db 255
len db 0
buffer db 254 dup(0)

.code

proc print
	push ax
	push bx   ;сохраняем содержимое регистов
	push cx
	push dx
	xor cx,cx  
	mov bx, 10
	test ax, 1000000000000000b
	jnz negativeOutput
	jmp remains

negativeOutput:
	push ax
	xor dx, dx
	mov dl, '-'
	mov ah, 02h
	int 21h
	pop ax
	neg ax

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
	call newLine

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
	push di ; в di будет хранится присутствие минуса
	
	mov ah, 0ah    ; получаем строку не более максимальной длины
	lea dx, maxLen
	int 21h

	xor dx, dx ; подготавливаем результат

	xor ch, ch ; заносим фактическую длину в счётчик
	mov cl, len
	test cl, cl ; пустая строка
	jz fail
	lea si, buffer ;настраиваем указатель в начало строки
	cld ; сбрасываем флаг направления для того, чтобы прибавлять индекс
	clc
	mov al, [si]
	cmp al, '-'
	jz setNegativeFlag
	jmp char

setNegativeFlag:
	xor di, di
	mov di, 1
	inc si ; переходим на следующий символ и уменьшаеем счётчик
	sub cl, 1

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
	test di, 1 ; проверяем на отрицательное
	jnz negativeInput
	cmp ax, 32767
	ja fail
	jmp ok

fail:
	stc ; устанавливаем флаг ошибки
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	ret

negativeInput:
	cmp ax, 32768
	ja fail
	neg ax

ok:
	clc
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	ret
endp

proc newLine
	push ax
	push dx

    mov dl, 10
	mov ah, 02h
	int 21h

	pop dx
	pop ax
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
    call newLine
    call print
    push ax

    mov ah, 09h
    mov dx, offset message2
    int 21h
    call scan
    jc error
    call newLine
    call print
    test ax, ax
    jz div_error

    mov bx, ax
    xor dx, dx
    pop ax
    cwd ;берёт бит знака AH и заполняет им DX (замена xor dx, dx)
    idiv bx
    call print
    jmp finish

div_error:
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
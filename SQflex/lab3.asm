model small			; модель памяти
.stack 100h         ; установка размера стека
.data

devident dw 0
devider dw 0
temporary dw 0
unusial dw -32768

currentpos dw ?
isnegative dw ?

enterdevident db "Enter devident: ", '$'
enterdevider db "Enter devider: ", '$'
repeat db 13, 10,"Repeat please!", 13, 10, '$'
wholeres db "Result: ", '$'
errorzero db "Division by zero!", 13, 10, '$'
n db 10,"$"
u dw 10
cel dw ?

.code

InputInt proc
	mov currentpos, 0
	mov isnegative, 0

	entersymb:
		add currentpos, 1

		MOV AH, 01h
		INT 21h
		xor ah, ah

		cmp ax, 43
		jz plus

		cmp ax, 45
		jz minus	

	usiallint:
		CMP AX, 13 ;проверка на энтр
		JZ end1
		CMP AX, 48 ;проверка на 0-9
		JC error
		CMP AX, 57
		JZ usiallint
		JNC error

	contin:
		SUB AL, 48
		MOV AH, 0
		MOV BX, AX
		MOV AX, temporary
		MUL u
		JC error
		ADD AX, BX
		JC error
		MOV temporary, AX
		JMP entersymb

	plus:
		cmp currentpos, 1
		jz positive
		jmp error

	positive:
		mov isnegative, 0
		jmp entersymb

	minus:
		cmp currentpos, 1
		jz negative
		jmp error

	negative:
		mov isnegative, 1
		jmp entersymb

	error:
		mov currentpos, 0
		mov isnegative, 0
		LEA DX, repeat
		MOV AH, 09h
		INT 21h
		MOV AX, 0
		MOV temporary, AX
		JMP entersymb

	makeneg:
		neg temporary
		jmp end2

	end1:
		cmp isnegative, 1
		jz makeneg

	end2:
		mov cx, temporary
		cmp cx,unusial
		jz error

	ret
InputInt endp

OutputInt proc ;вывод из ах

	test ax, ax ;; Проверяем число на знак.
	jns out1

	mov  cx, ax ;; Если оно отрицательное, выведем минус и оставим его модуль.
    mov ah, 02h
    mov dl, '-'
    int 21h
    mov ax, cx
    neg ax

    out1:
		MOV CX, 0

		next:
			MOV DX, 0
			DIV u
			PUSH DX
			MOV DX, 0
			INC CX
			CMP AX, 0
			JNZ next

		cycle:
			POP DX
			MOV DH, 0
			ADD DL, 48
			MOV AH, 02h
			INT 21h
			LOOP cycle

	ret
OutputInt endp

stasyan proc
	push ax
	push dx

	lea dx, n
	mov ah, 09h
	int 21h

	pop dx
	pop ax

	ret
stasyan endp

start:
	MOV AX, @data
	MOV DS, AX

	LEA DX, enterdevident
	MOV AH, 09h
	INT 21h
	call InputInt
	mov ax, temporary

	push temporary
	pop devident
	mov ax, devident
	mov temporary, 0

	LEA DX, enterdevider
	MOV AH, 09h
	INT 21h
	call InputInt
	mov ax, temporary

	push temporary
	pop devider
	mov ax, devider
	mov temporary, 0

	cmp devider, 0
	jz altendofprog

	mov ax, devident
	cwd
	idiv devider

	mov cel, ax ;ax=целое

	LEA DX, wholeres
	MOV AH, 09h
	INT 21h
	mov ax, cel

	call outputint

	call stasyan

	MOV AH, 4Ch
	INT 21h

	altendofprog:
	LEA DX, errorzero
	MOV AH, 09h
	INT 21h

	MOV AH, 4Ch
	INT 21h
end start 
.model small
.stack 256
.386
.data

Task3 db 13,10,'Task3------------$'
Number db 13,10,'Number: $'
EnterNumber db 13,10,'Enter number:  $'
EnterDividend db 13,10,'Enter dividend:  $'
EnterDivider db 13,10,'Enter divider:  $'
Answer db 13,10,'Answer:  $' 
Remainder db 13,10,'Remainder :  $' 
DividingOnNull db 13,10,'Dividing on 0!$' 
Null db 13,10,'$'
resultSign dw 0 
residue dw 0 
count dw 0 
noSign dw 0 
isNeg dw 0 
isValue dw 0 
preventInput dw 0
isEmpty dw 1        
divider dw 2 
firstInput dw 1

.code
	clearAllReg proc			;очистка регистров
		xor ax, ax
		xor bx, bx
		xor dx, dx

		ret
	clearAllReg endp			

	clearAllFlag proc			;сбрасываем все флаги
		mov firstInput, 1
		mov noSign, 0
		mov isNeg, 0
		mov isEmpty, 1
		mov preventInput, 0

		ret
	clearAllFlag endp
	
	printRegA proc				;вывод из регистра АХ
		push    ax
		push    bx
		push    cx
		push    dx
		push    di

		mov     cx, 10          ;cx - основание системы счисления
		xor     di, di          
		or      ax, ax			;проверка на отрицательность
		jns     Convert
		push    ax
		mov     dx, '-'
		mov     ah, 2           ;ah - функция вывода символа
		int     21h

		pop     ax
		neg     ax
		Convert:
			xor     dx, dx
			div     cx              ;перевод в десятичную систему исчисления
			add     dl, '0'         ;перевод в строку
			inc     di				;увеличиваем каунт для строки
			push    dx
			or      ax, ax			
			jnz     Convert
		print:
			pop     dx              ;достаем из стека
			mov     ah, 2           ;ah - функция вывода символа
			int     21h
			dec     di              ;отнимаем от каунта строки пока не станет <=0
			jnz     print
			pop     di
			pop     dx
			pop     cx
			pop     bx
			pop     ax
		ret
	printRegA endp

	readSymbolInput proc				;посимвольный ввод	
		push bx
		push cx
		push dx

		call clearAllReg				;процедура очистки регистров
		mov cx, 0
		call clearAllFlag				;процедура очистки флагов
		mov isValue, 0
		mov count, 0

		StartSymbolInput:
			call clearAllReg
			mov ah, 08h					;ввод символа
			int 21h
			cmp al, 13
			jz endSymbolInput

			cmp al, 8
			jz backspace

			cmp al, 27
			jz escape

			cmp preventInput, 1			
			jnz checkSymbolInput
			jmp StartSymbolInput
			checkSymbolInput:
			
			cmp al, '-'
			jz minus

			cmp al, '+'
			jz plus

			cmp al, '9'
			ja StartSymbolInput

			cmp al, '0'
			jb StartSymbolInput
			
			cmp isNeg, 1                        ;Проверка на отрицательность
			jnz notNeg

			sub ax, '0'
			mov ah, 0
			mov cx, 0

			cmp firstInput, 1
			jnz input1

			mov firstInput, 0
			mov noSign, 1

			cmp al, 0
			jnz input1

			mov preventInput, 1

			input1:
			push ax
				mov ax, isValue
				mov bx, 10
				push dx
					mul bx				;умножаю на 10 для проверки на переполнение
				pop dx
				mov cx, ax
			pop ax

			jnc next1
			jmp overflow

			next1:
				add cx, ax
				jnc next2
				jmp overflow
			next2:
				mov bl, al
				mov ax, cx
				mov cx, 0
				mov dx, 0
				
				div divider
				mov residue, dx

				sub cx, ax
				jo overflow

				sub cx, ax
				jo overflow

				sub cx, dx
				jo overflow

				mul divider
				add ax, residue

				mov isValue, ax

				inc count
				mov isEmpty, 0

				mov dl, bl
				add dl, '0'

				mov ah, 02h
				int 21h

				jmp StartSymbolInput
			notNeg:
				sub ax, '0'
				mov ah, 0

				cmp firstInput, 1
				jnz input2

				mov firstInput, 0
				mov noSign, 1

				cmp al, 0
				jnz input2

				mov preventInput, 1
				
                input2:
				mov bl, al
				mov ax, cx

				push bx

					push dx

						mov bx, 10				;умножаю на 10 для проверки на переполнение
						imul bx

					pop dx

				pop bx

				jo overflow

				add ax, bx
				jo overflow

				mov cx, ax

				inc count
				mov isEmpty, 0

				mov dl, bl
				add dl, '0'
				
				mov ah, 02h
				int 21h

				jmp StartSymbolInput
		plus:
			cmp NoSign, 1
			jnz stillIncluded

			jmp StartSymbolInput

			stillIncluded:

				mov isEmpty, 0
				mov dl, '+'
			
				mov ah, 02h
				int 21h

				mov noSign, 1
				inc count

			jmp StartSymbolInput
		backspace:
			cmp count, 0
			jnz good

			jmp StartSymbolInput

			good:

				cmp isNeg, 1
				jnz noNeg

					dec count
					mov dx, 0
					mov ax, isValue
					mov bx, 10
					div bx
					mov isValue, ax

					cmp count, 0
					jnz mark4

					mov isValue, 0

					call clearAllFlag

					call clearAllReg

					xor cx, cx

				mark4:
					jmp next
			noNeg:
				dec count
				mov ax, cx
				mov bx, 10
				mov dx, 0
				div bx
				mov cx, ax

				cmp count, 0
				jnz mark5

				call clearAllFlag

				call clearAllReg

				xor cx, cx

				mark5:

				jmp next

			next:

				mov dl, 8
				mov ah, 02h
				int 21h

				mov dl, ' '
				int 21h

				mov dl, 8
				int 21h

			jmp StartSymbolInput
		escape:
			mov cx, count

			cmp count, 0
			jz start

			again:

				mov dl, 8
				mov ah, 02h
				int 21h

				mov dl, ' '
				int 21h

				mov dl, 8
				int 21h

			loop again

			call clearAllFlag

			call clearAllReg

			xor cx, cx

			mov count, 0
			mov isValue, 0

			start:

			jmp StartSymbolInput
		minus:

			cmp noSign, 1
			jnz stillIncluded1

			jmp StartSymbolInput

			stillIncluded1:

				mov isNeg, 1
				mov dl, '-'

				mov ah, 02h
				int 21h

				mov noSign, 1

				inc count

			jmp StartSymbolInput
		overflow:
			jmp StartSymbolInput
			
		endSymbolInput:

			cmp isEmpty, 1
			jnz checkNeg

			jmp StartSymbolInput

			checkNeg:

				cmp isNeg, 1
				jz pushIsValue

				mov ax, cx
				
				pop dx
				pop cx
				pop bx
				
				ret

				pushIsValue:

					mov cx, isValue
					
					sub cx, 1
					neg cx
					sub cx, 1
					mov ax, cx

					pop dx
					pop cx
					pop bx

					ret
	readSymbolInput endp

main:
	mov ax, @data
	mov ds, ax

	lea dx, Task3
	mov ah, 09h				;вывод строки
	int 21h

	lea dx, EnterDividend
	mov ah, 09h
	int 21h

	call readSymbolInput
	
	mov cx, ax
	
	lea dx, Number
	mov ah, 09h
	int 21h

	mov ax, cx
	call printRegA

	or cx, cx
	jns mark1

	inc resultSign
	neg cx

	mark1:
	lea dx, EnterDivider
	mov ah, 09h
	int 21h

	call readSymbolInput

	cmp ax, 0
	jz mark1

	mov bx, ax

	lea dx, Number
	mov ah, 09h
	int 21h

	mov ax, bx
	call printRegA

	or bx, bx
	jns mark2

	inc resultSign
	neg bx

	mark2:
	xor dx, dx
	mov ax, cx
	div bx

	mov bx, dx
	mov cx, ax
	xor dx, dx

	mov ax, resultSign
	div divider

	cmp dx, 1
	jnz mark3

	neg cx
	neg bx

	mark3:
	lea dx, Answer
	mov ah, 09h
	int 21h

	mov ax, cx
	call printRegA

	lea dx, Remainder
	mov ah, 09h
	int 21h

	mov ax, bx
	call printRegA

	lea dx, Null
	mov ah, 09h
	int 21h

	call clearAllReg              
	xor cx, cx

	mov ax, 4C00h						;Конец программы
	int 21h
end main
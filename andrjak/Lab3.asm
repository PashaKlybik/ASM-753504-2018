.model small
.stack 256
.data
    numberSystem dw 10
    errorStr db 'Error!$'
    endLine db 13, 10, '$'
	outputBuffer db '      ',13, 10,'$'
    strDiv db '/',13, 10,'$'
	strInt db 'the integer part:',13, 10,'$'
	strRemainder db 'Remainder:',13, 10,'$'
	errorStrZero db 'Number can not start from zero!',13, 10,'$'
	errorStrOverflow db 'Number is very large!',13, 10,'$'
	errorStrInvalidSymbol db 'You entered a wrong symbol!',13, 10,'$'
.code
;Процедура для очистки экрана при запуске программы 
startCleaning PROC 
  mov ax,0600h     ;AH 06 (прокрутка) ;AL 00 (весь экран)
  mov bh,07        ;(черно/белый)
  mov cx,0000      ;Верхняя левая позиция
  mov dx,184Fh     ;Нижняя правая позиция
  int 10h          ;Передача управления в BIOS
  
  mov ax,02h
  xor dx,dx        ;Перемещение курсора к началу консоли   
  int 10h
startCleaning ENDP

wordToStr PROC              ;Превращает число в строку
; AX - слово
; DI - буфер для строки (5 символов(65536)).	 
    push ax
    push bx
    push cx
    push dx
    push di
	
    xor cx,cx               ;Обнуление CX
    mov bx,10               ;В BX делитель (10) 
  remainder:                ;Цикл получения остатков от деления
    xor dx,dx               ;Обнуление старшей части двойного слова
    div bx                  ;Деление AX остаток в DX
    add dl,'0'              ;Преобразование остатка в код символа
    push dx                 
    inc cx                  ;Увеличение счетчика символов
    test ax,ax              ;Проверка AX
    jnz remainder           ;Переход к началу цикла, если частное не 0.

  extraction:             	;Цикл извлечения символов из стека
    pop dx                  ;Восстановление символа из стека
    mov [di],dl             ;Сохранение символа в буфере
    inc di                  ;Инкремент адреса буфера
    loop extraction         
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
ret	
wordToStr ENDP

;Процедура преобразования слова в строку в десятичном виде (со знаком)
; AX - слово
; DI - буфер для строки (6 символов).
signWordToStr PROC
    push ax
	mov di, offset outputBuffer
    test ax,ax              ;Проверка знака AX
    jns notSign      		;Если >= 0, преобразуем как беззнаковое
    mov [di],'-'            ;Добавление знака в начало строки
    inc di                  ;Инкремент DI
    neg ax                  ;Изменение знака значения AX
    notSign:
    call wordToStr          ;Преобразование беззнакового значения
    pop ax
ret
signWordToStr ENDP

printStr PROC 				;передаётся адрес строки в регистре DX
  push ax	
  mov ah,9                 
  int 21h  
  pop ax
ret
printStr ENDP

clear PROC
;ввод DI - адрес буфера
  push cx
  mov cx,7 
  following:            ;Цикл очистки Бувера вывода 
    mov [di],' '        
    inc di              
    loop following 		
  pop cx
ret	
clear ENDP

remove PROC       ;Процедура для удаления сивола 
    push ax
    push bx    
    push cx         

    mov ah, 0AH   ;Запись символа на том месте куда указывает курсор
    mov bh, 0
	mov al, ' '   ;Сивол который будет выводится 
    mov cx, 1     ;Сколько сиволов записать 
    int 10h       

    pop cx
    pop bx
    pop ax
    ret 
remove ENDP

wordEnter PROC
;Возврат :ax = число введённое с консоли 
  push bx
  push cx
  push dx
  push di
  push si
  
  xor bx,bx                    ;Очищаем bx для хранения временных данных 
  xor si,si                    ;Храним зак 
  
  jmp iterate  
zero:
    cmp bx,0
    jnz continue                 ;Если до этого уже были введены сиволы возврощаемся назад 
    mov dl,8
    mov ah,02h                   ;Стираем символ
    int 21h
    call remove
    jmp iterate
	
signDelete:
    cmp si,0
	je positive
	mov si,0
	jmp positive
  
iterate:                       ;Часть кода которая повторяется до тех пор 
    xor di,di                  ;пока не будет введён Enter или не переполнится
    mov ah,01h                 ;область памяти 
    int 21h                       
    cmp  al,8                  ;Сравнение введённого символа с Backspace
    je bckspace
	cmp al,13                  ;Сравнение введённого символа с Enter
    je enterr  
    cmp al,27                  ;Сравнение введённого символа с Escape
    je escape
    cmp al,'-'
    je minus   
    sub al,'0'                 ;Превращение символа числа ASCII в число в переменной 
    cmp al,9                   ;Проверка является ли сивол десятичным числом (сивол > 9)
    ja exceptionInvalidSymbol 
    test al,al                 ;Если символ является нулём и перед ним нет символов 
    je zero                    ;то его не выводим на экран и не считаем 
continue:
    xor ch,ch                  
    mov cl,al   
    mov ax,bx                  ;Записываем в ax результат предыдущих итераций 
    mul numberSystem
    cmp dx,0                   ;Если вышло за пределы слова 
    jne exceptionOverflow
    add ax,cx
    jb  exceptionOverflow      ;Если вышло за пределы слова 
    cmp si,1
    je negative
    cmp ax,32767               ;Переполнение при положительном числе 
    jnbe exceptionOverflow 
back:
    mov bx,ax                  ;Записываем в bx результат вычислений (Введённое число)
    jmp iterate

enterr:
    test bx,bx
	je exceptionNull           ;Исключение если до этого небыл введён ни один символ 
    mov ax,bx
    cmp si,1                   ;Если число положительное переходим к концу ввода 
    jne endWordEnter
    neg ax                     ;Превращаем регистр ax в отрицательное число 
	jmp endWordEnter           ;Переход к концу выполнения если всё правильно 

bckspace:
    test bx,bx
	je signDelete
  positive:
    xchg bx,ax
    xor dx,dx
    div numberSystem            ;Делим результат предыдущих итераций на 10 в результате 
    xchg bx,ax                  ;получаем в целой части число == числу до ввода последнего
    call remove                 ;символа а в остатке сам символ (Нам нужна только целая часть)
    jmp iterate
	
escape:
    xor bx,bx
	xor si,si
    mov cx,7
  cleaning:
    mov dl,8
    mov ah,02h                   ;Очищаем все символы 
    int 21h
    call remove
    loop cleaning    
    cmp di,1                     ;Проверки для вызова другими функциями 
    je InvalidSymbol              
    cmp di,2
    je Overflow
    jmp iterate
	
minus:                            ;Если был введён минус 
	cmp bx,0                      ;Проверяем на какой позиции пишется число 
	jne exceptionInvalidSymbol
	cmp si,0
	jne exceptionInvalidSymbol
    mov si,1
	jmp iterate                   ;Продолжаем ввод числа 

negative:
    cmp ax,32768                        ;Граница отрицательного числа 
    jnbe exceptionOverflow              ;Если переполнение 
    jmp back                            ;Если всё нормально

exceptionInvalidSymbol:
    mov di,1
    jmp escape
  InvalidSymbol:
	mov dx, offset errorStrInvalidSymbol
    call printStr
    jmp iterate
	
exceptionOverflow:
    mov di,2
    jmp escape
  Overflow:
    mov dx,offset errorStrOverflow      
    call printStr
    jmp iterate
	
exceptionNull:	
	mov dx,offset errorStrZero   ;Если пользователь нажал Enter ,но ничего не ввёл
	call printStr
	jmp iterate
	
endWordEnter:
  pop si 
  pop di	
  pop dx
  pop cx
  pop bx
  ret
wordEnter ENDP	

exception PROC
    cmp bx,-1
	jnz notException
    lea dx,errorStr              ;На случай переполнения при делении единственый возможный вариант
    call printStr                ;-32768/-1 приводит к переполнению 
    mov ax, 4c00h
    int 21h
ret
exception ENDP

main:
    mov ax, @data
    mov ds, ax
 
    call startCleaning          ;Очищаем экран	
    call wordEnter              ;Получаем первое число 
    xchg ax,bx                  ;Временно перемещаем первое число в bx
	
	push dx                     ;Сохраняем dx потому что это влияет на работу других процедур
	lea dx,strDiv        ;Выводим знак деления 
    call printStr
    pop dx 	                    ;Востонавливаем dx
	
    call wordEnter              ;Получаем второе число 
    xchg ax,bx                  ;Мнеям первое и второе число местами 
    
	cmp ax,-32768               ;Проверка на фатальную ошибку переполнения 
	je exception
  notException:
  
	cmp ax,0                    ;Так как при делени используется обратный код
    jl point1                   ;и два регистра , то необходимо в случае
    jmp point2
    point1:
    cwd
    point2:
    idiv bx                     ;Выполняем деление 

    mov bx,dx                   ;Записываем остаток в bx 
 
    lea dx,strInt           
    call printStr
    call signWordToStr             ;Выводим целочисленую часть 
    lea dx,outputBuffer
    call printStr

    lea di,outputBuffer      ;Очищаем буфер для вывода чтобы при выводе второго числа 
    call clear                      ;небыло ошибок 
	
    lea dx,strRemainder
    call printStr
    mov ax,bx                       ;Выводим остаток 
	test ax,ax                      ;Если число меньше нуля то преобразуем в положительно 
	jns allGood                     ;иначе ничего не делаем 
	neg ax                          ;Меняем знак остатка так как остаток всегда положительный 
	allGood:
	lea di,outputBuffer    
    call wordToStr
    lea dx,outputBuffer
    call printStr 
	
    mov ax, 4c00h
    int 21h
end main
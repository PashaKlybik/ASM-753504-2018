.model small
.stack 256
.data
    numberSystem dw 10
    errorStr db 'Error!$'
    endLine db 13, 10, '$'
    outputBuffer db '     ',13, 10,'$'
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
		
  mov di, offset outputBuffer
  xor cx,cx                 ;Обнуление CX
  remainder:                ;Цикл получения остатков от деления
    xor dx,dx               ;Обнуление старшей части двойного слова
    div numberSystem        ;Деление AX=(DX:AX)/BX, остаток в DX
    add dl,'0'              ;Преобразование остатка в код символа
    push dx                 ;Сохранение в стеке
    inc cx                  ;Увеличение счетчика символов
    test ax,ax              ;Проверка AX
    jnz remainder           ;Переход к началу цикла, если частное не 0.
  extraction:               ;Цикл извлечения символов из стека
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
  mov cx,6 
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
  
  xor bx,bx                    ;Очищаем bx для хранения временных данных  
  
iterate:                       ;Часть кода которая повторяется до тех пор 
    mov ah,01h                 ;пока не будет введён Enter или не переполнится 
    int 21h                    ;область памяти   
    cmp  al,8                  ;Сравнение введённого символа с Backspace
    je bckspace
    cmp al,13                  ;Сравнение введённого символа с Enter
    je enterr  
    cmp al,27                  ;Сравнение введённого символа с Escape
    je escape    
    sub al,'0'                 ;Превращение символа числа ASCII в число в переменной 
    cmp al,9                   ;Проверка является ли сивол десятичным числом (сивол > 9)
    ja exceptionInvalidSymbol 
    test al,al                 ;Если символ является нулём и перед ним нет символов 
    je zero                    ;то его не выводим на экран и не считаем 
continue:
    xor cx,cx    
    mov cl,al   
    mov ax,bx                  ;Записываем в ax результат предыдущих итераций 
    mul numberSystem
    cmp dx,0                   ;Если вышло за пределы слова 
    jnz exceptionOverflow
    add ax,cx
    jc  exceptionOverflow      ;Если вышло за пределы слова  
    mov bx,ax                  ;Записываем в bx результат вычислений (Введённое число)
    jmp iterate

enterr:
    test bx,bx
    je exceptionNull           ;Исключение если до этого небыл введён ни один символ 
    mov ax,bx
    jmp endWordEnter           ;Переход к концу выполнения если всё правильно 

bckspace:
    xchg bx,ax
    xor dx,dx
    div numberSystem            ;Делим результат предыдущих итераций на 10 в результате 
    xchg bx,ax                  ;получаем в целой части число == числу до ввода последнего
    call remove                 ;символа а в остатке сам символ (Нам нужна только целая часть)
    jmp iterate
 
escape:
    xor bx,bx
    mov cx,6
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

zero:
    cmp bx,0
    jnz continue                 ;Если до этого уже были введены сиволы возврощаемся назад 
    mov dl,8
    mov ah,02h                   ;Стираем символ
    int 21h
    call remove
    jmp iterate

exceptionNull:	
    mov dx,offset errorStrZero   ;Если пользователь нажал Enter ,но ничего не ввёл
    call printStr
    jmp iterate

endWordEnter:	
  pop dx
  pop cx
  pop bx
  ret
wordEnter ENDP	

main:
    mov ax, @data
    mov ds, ax
 
    call startCleaning          ;Очищаем экран
    call wordEnter              ;Получаем первое число 
    xchg ax,bx                  ;Временно перемещаем первое число в bx
	
    push dx                     ;Сохраняем dx потому что это влияет на работу других процедур
    mov dx,offset strDiv        ;Выводим знак деления 
    call printStr
    pop dx 	                    ;Востонавливаем dx
	
    call wordEnter              ;Получаем второе число 
    xchg ax,bx                  ;Мнеям первое и второе число местами 
    div bx                      ;Выполняем деление 
    mov bx,dx                   ;Записываем остаток в bx 
 
    mov dx,offset strInt           
    call printStr
    call wordToStr                 ;Выводим целочисленую часть 
    mov dx,offset outputBuffer
    call printStr

    mov di,offset outputBuffer     ;Очищаем буфер для вывода чтобы при выводе второго числа 
    call clear                     ;небыло ошибок 

    mov dx,offset strRemainder
    call printStr
    mov ax,bx                      ;Выводим остаток 
    call wordToStr
    mov dx,offset outputBuffer
    call printStr 
 
    mov ax, 4c00h
    int 21h
end main
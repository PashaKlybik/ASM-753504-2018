.model small
.stack 256
.data
    arraySize dw ?
    messageEnterA db 'Enter the number with which you will compare the elements of the matrix:$'
    messageEnterN db 'Enter the number of lines:$'
    messageEnterM db 'Enter the number of columns:$'
    numberSystem dw 10
    errorStr db 'Error!$'
    spaceChar db '  ','$'
    outputBuffer db '       ','$'
    inputFile db "input.txt", 0
    errorStrZero db 'Number can not start from zero!',13, 10,'$'
    errorStrOverflow db 'Number is very large!',13, 10,'$'
    errorStrInvalidSymbol db 'You entered a wrong symbol!',13, 10,'$'
    incorrectEntryMessage db 'Not possible parameters or array size too large!',13, 10,'$'
    A dw ?
    strLength dw ?
    endLine db 13, 10, '$'
    array dw 5000 dup(0)
    buffer db ?
    handle dw ? 
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

;Процедура преобразования слова в строку в десятичном виде (со знаком)
; AX - слово
; DI - буфер для строки (6 символов).
signWordToStr PROC
    push ax
    push di 
    mov di, offset outputBuffer
    test ax,ax              ;Проверка знака AX
    jns notSign      		;Если >= 0, преобразуем как беззнаковое
    mov [di],'-'            ;Добавление знака в начало строки
    inc di                  ;Инкремент DI
    neg ax                  ;Изменение знака значения AX
    notSign:
    call wordToStr          ;Преобразование беззнакового значения
    pop di
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

clear PROC              ;Ввод DI - адрес буфера
  push cx
  mov cx,6 
  following:            ;Цикл очистки Бувера вывода 
    mov [di],' '        
    inc di              
    loop following 		
  pop cx
ret	
clear ENDP

wordEnter PROC          ;Возврат :ax = число введённое с консоли 
  push bx
  push cx
  push dx
  push di
  push si
  xor ax,ax
  xor bx,bx                    ;Очищаем bx для хранения временных данных 
  xor cx,cx
  xor di,di
  xor dx,dx 
  xor si,si                    ;Храним зак 
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
    cmp al,32                  ;Сравнение с пробелом
    je enterr
    cmp al,27                  ;Сравнение введённого символа с Escape
    je escape
    cmp al,'-'
    je minus   
    sub al,'0'                 ;Превращение символа числа ASCII в число в переменной 
    cmp al,9                   ;Проверка является ли сивол десятичным числом (сивол > 9)
    ja exceptionInvalidSymbol 

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
    jne exceptionNull          ;Исключение если до этого небыл введён ни один символ
    xor ax,ax                  ;Вводится ноль 
    jmp endWordEnter
  exceptionNull:
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
	
endWordEnter:
  pop si 
  pop di	
  pop dx
  pop cx
  pop bx
  ret
wordEnter ENDP

inputArray PROC                ;Процедура для ввода Массива с клавиатуры
  push ax                      
  push bx
  push cx
  push dx
  push di
  push si
  comback:
    call startCleaning
    lea dx,messageEnterA
    call printStr
    call wordEnter              ;Ввод А с которым будем сравнивать 
    mov A,ax 
    lea dx,messageEnterN 
    call printStr
    call wordEnter              
    cmp ax,0                    ;Проверка на не адекватного пользователя (размер массива)
    jle wrongArraySize          ;Размерности массива
    mov bx,ax 
    lea dx,messageEnterM
    call printStr	
    call wordEnter
    cmp ax,0                    ;Если в массиве больше 5000 слов 
    jle wrongArraySize
    mov strLength,ax            ;Количество элементов в строке 
  
    xor dx,dx                   ;Было бы актуально для массивов больших размеров 
    mul bx                      ;Размер массива 
    cmp ax,5000                 ;Если в массиве слишком много символов 
    jg wrongArraySize           ;Мне кажется 5000 чисел вполне достаточно 
    mov arraySize,ax            ;Передаём размер массива 

    xor cx,cx                   ;Очищаем cx чтобы использовать его в качестве счётчика
    mov cx,ax                   ;Передаём размер массива
    lea di,array                ;Передаём адрес массива 
  inputForArray:                ;Цикл ввода 
    call wordEnter
    mov [di],ax             ;Передача в di введённого числа
    inc di	
    inc di 
    loop inputForArray
    jmp endInputArray
 
  wrongArraySize:
    lea dx,incorrectEntryMessage ;Собщение в случае не корректного ввода 
    call printStr
    jmp comback                  ;Повторение ввода в случае не корректных параметров 
  endInputArray:
  pop si
  pop di
  pop dx
  pop cx
  pop bx
  pop ax
ret
inputArray ENDP

outputArray PROC
push ax                      
push bx
push cx
push dx
push di
    lea di,array
    mov bx,[strLength]             
    mov cx,[arraySize]             
  displaing:
    xor ax,ax 
    mov ax,[di] 	
  next:
    call signWordToStr
    lea dx,outputBuffer
    call printStr
    lea dx,spaceChar
    call printStr
    push di
    lea di,outputBuffer
    call clear
    pop di
    inc di              ;Инкрементируем 2 раза так как в масив записываем word
    inc di
    dec bx 
    test bx,bx 
    je printEndString
    loop displaing
	
  printEndString:
    lea dx,endLine
    call printStr
    mov bx,[strLength]
    dec cx	
    test cx,cx 
    je endOutputArray
    jmp displaing
	
  endOutputArray:
pop di
pop dx
pop cx
pop bx
pop ax
ret
outputArray ENDP

task PROC
lea di,array
mov cx,[arraySize]
  performance:
    mov ax,[A]
    mov bx,[di]
    inc di
    inc di
    cmp bx,ax
    jbe performanceYet                       ;Меньше или равно 	
    mov [di-2],0
  performanceYet:
    loop performance
ret
task ENDP

FileOpen PROC               ;Вход = dx адрес сторки (Имя файла)
push cx
    mov ah,3Dh              ;Функция DOS 3Dh (открытие файла)
    xor al,al               ;Режим открытия - только чтение
    xor cx,cx               ;Нет атрибутов - обычный файл
    int 21h                 ;Прерывание 
    mov [handle],ax         ;Сохранение дискриптора 
pop cx
ret	
FileOpen ENDP            

StrToWord PROC ;выход: ax = введённое слово ,вход: di = буфер строки
push bx
push cx
push dx
push di
push si
  lea di,outputBuffer
  mov cx,7
  mov bx,2
  xor ax,ax
  xor dx,dx
  cmp [di],'-'
  jne notSignWord
    xor bx,bx
    inc di
  notSignWord:
    mov si,[di]
    sub si,'0'                 ;Превращение символа числа ASCII в число в переменной 
    cmp si,9 
    ja EndStrToWord
    mul numberSystem
    add ax,si
    inc di
  loop notSignWord
    test bx,bx
    jne EndStrToWord
    neg ax
  EndStrToWord:
    lea di,outputBuffer
    call clear
pop si
pop di
pop dx
pop cx
pop bx
ret
StrToWord ENDP

WordFromFile PROC         ;Вход handle Дискриптор файла
  push bx                 ;Выход ax = число из файла 
  push cx                 ;Работает как посимвольный ввод
  push dx                 ;Результат оказывается в буфере 
  push di                 ;После чего при помощи функции перевода 
    lea di,outputBuffer   ;Буфера в слово получаем результат 
    mov cx,7
  backFileWord:
    mov bx,[handle]
    xor ax,ax
    mov ah,3Fh
    lea dx,buffer
    push cx
    mov cx,1 
    int 21h
    pop cx
    cmp [buffer],' '
    jnz nextFileWord	
    lea di,outputBuffer
    call StrToWord
    jmp endFileWord
  nextFileWord: 
    xor ax,ax
    mov al,[buffer]
    mov [di],ax
    inc di
    loop backFileWord
  endFileWord:
  pop di
  pop dx
  pop cx
  pop bx
ret
WordFromFile ENDP

ArrayFromFile PROC      ;Получение массива из файла 
  push ax                      
  push bx
  push cx
  push dx
  push di
  push si
  combackFile:
    call startCleaning
    call WordFromFile              ;Ввод А с которым будем сравнивать 
    mov A,ax 
    call WordFromFile              
    cmp ax,0                    ;Проверка на не адекватного пользователя (размер массива)
    jle wrongFileArraySize          ;Размерности массива
    mov bx,ax 	
    call WordFromFile
    cmp ax,0                    ;Если в массиве больше 5000 слов 
    jle wrongFileArraySize
    mov strLength,ax            ;Количество элементов в строке 
    
    xor dx,dx                   ;Было бы актуально для массивов больших размеров 
    mul bx                      ;Размер массива 
    cmp ax,5000                 ;Если в массиве слишком много символов 
    jg wrongFileArraySize       ;Мне кажется 5000 чисел вполне достаточно 
    mov arraySize,ax            ;Передаём размер массива 
	
    xor cx,cx                   ;Очищаем cx чтобы использовать его в качестве счётчика
    mov cx,ax                   ;Передаём размер массива
    lea di,array                ;Передаём адрес массива 
  inputForFileArray:                ;Цикл ввода 
    call WordFromFile
    mov [di],ax             ;Передача в di введённого числа
    inc di	
    inc di 
    loop inputForFileArray
    jmp endFileInputArray
 
  wrongFileArraySize:
    lea dx,incorrectEntryMessage ;Собщение в случае не корректного ввода 
    call printStr
    jmp combackFile                  ;Повторение ввода в случае не корректных параметров 
  endFileInputArray:
  pop si
  pop di
  pop dx
  pop cx
  pop bx
  pop ax
ret
ArrayFromFile ENDP

main:
    mov ax, @data
    mov ds, ax  
    mov es, ax	

    lea dx,inputFile
    call FileOpen
    call ArrayFromFile                ;Ввести массив из файла
    call task
    call outputArray
    ;call inputArray
    ;call task                        ;Ввести массив с клавиатуры 
    ;call outputArray
	
    mov ax, 4c00h
    int 21h	
end main
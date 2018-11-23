.model small
.stack 256
.data
    errorStr db 'Error!',13, 10,'$'
    inputBuffer db 99, 100 dup ('$')
    strLength dw ?
    Vowels db 'AaEeIiOoUu',0
    endStr db 13, 10, '$'
    outputBuffer db 25 dup (' '),'$'

.code
startCleaning PROC          ;Процедура для очистки экрана при запуске программы
    mov ax,0600h              ;AH 06 (прокрутка) ;AL 00 (весь экран)
    mov bh,07                 ;(черно/белый)
    mov cx,0000               ;Верхняя левая позиция
    mov dx,184Fh              ;Нижняя правая позиция
    int 10h                   ;Передача управления в BIOS
  
    mov ax,02h
    xor dx,dx                 ;Перемещение курсора к началу консоли   
    int 10h
ret
startCleaning ENDP

wordToStr PROC              ;Превращает число в строку	 
    push ax                 ;AX - слово
    push bx                 ;DI - буфер для строки (5 символов(65536)).	
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

printStr PROC 				;Передаётся адрес строки в регистре DX
  push ax	
  mov ah,9                 
  int 21h  
  pop ax
ret
printStr ENDP

clear PROC                  ;Ввод DI - адрес буфера
  push cx
  mov cx,24 
  following:                ;Цикл очистки Бувера вывода 
    mov [di],' '        
    inc di              
    loop following 		
  pop cx
ret	
clear ENDP

inputStr PROC                        ;Ввод строки 
    push ax
    push dx
    mov ah,0aH
    lea dx,inputBuffer
    int 21h
    xor ax,ax
    mov al,[inputBuffer+1]            ;Получение длины введён
    mov strLength,ax                  ;Передача полученной длины в переменную 
    pop dx
    pop ax
ret
inputStr ENDP

searchVowels PROC                   ;Сравнение выбраного символа с списком гласных
  push ax                           ;Результат в bx
  push cx
  push di
  push es
	
    xor ax,ax
    xor bx,bx                        
    cld                              ;Поиск в перёд по строке
    mov cx,10                        ;Количество гласных равно количеству сравнений 
    mov al,[si]                      ;Временная переменная 
    lea di,Vowels                    ;Адрес строки с гласными в ES:DI
    repne scasb                      ;Сравниваем al с гласными 
    jne endSearchVowels              ;Если совпадение не найдено 
    inc bx                           ;Показывает найдено ли соответствие 

    cld                              ;Поиск в перёд по строке
    mov cx,10
    mov al,[si+1]                    ;Временная переменная 
    lea di,Vowels                    ;Адрес строки с гласными в ES:DI
    repne scasb                      ;Сравниваем al с гласными 
    jne endSearchVowels              ;Если совпадение не найдено 
    inc bx                           ;Если найдены две последовательно идущие гласные bx = 2

  endSearchVowels:  
  pop es
  pop di
  pop cx
  pop ax
ret
searchVowels ENDP

search PROC
  push ax
  push bx
  push cx
  push dx
  push di
  push si
    
    xor dx,dx
    xor bx,bx
    xor cx,cx 	
    mov cx,[strLength]                ;Передаём в cx длину введённой строки
    lea si,inputBuffer+2              ;Передаю в si адрес введённой строки 
    lea di,outputBuffer
  metka:
    xor ax,ax
    mov al,[si]
    mov [di],al                       ;Записываем на di(ую) позицию буфера вывода значение по адресу si
    cmp al,32                    ;Сравниваем байт на ходящийся по адресу в si с пробелом
    je space                          ;Если нашли пробел (конец слова)
    call searchVowels                 ;Проверяем символы
    cmp bx,2                           ;Если нашли две гласные рядом
    jc backSearch                          
    mov dx,bx                      ;Передаём в dx значение bx(показываем что в слове есть две гласные)
 
 backSearch:
    inc si                            ;Увеличиваем адрес si и ax
    inc di
    loop metka                        ;Вызываем до тех пор пока строка не закончится 
	
    cmp dx,1                     ;Проверяем регистр dx 
    jc  endSearch               ;Если нет двух подряд идущих гласных выходим 
    lea dx,outputBuffer          ;Передача в dx адреса строки вывода
    call printStr                ;Выводим слово с двумя гласными 
    lea di,outputBuffer
    call clear                   ;Очищаем буфер
    lea dx,endStr           
    call printStr
    jmp endSearch  
  
  space:
    cmp dx,2                     ;Проверяем регистр dx 
    jc  next               ;Если нет двух подряд идущих гласных продолжаем поиск 
    lea dx,outputBuffer          ;Передача в dx адреса строки вывода
    call printStr                ;Выводим слово с двумя гласными 
    lea dx,endStr           
    call printStr                ;Переходим на новую сторку 
  next:
    lea di,outputBuffer
    call clear                   ;Очищаем буфер
    lea di,outputBuffer          ;Передаём начальный адрес в di
    xor dx,dx
    jmp backSearch                   ;Продолжаем поиск
  endSearch:
  pop si
  pop di
  pop dx
  pop cx
  pop bx
  pop ax
ret
search ENDP
 
main:
    mov ax, @data
    mov ds, ax  
    mov es, ax	
    call startCleaning
    call inputStr 
    lea dx,endStr
    call printStr
    call search
    mov ax, 4c00h
    int 21h	
end main

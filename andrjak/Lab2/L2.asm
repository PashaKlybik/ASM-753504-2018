.model small
.stack 256
.data
    errorStr db 'Error!$'
    endLine db 13, 10, '$'
    inputBuffer db '     $'
    outputBuffer db '     $'
    strDiv db '/$'
    strRovno db '=$'
.code
main:
  mov ax, @data
  mov ds, ax
  
  call task

endProgram:
    mov ax, 4c00h
    int 21h
	
errorBlock:
    mov di, offset errorStr
    call printStr
    call printEndLine
    jmp endProgram	
;*************************************** procedures ***************************************
task:
    call inputWord
    jc errorBlock      
    call wordToStr
    mov di, offset outputBuffer      
    call printStr
    call printEndLine
	
    mov di, offset strDiv
    call printStr
    call printEndLine
	
    mov bx,ax
	
    mov di, offset inputBuffer
    call clear
    mov di, offset outputBuffer    ;clear buffers
    call clear
    xor di,di
	
    call inputWord
    jc errorBlock 
    call wordToStr
    mov di, offset outputBuffer
    call printStr
    call printEndLine
	
    xor dx,dx
    xchg ax,bx 
    cmp bx ,0
    jz errorBlock
    div bx 
	
    mov di, offset strRovno
    call printStr
    call printEndLine
	
    mov di, offset inputBuffer
    call clear
    mov di, offset outputBuffer
    call clear
	
    call wordToStr
    mov di, offset outputBuffer
    call printStr
    call printEndLine	
ret
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ cleaning procedure $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;ввод DI - адрес буфера		
clear:
  push cx
  mov cx,6 
  following:            ;Цикл очистки
    mov [di],' '        
    inc di              
    loop following 		
  pop cx
ret	
;################################## output on display ##################################
printStr: 				;передаётся адрес строки в регистре DI
  push ax	
  mov ah,9                
  xchg dx,di  
  int 21h  				
  xchg dx,di 
  pop ax
ret

printEndLine:          ; = \n
  push di
  mov di, offset endLine
  call printStr
  pop di
ret	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WordToStr !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; AX - слово
; DI - буфер для строки (5 символов(65536)).		
wordToStr:
  push ax
  push bx
  push cx
  push dx
  push di
		
  mov di, offset outputBuffer
  xor cx,cx                 ;Обнуление CX
  mov bx,10                 ;В BX делитель (10)
  remainder:                ;Цикл получения остатков от деления
    xor dx,dx               ;Обнуление старшей части двойного слова
    div bx                  ;Деление AX=(DX:AX)/BX, остаток в DX
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
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ input line @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
; Процедура ввода строки c консоли
; вход:  AL - максимальная длина (с символом $) 
; выход: AL - длина введённой строки (не считая символа $)
; DX - адрес строки, заканчивающейся символом $
inputStr:
  push cx                     
  mov cx,ax                   ;Сохранение AX в CX
  mov ah,0Ah                  ;Функция DOS 0Ah - ввод строки в буфер
  mov [inputBuffer],al        ;Запись максимальной длины в первый байт буфера
  mov byte[inputBuffer+1],0   ;Обнуление второго байта (фактической длины)
  mov dx,offset inputBuffer   ;DX = aдрес буфера
  int 21h                     ;Обращение к функции DOS
  mov al,[inputBuffer+1]      ;AL = длина введённой строки
  add dx,2                    ;DX = адрес строки
  mov ah,ch                   ;Востановление ah
  pop cx                      
ret
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ StrToWord @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; вход: AL - длина строки
; DX - адрес строки
; выход: AX - слово (в случае ошибки AX = 0)
; CF = 1 - ошибка
strToWord:
  push cx 
  push dx
  push bx
  push si
  push di
 
  mov si,dx             ;SI = адрес строки
  mov di,10             ;DI = множитель 10 (основание системы счисления)
  xor ah,ah
  mov cx,ax 		    ;CX = счётчик цикла = длина строки
  cmp cx ,0
  jz wordError	        ;Если длина = 0, возвращаем ошибку
  xor ax,ax               
  xor bx,bx               
 
  translation:
    mov bl,[si]            ;Загрузка в BL очередного символа строки
    inc si                 ;Инкремент адреса
    cmp bl,'0'             ;Если код символа меньше кода '0'
    jl wordError           ;возвращаем ошибку
    cmp bl,'9'             ;Если код символа больше кода '9'
    jg wordError           ;возвращаем ошибку
    sub bl,'0'             ;Преобразование символа-цифры в число
    mul di                 ;AX = AX * 10
    jc wordError           ;Если результат больше 16 бит - ошибка
    add ax,bx              ;Прибавляем цифру
    jc wordError           ;Если переполнение - ошибка
    loop translation       
    jmp wordExit           ;Успешное завершение (здесь всегда CF = 0)
 
  wordError:
    xor ax,ax              
    stc                    ;CF = 1 (Возвращаем ошибку) 
  wordExit:
    pop di                  
    pop si
    pop bx
    pop dx
    pop cx
ret	
; Процедура ввода слова с консоли в десятичном виде (без знака)
; выход: AX - слово (в случае ошибки AX = 0)
; CF = 1 - ошибка
inputWord:
    push dx                 
    mov dx,offset inputBuffer
    mov al,6                    ;Ввод максимум 5 символов (65535) + конец строки
    call inputStr               ;Вызов процедуры ввода строки
    call strToWord              ;Преобразование строки в слово (без знака)
    pop dx                  
ret		
end main
.model small
.data
input1 db 0dh,0ah,'Enter first number  : $'
input2 db 0dh,0ah,'Enter second number : $'
output db 0dh,0ah,'Result = $'
output2 db 0dh,0ah,'Error'
buf label byte                   ; прием строки с клавиатуры
max db 20                        ; максимальная длина строки
len db 0                           ; реальная длина введенной строки
string db 20 dup (?)          ; собственно сама строка
 
 .code
 .startup
 
GetFirst:
               lea dx, input1     ; строка приглашения
               call GetNum       ; введем число в AX
               jc GetFirst          ; повторим, если ошибка
               mov bx, ax         ; сохраним
 
GetSecond:
               lea dx, input2
               call GetNum
               cmp ax,0
               jc GetSecond
               mov cx,bx
               mov bx,ax
               mov ax,cx
               cwd                      ;расширяем знаки в DX
               idiv   bx 
 
               lea dx, output     ; строка Sum=
               call PrintNum      ; выведем число
               mov ah, 0           ; ждем нажатие на клавишу
               int 16h
 
               mov ax,4c00h     ; конец работы
               int 21h
 
PrintNum proc               ; вывод числа из ax
    push ax
    mov ah, 9
    int 21h                     ; вывод строки (из dx)
    pop ax
    test ax, ax                ;проверим на знак
    jns FormStr              ;для положительного на вывод
    push ax                    ;для отрицательного выводим - и меняем знак
    mov al,'-'                  ;знак -
    int 29h
    pop ax
    neg ax                      ;меняем знак числа на +, теперь оно положительное
 
FormStr:
       mov bx, 10      ; будем делить на 10
       xor cx, cx         ; счетчик цифр
DivLoop:                 ; цикл получения десятичных разрядов
       xor dx, dx        ; подготовимся для очередного деления
       div bx              ; в dx остаток - очередной десятичный разряд
       push dx           ; сохраним в стеке (от младшего к старшему)
       inc cx              ; посчитаем все это
       test ax, ax       ; проверим на наличие еще десятичных разрядов
       jnz DivLoop     ; продолжим далее
 
PrLoop:                 ; цикл вывода десятичных цифр-символов
        pop ax          ; востановим очередной разряд (от старшего к младшему)
        add al, '0'      ;  символ цифры
        int 29h          ; вывод
        loop PrLoop   ; по всем цифрам
        ret
PrintNum endp

GetNum proc      ; преобразование сроки в число
       push bx
       mov ah, 9
       int 21h        ; приглашение ввести строку
       lea dx, buf
       mov ah, 0ah
       int 21h        ; вводим строку
 
        xor di, di  ; здесь будем накапливать число
        mov cl, 0  ; флаг знака
        mov ch, 0  ; количество цифр
        xor bx, bx  ; очередной знак (для сложения со словом)
        lea si, string ; числовая строка
GetNumLoop:
       lodsb   ; очередная цифра
       cmp al, 0dh ; проверим на разделители
       je NumEndFound ; конец ввода
       cmp al, ' '
       je NumEndFound
       cmp al, 9
       je NumEndFound
       cmp al, '-'; минус может быть олько один и в первой позиции! 
       jne CmpNum
       test ch, ch  ; были ли введены цифры?
       jnz SetC   ; были - ошибка - минус не в первой позиции!
       test cl, cl  ; был ли уже введен минус?
       jnz SetC   ; был - ошибка - можно только один!
       mov cl, 1  ; пометим отрицательное число
       jmp GetNumLoop ; на анализ следующего символа
 CmpNum:
       cmp al, '0'  ; цифра?
       jb SetC   ; фигушки - не цифра! 
       cmp al, '9'
       ja SetC
       inc ch  ; считаем цифры
       and al, 0fh  ; цифра -> число (30h-39h -> 0-9)
       mov bl, al  ; сохраним (bh=0)
       mov ax, 10  ; умножим на 10 
       imul di  ; предыдущее значение
       test dx, dx  ; больше cлова - ошибка!
       jnz SetC 
       add ax,bx
       jc SetC  ; больше  слова - ошибка!
       js SetC  ; больше 32767 - ошибка!
       mov di, ax  ; сэйвим
       jmp GetNumLoop ; на анализ следующего символа
 
NumEndFound:   ; встретили разделитель
         test ch, ch  ; что-то было?
         jz SetC   ; не было числа (например, был введен один минус)
         test cl, cl  ; число отрицательное?
         jz GetNumRet
         neg di  ; дополнительный код отрицательного числа
GetNumRet:
        mov ax, di  ; результат сэйвим в ax
        pop bx
        clc   ; все гут
        ret
SetC :
        pop bx
        stc   ; ошибка
        ret
GetNum endp 
end 
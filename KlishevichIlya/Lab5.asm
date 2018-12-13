model small
.486
LOCALS @@
.stack  256
.data
 
Rows            equ     4                ;максимальное количество строк
Columns         equ     4                ;максимальное количество столбцов
iSize           equ     Rows*Columns     ;максимальный размер матрицы
m               dw      Rows             ;текущее количество строк
n               dw      Columns          ;текущее количество столбцов
Matrix          dw      iSize dup(?)     ;матрица
asCR_LF         db      0dh, 0ah, '$'   ;"перевод строки"
asTitle0        db      'Input matrix', '$'
asTitle1        db      'Current matrix', '$'
asTitle2        db      'Result matrix', '$'
asPrompt1       db      'a[ ', '$'      ;строка приглашения
asPrompt2       db      ',  ', '$'
asPrompt3       db      ']= ', '$'
 
kbMaxLen        equ     6+1             ;буфер ввода с клавиатуры 
kbInput         db      kbMaxLen, 0, kbMaxLen dup(0)
.code
; преобразования строки в число
; на входе:
; ds:[si] - строка с числом
; ds:[di] - адрес числа
; на выходе
; ds:[di] - число
; CY - флаг переноса (при ошибке - установлен, иначе - сброшен)
Str2Num PROC
        push    ax
        push    bx
        push    cx
        push    dx
        push    ds
        push    es
        push    si
 
        push    ds
        pop     es
 
        mov     cl, ds:[si]
        xor     ch, ch
        inc     si
        mov     bx, 10
        xor     ax, ax
 
        ;если в строке первый символ '-'
        ; - перейти к следующему
        ; - уменьшить количество рассматриваемых символов
        cmp     byte ptr [si], '-'
        jne     @@Loop
        inc     si
        dec     cx
@@Loop:
        mul     bx         ; умножаем ax на 10 ( dx:ax=ax*bx )
        mov     [di], ax   ; игнорируем старшее слово
        cmp     dx, 0      ; проверяем, результат на переполнение
        jnz     @@Error
 
        mov     al, [si]   ; Преобразуем следующий символ в число
        cmp     al, '0'
        jb      @@Error
        cmp     al, '9'
        ja      @@Error
        sub     al, '0'
        xor     ah, ah
        add     ax, [di]
        jc      @@Error    ; Если сумма больше 65535
        cmp     ax, 8000h
        ja      @@Error
        inc     si
        loop    @@Loop
        pop     si         ;проверка на знак
        push    si
        inc     si
        cmp     byte ptr [si], '-'
        jne     @@Check    ;если должно быть положительным
        neg     ax         ;если должно быть отрицательным
        jmp     @@StoreRes
@@Check:                   ;дополнительная проверка, когда при вводе положительного числа получили отрицательное
       or       ax, ax     ;
       js       @@Error
@@StoreRes:                ;сохранить результат
        mov     [di], ax
        clc
        pop     si
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
@@Error:
        xor     ax, ax
        mov     [di], ax
        stc
        pop     si
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
Str2Num ENDP
 
; выводит число из регистра AX на экран
; входные данные:
; ax - число для отображения
Show_AX proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
 
        mov     cx, 10
        xor     di, di          ; di - кол. цифр в числе
 
        ; если число в ax отрицательное, то
        ;1) напечатать '-'
        ;2) сделать ax положительным
        or      ax, ax
        jns     @@Conv
        push    ax
        mov     dx, '-'
        mov     ah, 2           ; ah - функция вывода символа на экран
        int     21h
        pop     ax
        neg     ax
@@Conv:
        xor     dx, dx
        div     cx              ; dl = num mod 10
        add     dl, '0'         ; перевод в символьный формат
        inc     di
        push    dx              ; складываем в стэк
        or      ax, ax
        jnz     @@Conv
        ; выводим из стэка на экран
@@Show:
        pop     dx              ; dl = очередной символ
        mov     ah, 2           ; ah - функция вывода символа на экран
        int     21h
        dec     di              ; повторяем пока di<>0
        jnz     @@Show
 
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
Show_AX endp
 
; На входе
;m     - количество строк
;n     - количество столбцов
;ds:dx - адрес матрицы
ShowMatrix PROC FAR
        pusha
        mov     si, 0  ; строка
        mov     di, 0  ; столбец
        mov     bx, dx
 
@@ShowRow:
        mov     ax, [bx]
        call    Show_AX
        mov     ah,     02h
        mov     dl,     ' '
        int     21h
        add     bx,     2
        inc     di
        cmp     di, n
        jb      @@ShowRow
 
        mov     dx, OFFSET asCR_LF
        mov     ah, 09h
        int     21h
        mov     di, 0
        inc     si
        cmp     si, m
        jb      @@ShowRow
        popa
        ret
ShowMatrix ENDP
 
; На входе
;ds:dx - адрес матрицы
InputMatrix PROC
        pusha
        mov     bx,     dx ;bx - адрес очередного элемента матрицы
        ;Вывод на экран приглашения ввести матрицу
        mov     ah, 09h
        mov     dx, OFFSET asTitle0
        int     21h
 
        mov     ah, 09h
        mov     dx, OFFSET asCR_LF
        int     21h
        mov     si, 1  ; строка (индекс)
        mov     di, 1  ; столбец (индекс)
@@InpInt:
        ;вывод на экран приглашения 'a[ 1, 1]='
        lea     dx, asPrompt1
        mov     ah, 09h
        int     21h
        mov     ax,     si
        call    Show_AX
        lea     dx, asPrompt2
        mov     ah, 09h
        int     21h
        mov     ax,     di
        call    Show_AX
        lea     dx, asPrompt3
        mov     ah, 09h
        int     21h
        ;Ввод строки
        mov     ah, 0ah
        mov     dx, OFFSET kbInput
        int     21h
        ;Преобразование строки в число
        push    di
        push    si
        mov     si, OFFSET kbInput+1
        mov     di, bx
        call    Str2Num
        pop     si
        pop     di
        jc      @@InpInt  ; если ошибка преобразования - повторить ввод
        ;проверка введенного числа на количество разрядов не менее 2
        cmp     word ptr [bx],  10
        jge     @@Ok
        cmp     word ptr [bx],  -10
        jle     @@Ok
        jmp     @@InpInt
@@Ok:
        ;на экране - перейти к следующей строке
        mov     dx, OFFSET asCR_LF
        mov     ah, 09h
        int     21h
        ;перейти к следующему элементу матрицы
        add     bx,     2
        inc     di
        cmp     di, n
        jbe     @@InpInt
        mov     di, 1
        inc     si
        cmp     si, m
        jbe     @@InpInt
        popa
        ret
InputMatrix ENDP
 
Main    PROC    FAR
        mov     dx, @data
        mov     ds, dx
 
        mov     dx, OFFSET Matrix
        call    InputMatrix
        mov     ah, 09h
        mov     dx, OFFSET asTitle1
        int     21h
        mov     ah, 09h
        mov     dx, OFFSET asCR_LF
        int     21h
        mov     dx, OFFSET Matrix
        call    ShowMatrix
 
        ;поиск строки с минимальным значением суммы элементов
        mov     ax,     7FFFh   ;минимальное значение суммы в матрице
        mov     di,     0       ;номер строки с минимальной суммой
        mov     cx,     m
        lea     si,     Matrix
@@ForI:                         ;цикл по строкам
        mov     bx,     0       ;сумма элементов строки
        push    cx
        mov     cx,     n       ;количество элементов в строке
       @@ForJ:
                add     bx,     [si]
                add     si,     2
               loop    @@ForJ
        pop     cx
 
        cmp     ax,     bx
        jle     @@Next
        mov     ax,     bx
        mov     di,     m       ;di - номер строки с минимальной суммой
        sub     di,     cx
@@Next:
        loop    @@ForI
        ;замена элементов строки с минимальной суммой элементов, на нули
        lea     bx,     Matrix
        mov     ax,     n
        mul     di
        shl     ax,     1
        add     bx,     ax
        mov     cx,     n
        mov     ax,     0
@@@ForJ:
        mov     [bx],   ax
        add     bx,     2
        loop    @@@ForJ
        ;Вывод результатов на экран
        mov     ah, 09h
        mov     dx, OFFSET asTitle2
        int     21h
        
        mov     ah, 09h
        mov     dx, OFFSET asCR_LF
        int     21h
        
        mov     dx, OFFSET Matrix
        call    ShowMatrix
        mov     ax, 4c00h
        int     21h
Main    ENDP
END     Main

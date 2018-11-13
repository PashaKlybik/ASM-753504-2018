.MODEL  Small
.STACK  100h 
.DATA
 
KeyBuf  db      7, 0, 7 dup(0)      ;max,len,string,CR(0dh)
CR_LF   db      0Dh, 0Ah, '$'
 
InDividend      db      'enter the dividend: ', '$'
InDivider       db      'enter the divider: ', '$'
TextDividend    db      'dividend =  ', '$'
TextDivider     db      'divider =  ', '$'
TextResult      db      'result =  ', '$'
Error01         db      'eror',0Dh, 0Ah, '$'
Dividend        dw      ?
Divider         dw      ?
Result          dw      ?
Sing            dw      0
 
.CODE
 
; выводит число в регистре AX на экран
; входные данные:
; cx - система счисления (не больше 10)
; ax - число для отображения
Show_ax PROC
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
 
        mov     cx, 10          ; cx - основание системы счисления
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
Show_ax ENDP
 
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
        jb      @@Error    ;Ниже
        cmp     al, '9'
        ja      @@Error    ;Выше
        sub     al, '0'
        xor     ah, ah
        add     ax, [di]
        jc      @@Error    ; Если сумма больше 65535
        cmp     ax, 8000h
        ja      @@Error
        inc     si
 
        loop    @@Loop     ;Управление циклом
 
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
 
Main    PROC    FAR
        mov     ax, @DATA
        mov     ds, ax
        mov     es, ax
 
        ; ввод числа с клавиатуры (строки)
        lea     dx, InDividend
        mov     ah, 09h
        int     21h
 
        mov     ah, 0Ah
        mov     dx, offset KeyBuf
        int     21h
 
        ; перевод строки (на новую строку)
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h
 
        ; преобразование строки в число
        lea     si, KeyBuf+1
        lea     di, Dividend
        call    Str2Num
 
        ; проверка на ошибку
        jnc     @@NoError
 
        ; если есть ошибка ввода - напечатать сообщение об ошибке
        lea     dx, Error01
        mov     ah, 09h
        int     21h
        jmp     @@Exit
 
        ; если нет ошибки ввода - напечатать число
@@NoError:
        ; в десятичном представлении
        lea     dx, TextDividend  
        mov     ah, 09h
        int     21h
 
        mov     ax, Dividend
        mov     cx, 10
        call    Show_ax
 
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h
;1111111111111111111111111111111111111111111111


        ; ввод числа с клавиатуры (строки)
        lea     dx, InDivider
        mov     ah, 09h
        int     21h
 
        mov     ah, 0Ah
        mov     dx, offset KeyBuf
        int     21h
 
        ; перевод строки (на новую строку)
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h
 
        ; преобразование строки в число
        lea     si, KeyBuf+1
        lea     di, Divider
        call    Str2Num
 
        ; проверка на ошибку
        jnc     @@NoError2
 
        ; если есть ошибка ввода - напечатать сообщение об ошибке
        lea     dx, Error01
        mov     ah, 09h
        int     21h
        jmp     @@Exit
 
        ; если нет ошибки ввода - напечатать число
@@NoError2:
        ; в десятичном представлении
        lea     dx, TextDivider
        mov     ah, 09h
        int     21h
 
        mov     ax, Divider
        mov     cx, 10
        call    Show_ax
 
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h

        ;деление
        mov dx, 0  
        mov ax, Dividend
        cmp ax, 0
        JG DIVER
        neg ax
        add Sing, 1
        DIVER:
        mov bx, Divider
        cmp bx, 0
        JG DIV1
        neg bx
        add Sing, 1

        DIV1:
        div bx
        mov si, Sing
        cmp si, 1
        JNZ RES
        neg ax
        
        RES:     
        mov Result,ax

        lea     dx, TextResult
        mov     ah, 09h
        int     21h
 
        mov     ax, Result
        mov     cx, 10
        call    Show_ax

        ;переход на новую сктроку
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h
 
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h
        ; выход
@@Exit:
        ; ожидание нажатия любой клавиши
        mov     ah, 01h
        int     21h
 
        mov     ax, 4c00h
        int     21h
Main    ENDP
 

 
        END     Main
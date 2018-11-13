.MODEL  Small
.STACK  100h 

.DATA 
KeyBuf          db      6, 0, 6 dup(0)      ;max,len,string,CR(0dh)  
CR_LF           db      0Dh, 0Ah, '$'       ;переход на след. строку


InDividend      db      'enter the dividend: ', '$'
InDivider       db      'enter the divider: ', '$'
TextDividend    db      'dividend =  ', '$'
TextDivider     db      'divider =  ', '$'
TextResult      db      'result =  ', '$'
Error01         db      'eror',0Dh, 0Ah, '$'
Dividend        dw      ?
Divider         dw      ?
Result          dw      ?
 
.CODE
; выводит число в регистре AX на экран
; входные данные:
; cx - система счисления 
; ax - число для отображения
Show_ax PROC
    xor     di, di      ; di - кол. цифр в числе, обнуление
    mov     cx, 10
    
@@Conv:
    xor     dx, dx
    div     cx              
    add     dl, '0'     ; перевод в символьный формат      
    inc     di
    push    dx              
    or      ax, ax      ; складываем в стэк
    jnz     @@conv      ;обнуление первых 4 чисел
    
@@Show:
    pop     dx          ; dl = очередной символ     
    mov     ah, 2       ; ah - функция вывода символа на экран    
    int     21h
    dec     di          ; повторяем пока di<>0   
    jnz     @@show
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
    push    ds
    pop     es 
    mov     cl, ds:[si]
    xor     ch, ch
    inc     si         ;+1
    mov     bx, 10
    xor     ax, ax
    
@@Loop:
    mul     bx         ; умножаем ax на 10 ( dx:ax=ax*bx )
    mov     [di], ax   ; игнорируем старшее слово
    cmp     dx, 0      ; проверяем, результат на переполнение
    jnz     @@Error
    mov     al, [si]   ; Преобразуем следующий символ в число
    cmp     al, '0'
    jb      @@Error    ;ниже
    cmp     al, '9'
    ja      @@Error    ;выше
    sub     al, '0'
    xor     ah, ah
    add     ax, [di]
    jc      @@Error    ; Если сумма больше 65535 
    inc     si
    loop    @@Loop     ;Управление циклом
    mov     [di], ax
    clc                ;флаг CF-флаг переноса
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
    lea     dx, InDividend     ; ввод числа с клавиатуры (строки)
    mov     ah, 09h
    int     21h
    mov     ah, 0Ah
    mov     dx, offset KeyBuf
    int     21h
    lea     dx, CR_LF          ; перевод строки (на новую строку)
    mov     ah, 09h
    int     21h
    lea     si, KeyBuf+1
    lea     di, Dividend
    call    Str2Num            ; преобразование строки в число
    jnc     @@NoError          ; проверка на ошибку
    lea     dx, Error01        ; если есть ошибка ввода - напечатать сообщение об ошибке
    mov     ah, 09h
    int     21h
    jmp     @@Exit

@@NoError:                     ; если нет ошибки ввода - напечатать число
    lea     dx, TextDividend   ; ввод числа с клавиатуры (строки)
    mov     ah, 09h
    int     21h
    mov     ax, Dividend
    call    Show_ax
    lea     dx, CR_LF          ; перевод строки (на новую строку)
    mov     ah, 09h
    int     21h
    lea     dx, InDivider
    mov     ah, 09h
    int     21h
    mov     ah, 0Ah
    mov     dx, offset KeyBuf
    int     21h
    lea     dx, CR_LF
    mov     ah, 09h
    int     21h
    lea     si, KeyBuf+1       ; преобразование строки в число
    lea     di, Divider
    call    Str2Num            ; проверка на ошибку
    jnc     @@NoError2         ; если есть ошибка ввода - напечатать сообщение об ошибке
    lea     dx, Error01
    mov     ah, 09h
    int     21h
    jmp     @@Exit
    
@@NoError2:                    ; если нет ошибки ввода - напечатать число
    lea     dx, TextDivider
    mov     ah, 09h
    int     21h
    mov     ax, Divider
    call    Show_ax
    lea     dx, CR_LF
    mov     ah, 09h
    int     21h
        
     ;деление
    mov     dx,0  
    mov     ax,Dividend
    mov     bx,Divider        
    div     bx 
    mov     Result,ax
    lea     dx, TextResult
    mov     ah, 09h
    int     21h 
    mov     ax, Result
    call    Show_ax
    lea     dx, CR_LF            ;переход на новую сктроку
    mov     ah, 09h
    int     21h 
    lea     dx, CR_LF
    mov     ah, 09h
    int     21h
        
@@Exit:                          ; выход
    mov     ah, 01h              ; ожидание нажатия любой клавиши
    int     21h
    mov     ax, 4c00h
    int     21h
    
Main    ENDP
END     Main

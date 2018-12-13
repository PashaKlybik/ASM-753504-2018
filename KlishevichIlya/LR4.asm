LOCALS
.model small
.stack 100h
.data
        kbdBuffer       db      80, ?, 80 dup(0)             ;буфер клавиатуры для ввода строки
        CrLf            db      0Dh, 0Ah, '$'                ;символы перевода строки
        Delimiter       db      ' '                          ;разделитель слов в строке
        String          db      ?, 80 dup(0)                 ;строка в формате длина, символы
        WordForDelete   db      ?, 80 dup(0)                 ;строка в формате длина, символы
        PromptStr       db      'Enter string:', 0Dh, 0Ah, '$'
        PromptWord      db      'Enter word:', 0Dh, 0Ah, '$'
        msgNewString    db      'Result String: ', 0Dh, 0Ah, '$'
.code
main    proc
        mov     ax,     @data
        mov     ds,     ax
        mov     ah,     09h           ;ввод строки
        lea     dx,     PromptStr
        int     21h
        lea     dx,     String
        call    GetStr
        mov     ah,     09h           ;ввод слова для удаления из строки
        lea     dx,     PromptWord
        int     21h
        lea     dx,     WordForDelete
        call    GetStr
 
        ;цикл выделения слов и сравнения их с удаляемым словом
        mov     cx,     0           ;cx - длина строки
        mov     cl,     String
        jcxz    @@Break            ;если строка пустая - завершить программу
        mov     dx,     0          ;dx - длина удаляемого слова
        mov     dl,     WordForDelete
        or      dx,     dx
        jz      @@Break
        lea     si,     String+1    ;si - адрес первого символа строки
        mov     di,     si          ;di - адрес начала слова в строке
@@For:
        lodsb                           ;чтение очередного символа в al, увеличение si на 1
        cmp     al,     Delimiter       ;очередной символ - разделитель слов?
        je      @@NewWord               ;да - перейти к строкам, выполняющим сравнение с образцом
        loop    @@For           ;
        ;обработка последнего слова в строке
        inc     si                      ;для проверки последнего слова
@@NewWord:
        pushf
        cld
        ;сравнить длины слов
        mov     ax,     si
        sub     ax,     di
        dec     ax
        cmp     ax,     dx
        jne     @@Next
        ;при равенстве - сравнить слова
        push    si
        push    di
        push    cx
        push    es
        push    ds
        pop     es
        mov     cx,     dx
        lea     si,     WordForDelete+1
        repe    cmpsb
        pop     es
        pop     cx
        pop     di
        pop     si
        jne     @@Next
        ;при совпадении слов - удалить из строки слово
        jcxz    @@SkipCopy
        push    cx
        push    si
        push    di
        push    es
        push    ds
        pop     es
        rep     movsb
        pop     es
        pop     di
        pop     si
        pop     cx
        ;после переноса, просмотр продолжать с 1-го символа удалённого слова
        mov     si,     di
        dec     [String] ;удаляется не только слово, но и разделитель
@@SkipCopy:
        sub     [String], dl ;коррекция длины строки
@@Next:
        popf
        mov     di,     si
        jcxz    @@Break
        loop    @@For
@@Break:
        ;вывод результатов
        mov     ah,     09h
        lea     dx,     msgNewString
        int     21h
        call    ShowString
 
        mov     ah,     09h
        lea     dx,     CrLf
        int     21h
 
@@Exit:
        mov     ax,     4C00h   ;завершение программы
        int     21h
main    endp
 
      ;Чтение строки с клавиатуры
      ;на входе:
      ;  ds:dx - адрес строки
      ;на выходе:
      ;  ds:dx - строка в формате (длина, символы)
GetStr  proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        pushf
        push    es
 
        mov     bx,     dx      ;сохранение адреса строки
        mov     ah,     0Ah     ;чтение в буфер из клавиатуры
        lea     dx,     kbdBuffer
        int     21h
        mov     ah,     09h     ;перевод строки
        lea     dx,     CrLf
        int     21h
        ;копирование из буфера в переменную строки
        mov     cx,     0
        mov     cl,     [kbdBuffer+1]
        ;jcxz    @@SkipCopy
        inc     cx
        push    ds
        pop     es
        lea     si,     kbdBuffer+1
        mov     di,     bx
        cld
        rep     movsb
        mov     byte ptr [di],  '$'  ;добавление признака конца строки за последним символом
@@SkipCopy:
        pop     es
        popf
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
GetStr  endp
 
ShowString      proc
.386
        pusha
        mov     cx,     0
        mov     cl,     String
        lea     si,     String
        add     si,     cx
        mov     byte ptr [si+1],'$'
 
        mov     ah,     09h
        lea     dx,     String+1
        int     21h
 
        mov     ah,     09h
        lea     dx,     CrLf
        int     21h
        popa
        ret
ShowString      endp
end     main

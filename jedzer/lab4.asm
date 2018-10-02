;Лабораторная работа 4
;Необходимо ввести строку с клавиатуры, сделать ее обработку согласно заданию и показать результат на экране. 
;При выполнении работы необходимо использовать хотя бы одну из команд для работы с цепочками
;(http://kit.znu.edu.ua/eDoc/Arch/assembl/guide/Lesson/Lesson11/Les_11.htm). 
;Считается, что строка состоит из слов, разделенных произвольным числом
;пробелов (за исключением вариантов 5, 6, 8, 9).
;Пробелы также могут располагаться перед первым словом и после последнего слова.

;12) Удалить из строки все слова, не являющиеся палиндромами.

model small
stack 256
dataseg
    string db 201 dup(?) ;200 + 1 для $
codeseg

;reads line and writes it to string data + adds '$'
;saves ax, si
ReadLine proc
    push ax
    push si
        xor si, si
        ReadLoop:
            mov ah, 01h             
            int 21h
            cmp al, 13
            je finish
            mov string[si], al
            inc si
            cmp si, 200
            je finish
        jmp ReadLoop
        finish:
            mov string[si], ' '
            inc si
            mov string[si], '$'
    pop si
    pop ax
    ret
ReadLine endp

;procedure used to display line written in data::string
;saves ax, si
PrintLine proc
    push ax
    push si
        lea dx, string
        mov ah, 09h
        int 21h
    pop si
    pop ax
    ret
PrintLine endp

;procedure used to display new line symbol
;saves ax and dx
NewLine proc
    push ax
    push dx
        mov dx, 10
        mov ah, 2   
        int 21h 
        mov dx, 13
        mov ah, 2   
        int 21h 
    pop dx
    pop ax
    ret
NewLine endp

;procedure used to delete polindroms in data::string
;saves ax, si, di, cx, dx, bx
EditLine proc
    push ax
    push si
    push di
    push cx
    push dx
    push bx
    ;here we count amount of symbols in the word or finish program
    CountinueScan:
        xor cx, cx
        xor ah, ah
        mov bx, si
        CountTillSpace:
            mov dx, si
            dec dx
            lods string
            cmp al, ' '
            je IsItPolindrom
            cmp al, '$'
            je FinishProc
            inc cl
            jmp CountTillSpace

    IsItPolindrom:
        ;at this point cx represents amount of symbols in the word
        ;si - position of the last symbol of the word + 1 (space after symbol)
        mov si, bx
        mov cx, dx
        ;check if word is polyndrom
        BackWards:
            mov di, cx
            lods string
            cmp al, string[di]
            ;if not we delete it
            jne DeleteWord
            cmp si, cx
            jae FrenchFin
            dec cx
        jmp BackWards
        FrenchFin:
        inc si
        jmp CountinueScan
    ;god damn it
    ;...some shit {wordToDelete} some other shit...
    ;we move some other shit in place of {wordToDelete}
    ;symbol by symbol
    ;so we get: 
    ;...some shit some other shit...$ some other shit...
    DeleteWord:
        mov cx, bx
        mov si, dx
        add si, 2
        xor ah, ah
        MoveString:
            lods string
            mov di, cx
            mov string[di], al
            inc cx
            cmp al, '$'
            jne MoveString
        mov si, bx
        jmp CountinueScan
    FinishProc:
    pop bx
    pop dx
    pop cx
    pop di
    pop si
    pop ax
    ret
EditLine endp

main:
    mov ax, @data
    mov ds, ax

    call ReadLine
    call NewLine
    call EditLine
    call PrintLine
    call NewLine

    mov ah, 4ch
    int 21h
end main

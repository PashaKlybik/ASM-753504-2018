;   Пятое задание посвящается двухмерным массивам. Каждый из них является прямоугольным, 
;если не указано обратное (количество строк может быть отличным от количества столбцов).
;Для задания массива необходимо ввести количество строк, затем количество столбцов и затем все элементы. 
;Для ввода и вывода чисел использовать функции из 3 работы (работа со знаковыми числами), для простоты считать, 
;что ввод всегда корректный (т.е. можно убрать все проверки на некорректность  из функций). 
;При выводе на экран элементы одного столбца матрицы необходимо показывать друг под другом (разделять элементы символом табуляции).
;   Дополнительное задание на более высокую оценку: сделать ввод исходных матриц из файла, 
;вывод результата в файл (название файлов можно задать в сегменте данных, например "input.txt" "output.txt").
;   Крайне желательно сделать дополнительное задание, чтобы при сдаче не вводить вручную кучу чисел в консоли. 
;Также желательно предусмотреть возможность завершения ввода числа не только нажатием клавиши enter (0Dh), но и клавиши space (20h).

;2) Вводятся размерности N и M, матрица размерности NxM и число A. Необходимо обнулить в матрице все элементы, большие числа A.

model small
stack 256
dataseg
    options db "What do you want to do?", 10, 13, "1 - Enter matrix from keyboard", 10, 13, "!1 - Read matrix from file", 10, 13, '$' 
    FileNotFoundError db "File not found!", 10, 13, '$'
    enterAgain db 10, 13, "Enter again", 10, 13, '$'
    messageA db "Enter A to compare with: ", 10, 13, '$'
    messageCol db "Enter amount of columns: ", 10, 13, '$'
    messageRow db "Enter amount of rows: ", 10, 13, '$'
    
    input db "input.txt", 0
    output db "output.txt", 0
    
    inHandler dw ?

    array dw 6555 dup(?)
    buf db 1000 dup(" ")
    buf2 dw 0

    ten dw 10
    Rows dw ?
    Columns dw ?
    A dw ?
codeseg

;---------------------------USED IN BOTH METHODS--------------------------------------------
;first procedure. Used for asking user how he want's to read array (from keyboard of file)
;saves dx. Changes ax to 1 if '1' was typed
AskForOption proc
    push dx
    lea dx, options
    mov ah, 9
    int 21h
    mov ah, 01h             
    int 21h
    cmp al, '1'
    jne AskReturn
    mov ax, 1
    AskReturn:
    pop dx
    ret
AskForOption endp
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
;procedure used to display new line symbol
;saves ax and dx
PrintSpace proc
 push ax
    push dx
        mov dx, ' '
        mov ah, 2   
        int 21h 
    pop dx
    pop ax
    ret
PrintSpace endp
;prints double array taken from data::array
;saves si, si, cx
PrintDoubleArray proc
    push si
    push di
    push cx
    xor di, di
    xor cx, cx
    FirstFor:
        xor si, si
        SecondFor:
            push di
            add di, si
            push ax
            mov ax, 2
            mul di
            mov di, ax
            pop ax
            mov ax, array[di]
            pop di
            call OutInt
            call PrintSpace
            inc si
            cmp si, Columns
        jne SecondFor
        add di, Columns
        call NewLine
        inc cx
        cmp cx, Rows 
    jne FirstFor   
    pop cx
    pop di
    pop si
    ret
PrintDoubleArray endp
;number input porcedure. Reads number from console and saves it in AX
;saves bx, cx, si 
EnterInt proc
    push bx
    push cx
    push si
    start1:
    xor si, si
    mov cx, 0
        mov ah, 01h             
        int 21h
        cmp al, '-'
        jne positiveCheck
        inc si
    ReadLoop:
        mov ah, 01h             
        int 21h
        positiveCheck:
        cmp al, 13
        je finish
        cmp al, ' '
        je finish
        cmp al, '0'
        jl intErr
        cmp al, '9'
        jg intErr
        xor ah, ah
        sub ax, '0'
        mov cx, ax
        mov ax, bx
        mul ten
        cmp si, 0
        jne IsNegative
            add ax, cx
            mov bx, ax
            cmp ax, 0
            jl intErr
        jmp ReadLoop
        IsNegative:
            sub ax, cx
            mov bx, ax
            cmp ax, 0
            jg intErr
        jmp ReadLoop
    finish:
    mov ax, bx
    pop si
    pop cx
    pop bx
    ret
    intErr:
        lea dx, enterAgain
        mov ah, 09h
        int 21h 
        jmp start1
EnterInt endp
;number output porcedure. Gets number from ax and outputs it in console
;saves bx, cx, dx 
OutInt proc
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
    cmp ax, 0
    jge SplitAndPush
        push ax
        mov dx, '-'
        mov ah, 2   
        int 21h
        pop ax
        neg ax
    SplitAndPush:
        xor dx, dx
        div bx
        push dx
        inc cx
        test ax, ax
        jnz SplitAndPush
    PopAndDisplay:
        pop ax
        add ax, '0'
        mov dx, ax
        mov ah, 2
        int 21h
    loop PopAndDisplay
    pop dx
    pop cx
    pop bx
    ret
OutInt endp
;compares all elements of array with A and makes element zero
;saves si, di, cx
CmpAndKILL proc
    push si
    push di
    push cx
    push bx
    xor di, di
    xor cx, cx
    FirstFor2:
        xor si, si
        SecondFor2:
            mov bx, A
            push di
            add di, si
            push ax
            mov ax, 2
            mul di
            mov di, ax
            pop ax
            cmp array[di], bx
            jnae Continue
                mov array[di], 0
            Continue:
            pop di
            inc si
            cmp si, Columns
        jne SecondFor2
        add di, Columns
        inc cx
        cmp cx, Rows 
    jne FirstFor2  
    pop bx 
    pop cx
    pop di
    pop si
    ret
CmpAndKILL endp
;displays message that is in dx
;saves ax
Message proc
    push ax
    mov ah, 09h
    int 21h
    pop ax
    ret
Message endp
;---------------------------KEYBOARD METHODS--------------------------------------------
;read array from keyboard
ReadFromKeyboard proc
    push si
    push di
    push cx
    xor di, di
    xor cx, cx
    FirstForKey:
        xor si, si
        SecondForKey:
            push di
            add di, si
            push ax
            mov ax, 2
            mul di
            mov di, ax
            pop ax
            call EnterInt
            mov array[di], ax
            pop di
            inc si
            cmp si, Columns
        jne SecondForKey
        add di, Columns
        call NewLine
        inc cx
        cmp cx, Rows 
    jne FirstForKey   
    pop cx
    pop di
    pop si
    ret
ReadFromKeyboard endp
;reads array dementions and A
;saves ax, dx
ReadArraySizeAndComparisonNumber proc
    push ax
    push dx
    lea dx, messageA
    call Message
    call EnterInt
    mov A, ax
    lea dx, messageCol
    call Message
    call EnterInt
    mov Columns, ax
    lea dx, messageRow
    call Message
    call EnterInt
    mov Rows, ax
    pop dx
    pop ax
    ret
ReadArraySizeAndComparisonNumber endp
;intermidiate procedure (keyboard)
FromKeyboard proc
    call ReadArraySizeAndComparisonNumber
    call ReadFromKeyboard
    call CmpAndKILL
    call PrintDoubleArray
    ret 
FromKeyboard endp
;---------------------------FILE METHODS--------------------------------------------
;reads from file array dementions and A
;saves ax, dx
FileReadArraySizeAndComparisonNumber proc
    lea dx, input           ; имя файла
    mov ah, 3dh             ; функция создания и открытия файлов
    mov al, 0               ; режим=чтение
    int 21h                 ; выполнить
    mov inHandler, ax 

        call ReadIntFromFile
        mov A, ax
        call ReadIntFromFile
        mov Columns, ax
        call ReadIntFromFile
        mov Rows, ax
        call ReadArrayFromFile
    mov ah, 3eh
    mov bx, inHandler ; дескриптор исходного файла
    int 21h
    ret
FileReadArraySizeAndComparisonNumber endp
;read array from file
ReadArrayFromFile proc
    push si
    push di
    push cx
    xor di, di
    xor cx, cx
    FirstForSym:
        xor si, si
        SecondForSym:
            push di
            add di, si
            push ax
            mov ax, 2
            mul di
            mov di, ax
            pop ax
            call ReadIntFromFile
            mov array[di], ax
            pop di
            inc si
            cmp si, Columns
        jne SecondForSym
        add di, Columns
        inc cx
        cmp cx, Rows 
    jne FirstForSym   
    pop cx
    pop di
    pop si
    ret
ReadArrayFromFile endp
;reads from file A, Colums, Rows and array from input.txt
;saves
ReadIntFromFile proc
    push si
    push di
    push bx
    push cx
    push dx
    mov buf2, 0
    xor si, si
    mov cx, 0
        mov ah, 3fh             ; читаем массив байтов из файла
        mov bx, inHandler       ; дескриптор файла
        lea dx, buf             ; адрес входного буфера
        mov cx, 1               ; макс кол-во байтов для чтения
        int 21h
        cmp ax, cx              ; если достигнуть EoF или ошибка чтения
        jnz finish1             ; то закрываем файл закрываем файл
        cmp buf, '-'
        jne positiveCheck1
        inc si
    FileReadLoop:
        mov ah, 3fh             ; читаем массив байтов из файла
        mov bx, inHandler       ; дескриптор файла
        lea dx, buf             ; адрес входного буфера
        mov cx, 1               ; макс кол-во байтов для чтения
        int 21h
        cmp ax, cx              ; если достигнуть EoF или ошибка чтения
        jnz finish1             ; то закрываем файл закрываем файл
        positiveCheck1:
        mov al, buf
        cmp al, 13
        je finish1
        cmp al, ' '
        je finish1
        xor ah, ah
        sub ax, '0'
        mov cx, ax
        mov ax, buf2
        mul ten
        cmp si, 0
        jne IsNegative1
            add ax, cx
            mov buf2, ax
        jmp FileReadLoop
        IsNegative1:
            sub ax, cx
            mov buf2, ax
        jmp FileReadLoop
    finish1:
    mov ax, buf2
    pop dx
    pop cx
    pop bx
    pop di
    pop si
    ret
ReadIntFromFile endp
;saves new array in output.txt
; saves 

OutFileInt proc
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
    cmp ax, 0
    jge SplitAndPushFile
        mov buf2, '-'
        call PrintFile
        neg ax
    SplitAndPushFile:
        xor dx, dx
        div bx
        push dx
        inc cx
        test ax, ax
        jnz SplitAndPushFile
    PopAndDisplayFile:
        pop ax
        add ax, '0'
        push cx
        push bx
        mov buf2, ax
        call PrintFile
        pop bx
        pop cx
    loop PopAndDisplayFile
    pop dx
    pop cx
    pop bx
    ret
OutFileInt endp

PrintFile proc
    push dx
    push cx
    push bx
    mov bx, inHandler       ;Дескриптор файла
    mov ah, 40h             ;Функция DOS 40h (запись в файл)
    mov dx, buf2            ;Адрес буфера с данными
    mov cx, 1               ;Размер данных
    int 21h                 ;Обращение к функции DOS
    pop bx
    pop cx
    pop dx
    ret
PrintFile endp

OpenFileForWrite proc
    push dx
    push cx
    push bx
    mov ah, 3Ch             ;Функция DOS 3Ch (создание файла)
    lea dx, output          ;Имя файла
    xor cx, cx              ;Нет атрибутов - обычный файл
    int 21h                 ;Обращение к функции DOS
    mov inHandler, ax 
    pop bx
    pop cx
    pop dx
    ret
OpenFileForWrite endp

CloseFileForWrite proc
    push ax
    push bx
    mov ah, 3Eh              ;Функция DOS 3Eh (закрытие файла)
    mov bx, inHandler        ;Дескриптор
    int 21h                  ;Обращение к функции DOS
    pop bx
    pop ax
    ret
CloseFileForWrite endp

SaveToFile proc  
    push si
    push di
    push cx
    call OpenFileForWrite
    xor di, di
    xor cx, cx
    FirstForFile:
        xor si, si
        SecondForFile:
            push di
            add di, si
            push ax
            mov ax, 2
            mul di
            mov di, ax
            pop ax
            mov ax, array[di]
            pop di
            call OutFileInt
            mov buf2, ' '
            call PrintFile
            inc si
            cmp si, Columns
        jne SecondForFile
        add di, Columns
        mov buf2, 13
        inc cx
        cmp cx, Rows 
    jne FirstForFile   
    call CloseFileForWrite
    pop cx
    pop di
    pop si
    ret
SaveToFile endp
;intermidiate procedure (file)
FromFile proc
    push ax
    push dx
        call FileReadArraySizeAndComparisonNumber
        call CmpAndKILL
        call PrintDoubleArray
        call SaveToFile
    pop dx
    pop ax
    ret
FromFile endp
;---------------------------MAIN--------------------------------------------
main:
    mov ax, @data
    mov ds, ax
    mov es, ax
    call AskForOption
    cmp ax, 1
    jne File
    call FromKeyboard
    jmp EndProg
    File:
    call FromFile
    EndProg:
    mov ah, 4ch
    int 21h
end main

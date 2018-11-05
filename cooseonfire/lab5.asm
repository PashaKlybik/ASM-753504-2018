.model small
.stack 256
.data

fileName1x1 db 'mat1.txt', 0
fileName2x2 db 'mat2.txt', 0
fileName3x3 db 'mat3.txt', 0
startMessage db "Enter matrix dimension (N<=3):", 10, 13, '$'
resultMessage db "Det(A) = ", '$'
matrixInputError db "Unappropriate dimension of matrix!", 10, 13, '$'
fileOpenError db "Unable to open file!", 10, 13, '$'
isNumberFlag db 0
dimension dw ?
array dw 10 dup (?)
handle dw 0 ;дексриптор файла
maxReadBytes dw 250
maxLen db 255
len db 0
buffer db 254 dup(0)

.code

proc readFile
    mov [handle], ax ;сохранение дескриптора файла
    mov bx, ax
    mov ah, 3Fh
    lea dx, buffer
    mov cx, maxReadBytes ;максимальное количество считываемых байтов
    int 21h
    jc closeFile

    lea bx, buffer
    add bx, ax ; в ax кол-во байт
    mov byte[bx], '$'

    lea si, buffer
    mov cx, ax
    cld
    mov bx, 0 ; начальный индекс массива

startSymbol:
    mov isNumberFlag, 0
    xor di, di ; сбрасываем флаг отрицательного числа
    xor dx, dx ; здесь будет результат
    lodsb
    cmp al, '-'
    jnz checkSymbol

setNegativeFlag:
    mov di, 1
    loop loadSymbol

loadSymbol:
    lodsb
    checkSymbol:
        cmp al, '0'
        jb fail
        cmp al, '9'
        ja fail
        sub al, '0'
        push bx
        mov bx, dx ; умножаем на 10 и прибавляем цифру
        shl dx, 2
        add dx, bx
        pop bx
        shl dx, 1
        jc fail
        xor ah, ah
        add dx, ax
        jc fail
        mov isNumberFlag, 1
        loop loadSymbol

fail:
    mov al, isNumberFlag ; проверка, есть ли в dx число
    test ax, 1
    jz startSymbol

    jcxz closeFile
    mov ax, dx
    test di, 1 ; проверяем на отрицательное
    jnz negativeInput
    cmp ax, 32767
    ja fail
    jmp ok

negativeInput:
    negativeInput:
    cmp ax, 32768
    ja fail
    neg ax

ok:
    mov array[bx], ax
    inc bx    ; размерность array - dw (x2bytes)
    inc bx
    loop startSymbol
    
closeFile:
    mov ah, 3Eh
    xor bx, bx
    mov bx, [handle]
    int 21h
    ret
endp

proc arrayFromFile 
    push bx
    push cx
    push dx
    clc

    mov ah, 09h
    lea dx, startMessage
    int 21h

    call scan
    jc inputError
    call newLine
    cmp ax, 1
    je mat1x1
    cmp ax, 2
    je mat2x2
    cmp ax, 3
    jne inputError

    mov dimension, 3
    mov ah, 3Dh
    xor al, al ;режим только для чтения
    lea dx, fileName3x3
    xor cx, cx ;обычный файл
    int 21h
    jc fileError
    call readFile
    jc fileError
    call det3x3
    jmp succsess

mat1x1:
    mov ah,3Dh
    xor al, al 
    lea dx, fileName1x1
    xor cx, cx
    int 21h
    jc fileError
    call readFile
    jc fileError
    mov ax, array[0] ; единственный элемент
    jmp succsess

mat2x2:
    mov dimension, 2
    mov ah, 3Dh
    xor al, al
    lea dx, fileName2x2
    xor cx,cx
    int 21h
    jc fileError
    call readFile
    jc fileError
    mov bx, 0
    mov si, 0
    mov di, 2
    call det2x2
    jmp succsess

inputError:
    mov ah, 09h
    xor al, al
    lea dx, matrixInputError
    int 21h
    stc
    jmp finish

fileError:
    mov ah, 09h
    lea dx, fileOpenError
    int 21h
    stc
    jmp finish

succsess:
    clc
finish:
    pop dx
    pop cx
    pop bx
    ret
endp

proc newLine
    push ax
    push dx

    mov dl, 10
    mov ah, 02h
    int 21h

    pop dx
    pop ax
    ret
endp

proc getRow
    push ax
    mov ax, 2         ; настриваем bx
    mov cx, dimension
    mul cx
    mul bx
    mov bx, ax
    pop ax
    ret
endp

proc det2x2
    ; в bx - 1-ая строка || в si - 1-ый столбец, в di - 2-ой
    push bx
    call getRow
    mov ax, array[bx][si] ; (1,1)
    pop bx

    inc bx
    push bx
    call getRow
    mov cx, array[bx][di] ; (2,2)
    pop bx
    imul cx
    push ax

    push bx
    call getRow
    mov ax, array[bx][si] ; (2,1)
    pop bx

    dec bx
    push bx
    call getRow
    mov cx, array[bx][di] ; (1,2)
    pop bx
    imul cx
    mov di, ax
    pop ax
    sbb ax, di ; крест-накрест
    ret
endp

proc det3x3
    mov ax, array[0]
    push ax
    mov bx, 1
    mov si, 2
    mov di, 4
    call det2x2
    mov bx, ax
    pop ax
    imul bx
    push ax ; cохраняем первый минор

    mov ax, array[2]
    neg ax ; менем у А2 знак на противоположный
    push ax
    mov bx, 1
    mov si, 0
    mov di, 4
    call det2x2
    mov bx, ax
    pop ax
    imul bx
    push ax ; созраняем 2 минор

    mov ax, array[4]
    push ax
    mov bx, 1
    mov si, 0
    mov di, 2
    call det2x2
    mov bx, ax
    pop ax
    imul bx
    ; складываем все миноры
    pop bx ; cпециально значение ax в bx
    add ax, bx
    pop bx
    add ax, bx
    ret
endp

proc print
    push ax
    push bx   ;сохраняем содержимое регистов
    push cx
    push dx
    xor cx,cx  
    mov bx, 10
    test ax, 1000000000000000b
    jnz negativeOutput
    jmp remains

negativeOutput:
    push ax
    xor dx, dx
    mov dl, '-'
    mov ah, 02h
    int 21h
    pop ax
    neg ax

remains:
    xor dx, dx 
    div bx
    add dl, '0' ;получаем очередную цифру и преобразуем в код символа, кладём в стек
    push dx
    inc cx
    test ax, ax ;проверка, есть ли ещё разряды в ax
    jnz remains

output:
    pop dx
    mov ah, 02h
    int 21h
    loop output
    call newLine

    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp

proc scan
    push bx
    push cx
    push dx
    mov cx, 1 ; для loop после 1 итерации
    xor dx, dx ; готовим результат

getChar:
    mov ah, 01h
    int 21h
    inc cx

    cmp al, 13
    jz enterCase
    cmp al, 20h ; клавиша space
    jz enterCase

    clc
    cmp al, '0'
    jb fatality
    cmp al, '9'
    ja fatality
    sub al, '0'
    mov bx, dx ; умножаем на 10 и прибавляем цифру
    shl dx, 2
    add dx, bx
    shl dx, 1
    jc fatality
    xor ah, ah
    add dx, ax
    jc fatality
    loop getChar

fatality:
    stc ; устанавливаем флаг ошибки
    pop dx
    pop cx
    pop bx
    ret

enterCase:
    dec cx ; инкремент для enter и до loop
    test cx, cx ; пустая строка
    jz fatality
    clc
    mov ax, dx
    pop dx
    pop cx
    pop bx
    ret
endp

main:
    mov ax, @data
    mov ds, ax

    call arrayFromFile
    jc exit
    push ax
    mov ah, 09h
    lea dx, resultMessage
    int 21h
    pop ax
    call print

exit:
    mov ax, 4c00h
    int 21h
end main
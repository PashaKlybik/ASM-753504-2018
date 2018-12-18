model small                     ; модель памяти
.stack 100h         ; установка размера стека

.data
devident dw 0
devider dw 0
temporary dw 0
enterdevident db "Enter devident: ", '$'
enterdevider db "Enter devider: ", '$'
repeat db 13, 10,"Repeat please!", 13, 10, '$'
wholeres db "Result:", 13, 10, "integer = ", '$'
fractional db ", fractional = $"
errorzero db "Division by zero!", 13, 10, '$'
n db 10,"$"
u dw 10
ost dw ?
cel dw ?

.code
InputInt proc   ;ввод в АX 

        entersymb:
        MOV AH, 01h ;Ввод с клавиатуры
        INT 21h
        mov ah,0 ;Обнуление регистра
        CMP AX, 13 ;проверка на энтр
        JZ end1 ;если нуль или равно - то переходим
        CMP AX, 48 ;проверка на 0-9
        JC error   ;есть переполнение/не выше и не равно/ниже - переходим
        CMP AX, 57 ; без этой дичи ошибка будет просто циклиться, но я хз че эт значит :D
        JZ contin  ;если нуль или равно - то переходим
        JNC error ;Нет переполнения/выше или равно/не ниже

        contin:
                SUB AL, 48;без неё выдает бешеные значения, но о ней также ничего неизвестно(
                MOV AH, 0  ;обнуление
                MOV BX, AX  ;ещё одно обнуление
                MOV AX, temporary ;загоняем временную переменную сюда
                MUL u  ;Тож хз чейта, умножение на ax но для чего :c
                JC error
                ADD AX, BX ;Проверка на ноль для перехода на Jc (если ноль , то выводит Division by zero!")
                JC error
                MOV temporary, AX ;Помещаем в temp ax
                JMP entersymb

        error:
                LEA DX, repeat ;Загружает в DX адрес значения repeaat
                MOV AH, 09h ;http://www.avprog.narod.ru/progs/fdos01.html просто оставлю это здесь ... выводит строку символов в консоль
                INT 21h
                MOV AX, 0
                MOV temporary, AX
                JMP entersymb ; jmp - в любом случае переходим

        end1:

        ret; возврат из подпрограммы
InputInt endp ;конец подпрограммы

OutputInt proc; вывод
        MOV CX, 0 ;Обнуляем

        next:
                MOV DX, 0 ; Позволяет делить Ax на Bx (тип если Dx = 0)
               ; DIV u
                PUSH DX
                MOV DX, 0
                INC CX
                CMP AX, 0
                JNZ next

        cycle:
                POP DX
                MOV DH, 0
                ADD DL, 48
                MOV AH, 02h
                INT 21h
                LOOP cycle

        ret
OutputInt endp

stasyan proc
        push ax
        push dx

        lea dx, n
        mov ah, 09h
        int 21h

        pop dx
        pop ax

        ret
stasyan endp

start:
MOV AX, @data
MOV DS, AX

LEA DX, enterdevident
MOV AH, 09h
INT 21h
call InputInt
push temporary
pop devident
mov temporary, 0

LEA DX, enterdevider
MOV AH, 09h
INT 21h
call InputInt
push temporary
pop devider
mov temporary, 0

cmp devider, 0
jz altendofprog

mov ax, devident
cwd
div devider

mov cel, ax ;ax=целое
mov ost, dx ;dx=остаток

LEA DX, wholeres
MOV AH, 09h
INT 21h
mov ax, cel
call outputint

LEA DX, fractional
MOV AH, 09h
INT 21h
mov ax, ost
call outputint

call stasyan

MOV AH, 4Ch
INT 21h

altendofprog:
LEA DX, errorzero
MOV AH, 09h
INT 21h

MOV AH, 4Ch
INT 21h
end start
.model tiny
.code
org 100h ; начало COM-программы
Start: 
JMP MAIN
HandlerNEW PROC
 
CMP AL, 1eh                     ; Код кнопки 'a' - 1eh  
JNE BletterCheck                ; переходим, когда в AL не 1eh 
MOV AL, 02h                     ; Код кнопки '1' - 02h 
JMP return 

BletterCheck: 
CMP AL, 30h                     ; Код кнопки 'b' - 30h 
JNE CletterCheck                ; переходим, когда в AL не 30h 
MOV AL, 03h                     ; Код кнопки '2'  - 03h  
JMP return 

CletterCheck: 
CMP AL, 2eh                     ; Код кнопки 'c' - 2eh 
JNE DletterCheck                ; переходим, когда в AL не 2eh
MOV AL, 04h                     ; Код кнопки '3' - 04h
JMP return 

DletterCheck: 
CMP AL, 20h                     ; Код кнопки 'd'- 20h 
JNE EletterCheck                ; переходим, когда в AL не 20h 
MOV AL, 05h                     ; Код кнопки '4'  - 05h  
JMP return 

EletterCheck: 
CMP AL, 12h                     ; Код кнопки 'e' - 12h  
JNE StandardHandler             ; переходим, когда в AL не 12h 
MOV AL, 06h                     ; Код кнопки '5' - 06h  
JMP return 

return:                         ; приходим в эту метку, если нажали нужную кнопку и изменили её scan код
JMP dword ptr cs:INTerrupt15    ; переходит по адресу 
                                ; cs:INTerrupt15, где хранится 
                                ; оригинальная функция для обработки 
                                ; прерывания, которое выводит символ 
                                ; из регистра al на экран

StandardHandler:                ; приходим в эту метку, если не нажали нужную нам кнопку 
JMP dword ptr cs:INTerrupt15    ; переходит по адресу 
                                ; cs:INTerrupt15, где хранится 
                                ; оригинальная функция для обработки 
                                ; прерывания, которое выводит символ 
                                ; из регистра al на экран
 
INTerrupt15 dd ?                ;  адрес предыдущего обработчика
HandlerNEW ENDP

MAIN :                           ; скопировать адрес предыдущего обработчика в переменную INTerrupt15
MOV ax, 3515h                    ; AH = 35h, AL = номер прерывания
int 21h                          ; функция DOS: считать адрес обработчика прерывания  
                                 
MOV word ptr INTerrupt15, bx     ; возвратить смещение в BX  
MOV word ptr INTerrupt15 + 2, es ; сегментный адрес в ES и установить наш обработчик
                                
MOV AX, 2515h                    
MOV DX, offset HandlerNEW        ; DS:DX - адрес обработчика 
INT 21h                          

MOV DX, offset MAIN              ; DX - адрес первого байта за 
                                 ; концом резидентной части
INT 27h                          ; оставить программу резидентной 
end Start

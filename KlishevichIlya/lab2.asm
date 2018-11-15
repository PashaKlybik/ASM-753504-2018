.model small                  
.stack 16h                    
.data  
msgA db 'Enter A = ', '$ '
msgB db 13,10,'Enter B = ', '$ '
msg5 db 13,10,'Result X = ', '$ '     
msg6 db 13,10,'Error! ', '$ '           
msg label byte
maxnum db 6 
reallen db ?
numfld db 5 dup(30h)
mult10 dw 0
ascval db 5 dup(30h),'$'             
  x  dw  ?

  a  dw  0
  b  dw  0
c dw 0
  z dw 0
u dw 0
 
.code                        
start: mov ax, @data          
       mov ds, ax   
       mov ah,9

       lea dx, msgA ; Сообщение "Enter A = "
       int 21H;
 
       mov ah,0AH
       lea dx,msg
       int 21H   
       call asbin ; Ввод числа с клавиатуры
       mov ax,z
       mov a,ax

 
       mov ah,9
       lea dx, msgB ; Сообщение "Enter B = "
       int 21H;
 
       mov ah,0AH
       lea dx,msg
       int 21H   
       call asbin ; Ввод числа с клавиатуры
       mov ax,z
       mov b,ax
 
    
       mov ah,9
       lea dx, msg5 ; Сообщение "Result X = "
       int 21H;       
   
   
       mov bx, dx
       mov cx, ax             
 
       xor dx,dx
       mov ax, a    
       mov bx, b        
       div bx ; Делим 2 числа                
       mov x, ax

 
 
call outp ; Вывод результата на экран 
     

mov ax, 4c00h
int 21h

      
                  
asbin proc ; Процедура ввода с клавиатуры
       mov mult10,0001
       mov z,0
       mov cx,10
       lea si,numfld-1
       mov bl,reallen
       sub bh,bh
b20:
       mov al,[si+bx]
	cmp al,'0'
	jb Err
	cmp al,'9'
	ja Err
       and ax,000fh
       mul mult10
       add z,ax
       mov ax,mult10
       mul cx
       mov mult10,ax
        dec bx
       jnz b20
       ret
asbin  endp
 
Err:
	lea dx, msg6

    mov ah, 09h

    int 21h

    mov ax, 4c00h

    int 21h
	




outp proc ; Процедура вывода на экран
       mov cx,10                ; система счисления
       lea si, ascval+4         ; Установка указателя на конец массива ascval
       mov ax, x                ; Результат х занести в ax
c20:   cmp ax,10                ; Сравнить результат с числом 10
        
       jb c30                   ; Если меньше то преобразовывать не надо
       
       lea dx, msgB ; Сообщение "Enter B = "
       int 21H;
     
c30:   or al, 30h               ; Если остаток меньше 10, то вывод результата на экран
       mov [si], al             ; дисплея командами (см. ниже)
       lea dx, ascval           ; Загрузка адреса массива
       mov ah, 9                ; Вызов 9-ой функции MS-DOS 
       int 21h
       ret                      ; Возврат в головную программу из п/программы
outp endp               ; Конец процедуры
 


end start
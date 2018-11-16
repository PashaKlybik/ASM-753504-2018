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
start: 
	      mov ax, @data          
        mov ds, ax   
        mov ah,9

        lea dx, msgA ; Сообщение "Enter A = "
        int 21H;
 
        mov ah,0AH
        lea dx,msg
        int 21H   
        call inpt ; Ввод числа с клавиатуры
        mov ax,z
        mov a,ax

        mov ah,9
        lea dx, msgB ; Сообщение "Enter B = "
        int 21H;
 
        mov ah,0AH
        lea dx,msg
        int 21H   
        call inpt   ; Ввод числа с клавиатуры
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
        div bx            
        mov x, ax 
	      call outp 	; Вывод результата на экран
   
	      mov ax, 4c00h
	      int 21h
   
inpt proc 		    ; Процедура ввода с клавиатуры
	       mov mult10,0001      
      	 mov z,0              ;обнуление результата
         mov cx,10            ;основание системы счисления
       	 lea si,numfld-1      :устанвока указателя на начало буфера
      	 mov bl,reallen       ;фактическое кол-во символов числа
      	 sub bh,bh            ;обнуление регистра 
  @@Loop:                     ;цикл преобразования в число
  	     mov al,[si+bx]       ;загрузка символа из конца буфера       
         cmp al,'0'           
  	     jb Err               
  	     cmp al,'9'           
  	     ja Err               
         and ax,000fh         ;беру 4 последение цифры
       	 mul mult10            
       	 add z,ax             ;прибавление промежуточного рез-та
       	 mov ax,mult10        ;загрузка в ax нового значения
       	 mul cx               ;умножение на 10
       	 mov mult10,ax        ;новое значение 
	       dec bx               ;на след. разряд числа
       	 jnz @@Loop           ;продолжаем цикл
       	 ret
inpt  endp
 
  Err:
     	lea dx, msg6
     	mov ah, 09h
     	int 21h
     	mov ax, 4c00h
     	int 21h

outp proc 			                 ; Процедура вывода на экран
        mov cx,10                ; Система счисления
        lea si, ascval+4         ; Установка указателя на конец массива
        mov ax, x                ; Результат х заносится в ах
	      cmp ax,10                ; Результат сравнивается с 10
        jb @@More                ; Если меньше,то не надо преорбразовывать
        lea dx, msgB   		       ; Сообщение  "Enter B = "
        int 21H;
 @@More:   
       or al, 30h                ; Если остаток меньшу 10, то выводм на экран
       mov [si], al             
       lea dx, ascval            ; Адрес массива
       mov ah, 9                
       int 21h
       ret                       ; Выход из п\программы
outp endp               	       ; Конец процедуры
end start

.model small
.stack 256
.data
  mainStr db 39,40 dup('$')
  resultStr db 20 dup('$')
  strLength dw ?  
  endLine db 13,10,'$'
.code

;ввод строки
readlnStr proc
  push ax
  push dx

  xor ax,ax
  xor dx,dx
  mov ah,0Ah
  lea dx,mainStr
  int 21h
  xor ax,ax
  mov al,[mainStr+1]            ;получение длинны введенной строки   
  mov strLength,ax              ;передача полученной длинны в переменную
  
  pop dx
  pop ax
  ret
readlnStr endp

;вывод строки
writelnStr proc
  push ax
  mov ah,9 
  int 21h
  xor dx,dx
  pop ax
  ret
writelnStr endp

  assume ds:@data,es:@data       ;привязка DS и ES к сегменту данных
main:
  ;настройка регистров ds и ex на адресс сегмента данных
  mov ax,@data
  mov ds,ax 
  mov es,ax  

  call readlnStr
  xor ax,ax
  lea dx, endLine
  call writelnStr

  cld                            ;очистить флаг направление df = 0, т.е. будем просматривать цепочку справа налево
  lea di,resultStr
  lea si,mainStr
  add si,2                       ;информация о символах в строке идет не с самого начала, перед ней её характеристики.
  lods mainStr                   ;загрузить из цепочки в регистр-аккумулятор
  stos resultStr                 ;сохранить результат из регистра аккамулятора в цепочке
  dec di                         ;декрементируем адресса после применения цепоч команд
  dec si
  xor ax,ax
  mov cx,strLength
	
  isEquals:
    cmps resultStr, mainStr      ;сравнение элементов цепочек
     jcxz toExit                 ;если строка пройдена то на выход
      je equal
      jne notEqual    
	  
      equal:
        dec di                   ;декрементируем адресс т.к. мы и так находились на позиции последнего символа
        dec cx
      jmp isEquals
	
      notEqual:
        dec cx
        xor ax,ax
        dec si                   ;уменьшаем si чтобы перейти на позицию не совпавшего символа, т.к. после применения операции сравнения мы продвинуллись по адрессу.
        lods mainStr             ;загружаем элемента из цепочки в аккамулятор
        xor ah,ah                 
        stos resultStr           ;заносим значение из регистра-аккамулятора в цепочку
        dec di                   ;уменьшаем di после исп. цеп. комманды
      jmp isEquals
      
  toExit:
    lea dx,resultStr
    call writelnStr
    mov ax,4c00h
    int 21h
		
end main
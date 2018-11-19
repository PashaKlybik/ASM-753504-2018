.MODEL small
.STACK 100h

.DATA
msg1     DB "Enter string: $"
msg2     DB 0Ah, 0Dh, "Result: $"

str1ml   DB 200
str1l    DB '$'
str1     DB 200 dup('$')
 
str2ml   DB 200
str2l    DB '$'
str2     DB 200 dup('$')

max      dw 0
maxfirst dw 0
 
.CODE

begin:
    mov  ax,@data
    mov  ds,ax
    mov  es,ax
    xor  ax,ax
 
    ;вывод приглашения msg1
    lea  dx,msg1 
    call strout
 
    ;ввод строки str1
    lea   dx, str1ml 
    call  strin

; нахождение самого длинного слова
maxlen:
    mov   ch,0              
    mov   cl,str1l          ; длина строки
    lea   di,str1           ; адрес строки
    mov   al,' '            ; искомый символ
    mov   dx,di             ; адрес самого длинного слова на данный момент
    mov   max,0             ; длина самого длинного слова на данный момент
        
space:
    mov   si,di             ; запомнить адрес начала текущего слова
    repne scasb             ; сканировать пока не равно пробелу  
    mov   bx,di             ; адресс пробела
    sub   bx,si             ; первичная длина 
    jz    less              ; если длина=0 (2 пробела)
    cmp   cx,0              ; конец строки
    jz    end_str           
    dec   bx                ; реальная длина
    jz    less 
           
end_str:
    cmp   bx,max            ; сравнение длины(ВХ) с самым длинным
    jbe   less              ; < max
    mov   max,bx
    mov   dx,si  
 
less:  
    cmp   cx,0              
    jnz   space             ; если не конец     
    mov   bp,dx             ; адрес слова
    mov   bx, max           ; длина слова

              
    cmp   bx, 0
    je    exit
    cmp   bx, maxfirst      
    jb    exit 
    mov   maxfirst, bx  
          
    ; копирование слова
    cld
    lea   di,str1
    sub   bp,di
    mov   cx, bx
    lea   di, str2
    lea   si, str1[bp]
    rep   movsb

;Вывод слова
exit: 
    lea   dx, msg2 
    call  strout
    lea   dx, str2
    call  strout 
    ;выход
    mov   ah, 01h
    int   21h
    mov   ax, 4c00h
    int   21h

strin proc
    mov   ah, 0Ah
    int   21h
    ret
strin endp

strout proc
    mov   ah, 09h
    int   21h
    ret
strout endp
 
end begin
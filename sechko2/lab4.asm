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
 
    ;����� ����������� msg1
    lea  dx,msg1 
    call strout
 
    ;���� ������ str1
    lea   dx, str1ml 
    call  strin

; ���������� ������ �������� �����
maxlen:
    mov   ch,0              
    mov   cl,str1l          ; ����� ������
    lea   di,str1           ; ����� ������
    mov   al,' '            ; ������� ������
    mov   dx,di             ; ����� ������ �������� ����� �� ������ ������
    mov   max,0             ; ����� ������ �������� ����� �� ������ ������
        
space:
    mov   si,di             ; ��������� ����� ������ �������� �����
    repne scasb             ; ����������� ���� �� ����� �������  
    mov   bx,di             ; ������ �������
    sub   bx,si             ; ��������� ����� 
    jz    less              ; ���� �����=0 (2 �������)
    cmp   cx,0              ; ����� ������
    jz    end_str           
    dec   bx                ; �������� �����
    jz    less 
           
end_str:
    cmp   bx,max            ; ��������� �����(��) � ����� �������
    jbe   less              ; < max
    mov   max,bx
    mov   dx,si  
 
less:  
    cmp   cx,0              
    jnz   space             ; ���� �� �����     
    mov   bp,dx             ; ����� �����
    mov   bx, max           ; ����� �����

              
    cmp   bx, 0
    je    exit
    cmp   bx, maxfirst      
    jb    exit 
    mov   maxfirst, bx  
          
    ; ����������� �����
    cld
    lea   di,str1
    sub   bp,di
    mov   cx, bx
    lea   di, str2
    lea   si, str1[bp]
    rep   movsb

;����� �����
exit: 
    lea   dx, msg2 
    call  strout
    lea   dx, str2
    call  strout 
    ;�����
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
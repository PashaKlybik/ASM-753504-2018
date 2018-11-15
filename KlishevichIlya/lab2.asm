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

       lea dx, msgA ; ��������� "Enter A = "
       int 21H;
 
       mov ah,0AH
       lea dx,msg
       int 21H   
       call asbin ; ���� ����� � ����������
       mov ax,z
       mov a,ax

 
       mov ah,9
       lea dx, msgB ; ��������� "Enter B = "
       int 21H;
 
       mov ah,0AH
       lea dx,msg
       int 21H   
       call asbin ; ���� ����� � ����������
       mov ax,z
       mov b,ax
 
    
       mov ah,9
       lea dx, msg5 ; ��������� "Result X = "
       int 21H;       
   
   
       mov bx, dx
       mov cx, ax             
 
       xor dx,dx
       mov ax, a    
       mov bx, b        
       div bx ; ����� 2 �����                
       mov x, ax

 
 
call outp ; ����� ���������� �� ����� 
     

mov ax, 4c00h
int 21h

      
                  
asbin proc ; ��������� ����� � ����������
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
	




outp proc ; ��������� ������ �� �����
       mov cx,10                ; ������� ���������
       lea si, ascval+4         ; ��������� ��������� �� ����� ������� ascval
       mov ax, x                ; ��������� � ������� � ax
c20:   cmp ax,10                ; �������� ��������� � ������ 10
        
       jb c30                   ; ���� ������ �� ��������������� �� ����
       
       lea dx, msgB ; ��������� "Enter B = "
       int 21H;
     
c30:   or al, 30h               ; ���� ������� ������ 10, �� ����� ���������� �� �����
       mov [si], al             ; ������� ��������� (��. ����)
       lea dx, ascval           ; �������� ������ �������
       mov ah, 9                ; ����� 9-�� ������� MS-DOS 
       int 21h
       ret                      ; ������� � �������� ��������� �� �/���������
outp endp               ; ����� ���������
 


end start
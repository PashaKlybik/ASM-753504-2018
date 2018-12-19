.model tiny
.code
org 100h ; ������ COM-���������
Start: 
JMP MAIN

HandlerNEW PROC
 
CMP AL, 1eh                     ; ��� ������ 'a' - 1eh  
JNE BletterCheck                ; ���������, ����� � AL �� 1eh 
MOV AL, 02h                     ; ��� ������ '1' - 02h 
JMP return 

BletterCheck: 
CMP AL, 30h                     ; ��� ������ 'b' - 30h 
JNE CletterCheck                ; ���������, ����� � AL �� 30h 
MOV AL, 03h                     ; ��� ������ '2'  - 03h  
JMP return 

CletterCheck: 
CMP AL, 2eh                     ; ��� ������ 'c' - 2eh 
JNE DletterCheck                ; ���������, ����� � AL �� 2eh
MOV AL, 04h                     ; ��� ������ '3' - 04h
JMP return 

DletterCheck: 
CMP AL, 20h                     ; ��� ������ 'd'- 20h 
JNE EletterCheck                ; ���������, ����� � AL �� 20h 
MOV AL, 05h                     ; ��� ������ '4'  - 05h  
JMP return 

EletterCheck: 
CMP AL, 12h                     ; ��� ������ 'e' - 12h  
JNE StandardHandler             ; ���������, ����� � AL �� 12h 
MOV AL, 06h                     ; ��� ������ '5' - 06h  
JMP return 

return:                         ; �������� � ��� �����, ���� ������ ������ ������ � �������� � scan ���
JMP dword ptr cs:INTerrupt15    ; ��������� �� ������ 
                                ; cs:INTerrupt15, ��� �������� 
                                ; ������������ ������� ��� ��������� 
                                ; ����������, ������� ������� ������ 
                                ; �� �������� al �� �����

StandardHandler:                ; �������� � ��� �����, ���� �� ������ ������ ��� ������ 
JMP dword ptr cs:INTerrupt15    ; ��������� �� ������ 
                                ; cs:INTerrupt15, ��� �������� 
                                ; ������������ ������� ��� ��������� 
                                ; ����������, ������� ������� ������ 
                                ; �� �������� al �� �����
 
INTerrupt15 dd ?                ; ����� �������� ����� 
                                ; ����������� �����������
HandlerNEW ENDP

MAIN : 
 ; ����������� ����� ����������� ����������� 
 ; � ���������� INTerrupt15
MOV ax, 3515h                    ; AH = 35h, AL = ����� ����������
int 21h                          ; ������� DOS: ������� 
                                 ; ����� ����������� ���������� 
MOV word ptr INTerrupt15, bx     ; ���������� �������� � BX  
MOV word ptr INTerrupt15 + 2, es ; � ���������� ����� � ES,
                                 ; ���������� ��� ����������
MOV AX, 2515h                    ; AH = 25h, AL = ����� ����������
MOV DX, offset HandlerNEW        ; DS:DX - ����� ����������� 
INT 21h                          ; ������� DOS : ���������� ���������� 

MOV DX, offset MAIN              ; DX - ����� ������� ����� �� 
                                 ; ������ ����������� �����
INT 27h                          ; �������� ��������� ����������� 

end Start
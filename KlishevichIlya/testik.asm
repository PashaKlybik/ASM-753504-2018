.model small
.data
input1 db 0dh,0ah,'Enter first number  : $'
input2 db 0dh,0ah,'Enter second number : $'
output db 0dh,0ah,'Result = $'
output2 db 0dh,0ah,'Error'
buf label byte                   ; ����� ������ � ����������
max db 20                        ; ������������ ����� ������
len db 0                           ; �������� ����� ��������� ������
string db 20 dup (?)          ; ���������� ���� ������
 
 .code
 .startup
 
GetFirst:
               lea dx, input1     ; ������ �����������
               call GetNum       ; ������ ����� � AX
               jc GetFirst          ; ��������, ���� ������
               mov bx, ax         ; ��������
 
GetSecond:
               lea dx, input2
               call GetNum
               cmp ax,0
               jc GetSecond
               mov cx,bx
               mov bx,ax
               mov ax,cx
               cwd                      ;��������� ����� � DX
               idiv   bx 
 
               lea dx, output     ; ������ Sum=
               call PrintNum      ; ������� �����
               mov ah, 0           ; ���� ������� �� �������
               int 16h
 
               mov ax,4c00h     ; ����� ������
               int 21h
 
PrintNum proc               ; ����� ����� �� ax
    push ax
    mov ah, 9
    int 21h                     ; ����� ������ (�� dx)
    pop ax
    test ax, ax                ;�������� �� ����
    jns FormStr              ;��� �������������� �� �����
    push ax                    ;��� �������������� ������� - � ������ ����
    mov al,'-'                  ;���� -
    int 29h
    pop ax
    neg ax                      ;������ ���� ����� �� +, ������ ��� �������������
 
FormStr:
       mov bx, 10      ; ����� ������ �� 10
       xor cx, cx         ; ������� ����
DivLoop:                 ; ���� ��������� ���������� ��������
       xor dx, dx        ; ������������ ��� ���������� �������
       div bx              ; � dx ������� - ��������� ���������� ������
       push dx           ; �������� � ����� (�� �������� � ��������)
       inc cx              ; ��������� ��� ���
       test ax, ax       ; �������� �� ������� ��� ���������� ��������
       jnz DivLoop     ; ��������� �����
 
PrLoop:                 ; ���� ������ ���������� ����-��������
        pop ax          ; ���������� ��������� ������ (�� �������� � ��������)
        add al, '0'      ;  ������ �����
        int 29h          ; �����
        loop PrLoop   ; �� ���� ������
        ret
PrintNum endp

GetNum proc      ; �������������� ����� � �����
       push bx
       mov ah, 9
       int 21h        ; ����������� ������ ������
       lea dx, buf
       mov ah, 0ah
       int 21h        ; ������ ������
 
        xor di, di  ; ����� ����� ����������� �����
        mov cl, 0  ; ���� �����
        mov ch, 0  ; ���������� ����
        xor bx, bx  ; ��������� ���� (��� �������� �� ������)
        lea si, string ; �������� ������
GetNumLoop:
       lodsb   ; ��������� �����
       cmp al, 0dh ; �������� �� �����������
       je NumEndFound ; ����� �����
       cmp al, ' '
       je NumEndFound
       cmp al, 9
       je NumEndFound
       cmp al, '-'; ����� ����� ���� ����� ���� � � ������ �������! 
       jne CmpNum
       test ch, ch  ; ���� �� ������� �����?
       jnz SetC   ; ���� - ������ - ����� �� � ������ �������!
       test cl, cl  ; ��� �� ��� ������ �����?
       jnz SetC   ; ��� - ������ - ����� ������ ����!
       mov cl, 1  ; ������� ������������� �����
       jmp GetNumLoop ; �� ������ ���������� �������
 CmpNum:
       cmp al, '0'  ; �����?
       jb SetC   ; ������� - �� �����! 
       cmp al, '9'
       ja SetC
       inc ch  ; ������� �����
       and al, 0fh  ; ����� -> ����� (30h-39h -> 0-9)
       mov bl, al  ; �������� (bh=0)
       mov ax, 10  ; ������� �� 10 
       imul di  ; ���������� ��������
       test dx, dx  ; ������ c���� - ������!
       jnz SetC 
       add ax,bx
       jc SetC  ; ������  ����� - ������!
       js SetC  ; ������ 32767 - ������!
       mov di, ax  ; ������
       jmp GetNumLoop ; �� ������ ���������� �������
 
NumEndFound:   ; ��������� �����������
         test ch, ch  ; ���-�� ����?
         jz SetC   ; �� ���� ����� (��������, ��� ������ ���� �����)
         test cl, cl  ; ����� �������������?
         jz GetNumRet
         neg di  ; �������������� ��� �������������� �����
GetNumRet:
        mov ax, di  ; ��������� ������ � ax
        pop bx
        clc   ; ��� ���
        ret
SetC :
        pop bx
        stc   ; ������
        ret
GetNum endp 
end 
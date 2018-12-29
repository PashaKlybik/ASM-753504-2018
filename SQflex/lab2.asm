model small                     ; ������ ������
.stack 100h         ; ��������� ������� �����

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
InputInt proc   ;���� � �X 

        entersymb:
        MOV AH, 01h ;���� � ����������
        INT 21h
        mov ah,0 ;��������� ��������
        CMP AX, 13 ;�������� �� ����
        JZ end1 ;���� ���� ��� ����� - �� ���������
        CMP AX, 48 ;�������� �� 0-9
        JC error   ;���� ������������/�� ���� � �� �����/���� - ���������
        CMP AX, 57 ; ��� ���� ���� ������ ����� ������ ���������, �� � �� �� �� ������ :D
        JZ contin  ;���� ���� ��� ����� - �� ���������
        JNC error ;��� ������������/���� ��� �����/�� ����

        contin:
                SUB AL, 48;��� �� ������ ������� ��������, �� � ��� ����� ������ ����������(
                MOV AH, 0  ;���������
                MOV BX, AX  ;��� ���� ���������
                MOV AX, temporary ;�������� ��������� ���������� ����
                MUL u  ;��� �� �����, ��������� �� ax �� ��� ���� :c
                JC error
                ADD AX, BX ;�������� �� ���� ��� �������� �� Jc (���� ���� , �� ������� Division by zero!")
                JC error
                MOV temporary, AX ;�������� � temp ax
                JMP entersymb

        error:
                LEA DX, repeat ;��������� � DX ����� �������� repeaat
                MOV AH, 09h ;http://www.avprog.narod.ru/progs/fdos01.html ������ ������� ��� ����� ... ������� ������ �������� � �������
                INT 21h
                MOV AX, 0
                MOV temporary, AX
                JMP entersymb ; jmp - � ����� ������ ���������

        end1:

        ret; ������� �� ������������
InputInt endp ;����� ������������

OutputInt proc; �����
        MOV CX, 0 ;��������

        next:
                MOV DX, 0 ; ��������� ������ Ax �� Bx (��� ���� Dx = 0)
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

mov cel, ax ;ax=�����
mov ost, dx ;dx=�������

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
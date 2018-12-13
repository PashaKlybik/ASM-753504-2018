model small
.486
LOCALS @@
.stack  256
.data
 
Rows            equ    4                ;������������ ���������� �����
Columns         equ    4                ;������������ ���������� ��������
iSize           equ    Rows*Columns     ;������������ ������ �������
 
m               dw     Rows             ;������� ���������� �����
n               dw     Columns          ;������� ���������� ��������
 
Matrix          dw     iSize dup(?)     ;�������
 
asCR_LF         db      0dh, 0ah, '$'   ;"������� ������"
asTitle0        db      'Input matrix', '$'
asTitle1        db      'Current matrix', '$'
asTitle2        db      'Result matrix', '$'
asPrompt1       db      'a[ ', '$'      ;������ �����������
asPrompt2       db      ',  ', '$'
asPrompt3       db      ']= ', '$'
 
kbMaxLen        equ     6+1             ;����� ����� � ���������� Fn 0ah
kbInput         db      kbMaxLen, 0, kbMaxLen dup(0)
 
.code
 
; �������������� ������ � �����
; �� �����:
; ds:[si] - ������ � ������
; ds:[di] - ����� �����
; �� ������
; ds:[di] - �����
; CY - ���� �������� (��� ������ - ����������, ����� - �������)
Str2Num PROC
        push    ax
        push    bx
        push    cx
        push    dx
        push    ds
        push    es
        push    si
 
        push    ds
        pop     es
 
        mov     cl, ds:[si]
        xor     ch, ch
 
        inc     si
 
        mov     bx, 10
        xor     ax, ax
 
        ;���� � ������ ������ ������ '-'
        ; - ������� � ����������
        ; - ��������� ���������� ��������������� ��������
        cmp     byte ptr [si], '-'
        jne     @@Loop
        inc     si
        dec     cx
@@Loop:
        mul     bx         ; �������� ax �� 10 ( dx:ax=ax*bx )
        mov     [di], ax   ; ���������� ������� �����
        cmp     dx, 0      ; ���������, ��������� �� ������������
        jnz     @@Error
 
        mov     al, [si]   ; ����������� ��������� ������ � �����
        cmp     al, '0'
        jb      @@Error
        cmp     al, '9'
        ja      @@Error
        sub     al, '0'
        xor     ah, ah
        add     ax, [di]
        jc      @@Error    ; ���� ����� ������ 65535
        cmp     ax, 8000h
        ja      @@Error
        inc     si
 
        loop    @@Loop
 
        pop     si         ;�������� �� ����
        push    si
        inc     si
        cmp     byte ptr [si], '-'
        jne     @@Check    ;���� ������ ���� �������������
        neg     ax         ;���� ������ ���� �������������
        jmp     @@StoreRes
@@Check:                   ;�������������� ��������, ����� ��� ����� �������������� ����� �������� �������������
       or       ax, ax     ;
       js       @@Error
@@StoreRes:                ;��������� ���������
        mov     [di], ax
        clc
        pop     si
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
@@Error:
        xor     ax, ax
        mov     [di], ax
        stc
        pop     si
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
Str2Num ENDP
 
; ������� ����� �� �������� AX �� �����
; ������� ������:
; ax - ����� ��� �����������
Show_AX proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
 
        mov     cx, 10
        xor     di, di          ; di - ���. ���� � �����
 
        ; ���� ����� � ax �������������, ��
        ;1) ���������� '-'
        ;2) ������� ax �������������
        or      ax, ax
        jns     @@Conv
        push    ax
        mov     dx, '-'
        mov     ah, 2           ; ah - ������� ������ ������� �� �����
        int     21h
        pop     ax
 
        neg     ax
 
@@Conv:
        xor     dx, dx
        div     cx              ; dl = num mod 10
        add     dl, '0'         ; ������� � ���������� ������
        inc     di
        push    dx              ; ���������� � ����
        or      ax, ax
        jnz     @@Conv
        ; ������� �� ����� �� �����
@@Show:
        pop     dx              ; dl = ��������� ������
        mov     ah, 2           ; ah - ������� ������ ������� �� �����
        int     21h
        dec     di              ; ��������� ���� di<>0
        jnz     @@Show
 
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
Show_AX endp
 
; �� �����
;m     - ���������� �����
;n     - ���������� ��������
;ds:dx - ����� �������
ShowMatrix PROC FAR
        pusha
        mov     si, 0  ; ������
        mov     di, 0  ; �������
        mov     bx, dx
 
@@ShowRow:
        mov     ax, [bx]
        call    Show_AX
 
        mov     ah,     02h
        mov     dl,     ' '
        int     21h
 
        add     bx,     2
 
        inc     di
 
        cmp     di, n
        jb      @@ShowRow
 
        mov     dx, OFFSET asCR_LF
        mov     ah, 09h
        int     21h
 
        mov     di, 0
 
        inc     si
 
        cmp     si, m
        jb      @@ShowRow
 
        popa
        ret
ShowMatrix ENDP
 
; �� �����
;ds:dx - ����� �������
InputMatrix PROC
        pusha
        ;bx - ����� ���������� �������� �������
        mov     bx,     dx
        ;����� �� ����� ����������� ������ �������
        mov     ah, 09h
        mov     dx, OFFSET asTitle0
        int     21h
 
        mov     ah, 09h
        mov     dx, OFFSET asCR_LF
        int     21h
 
        mov     si, 1  ; ������ (������)
        mov     di, 1  ; ������� (������)
@@InpInt:
        ;����� �� ����� ����������� 'a[  1,  1]='
        lea     dx, asPrompt1
        mov     ah, 09h
        int     21h
        mov     ax,     si
        call    Show_AX
        lea     dx, asPrompt2
        mov     ah, 09h
        int     21h
        mov     ax,     di
        call    Show_AX
        lea     dx, asPrompt3
        mov     ah, 09h
        int     21h
 
        ;���� ������
        mov     ah, 0ah
        mov     dx, OFFSET kbInput
        int     21h
 
        ;�������������� ������ � �����
        push    di
        push    si
        mov     si, OFFSET kbInput+1
        mov     di, bx
        call    Str2Num
        pop     si
        pop     di
        jc      @@InpInt  ; ���� ������ �������������� - ��������� ����
        ;�������� ���������� ����� �� ���������� �������� �� ����� 2
        cmp     word ptr [bx],  10
        jge     @@Ok
        cmp     word ptr [bx],  -10
        jle     @@Ok
        jmp     @@InpInt
@@Ok:
        ;�� ������ - ������� � ��������� ������
        mov     dx, OFFSET asCR_LF
        mov     ah, 09h
        int     21h
        ;������� � ���������� �������� �������
        add     bx,     2
 
        inc     di
 
        cmp     di, n
        jbe     @@InpInt
 
        mov     di, 1
 
        inc     si
 
        cmp     si, m
        jbe     @@InpInt
 
        popa
        ret
InputMatrix ENDP
 
Main    PROC    FAR
        mov     dx, @data
        mov     ds, dx
 
        mov     dx, OFFSET Matrix
        call    InputMatrix
 
        mov     ah, 09h
        mov     dx, OFFSET asTitle1
        int     21h
 
        mov     ah, 09h
        mov     dx, OFFSET asCR_LF
        int     21h
 
        mov     dx, OFFSET Matrix
        call    ShowMatrix
 
        ;����� ������ � ����������� ��������� ����� ���������
        mov     ax,     7FFFh   ;����������� �������� ����� � �������
        mov     di,     0       ;����� ������ � ����������� ������
        mov     cx,     m
        lea     si,     Matrix
@@ForI:                         ;���� �� �������
        mov     bx,     0       ;����� ��������� ������
        push    cx
        mov     cx,     n       ;���������� ��������� � ������
        @@ForJ:
                add     bx,     [si]
                add     si,     2
                loop    @@ForJ
        pop     cx
 
        cmp     ax,     bx
        jle     @@Next
        mov     ax,     bx
        mov     di,     m       ;di - ����� ������ � ����������� ������
        sub     di,     cx
@@Next:
        loop    @@ForI
 
        ;������ ��������� ������ � ����������� ������ ���������, �� ����
        lea     bx,     Matrix
        mov     ax,     n
        mul     di
        shl     ax,     1
        add     bx,     ax
        mov     cx,     n
        mov     ax,     0
@@@ForJ:
        mov     [bx],   ax
        add     bx,     2
        loop    @@@ForJ
 
 
        ;����� ����������� �� �����
        mov     ah, 09h
        mov     dx, OFFSET asTitle2
        int     21h
 
        mov     ah, 09h
        mov     dx, OFFSET asCR_LF
        int     21h
 
        mov     dx, OFFSET Matrix
        call    ShowMatrix
 
        mov     ax, 4c00h
        int     21h
Main    ENDP
 
END     Main
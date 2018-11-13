.MODEL  Small
.STACK  100h 
.DATA
 
KeyBuf  db      7, 0, 7 dup(0)      ;max,len,string,CR(0dh)
CR_LF   db      0Dh, 0Ah, '$'
 
InDividend      db      'enter the dividend: ', '$'
InDivider       db      'enter the divider: ', '$'
TextDividend    db      'dividend =  ', '$'
TextDivider     db      'divider =  ', '$'
TextResult      db      'result =  ', '$'
Error01         db      'eror',0Dh, 0Ah, '$'
Dividend        dw      ?
Divider         dw      ?
Result          dw      ?
Sing            dw      0
 
.CODE
 
; ������� ����� � �������� AX �� �����
; ������� ������:
; cx - ������� ��������� (�� ������ 10)
; ax - ����� ��� �����������
Show_ax PROC
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
 
        mov     cx, 10          ; cx - ��������� ������� ���������
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
Show_ax ENDP
 
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
        jb      @@Error    ;����
        cmp     al, '9'
        ja      @@Error    ;����
        sub     al, '0'
        xor     ah, ah
        add     ax, [di]
        jc      @@Error    ; ���� ����� ������ 65535
        cmp     ax, 8000h
        ja      @@Error
        inc     si
 
        loop    @@Loop     ;���������� ������
 
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
 
Main    PROC    FAR
        mov     ax, @DATA
        mov     ds, ax
        mov     es, ax
 
        ; ���� ����� � ���������� (������)
        lea     dx, InDividend
        mov     ah, 09h
        int     21h
 
        mov     ah, 0Ah
        mov     dx, offset KeyBuf
        int     21h
 
        ; ������� ������ (�� ����� ������)
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h
 
        ; �������������� ������ � �����
        lea     si, KeyBuf+1
        lea     di, Dividend
        call    Str2Num
 
        ; �������� �� ������
        jnc     @@NoError
 
        ; ���� ���� ������ ����� - ���������� ��������� �� ������
        lea     dx, Error01
        mov     ah, 09h
        int     21h
        jmp     @@Exit
 
        ; ���� ��� ������ ����� - ���������� �����
@@NoError:
        ; � ���������� �������������
        lea     dx, TextDividend  
        mov     ah, 09h
        int     21h
 
        mov     ax, Dividend
        mov     cx, 10
        call    Show_ax
 
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h
;1111111111111111111111111111111111111111111111


        ; ���� ����� � ���������� (������)
        lea     dx, InDivider
        mov     ah, 09h
        int     21h
 
        mov     ah, 0Ah
        mov     dx, offset KeyBuf
        int     21h
 
        ; ������� ������ (�� ����� ������)
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h
 
        ; �������������� ������ � �����
        lea     si, KeyBuf+1
        lea     di, Divider
        call    Str2Num
 
        ; �������� �� ������
        jnc     @@NoError2
 
        ; ���� ���� ������ ����� - ���������� ��������� �� ������
        lea     dx, Error01
        mov     ah, 09h
        int     21h
        jmp     @@Exit
 
        ; ���� ��� ������ ����� - ���������� �����
@@NoError2:
        ; � ���������� �������������
        lea     dx, TextDivider
        mov     ah, 09h
        int     21h
 
        mov     ax, Divider
        mov     cx, 10
        call    Show_ax
 
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h

        ;�������
        mov dx, 0  
        mov ax, Dividend
        cmp ax, 0
        JG DIVER
        neg ax
        add Sing, 1
        DIVER:
        mov bx, Divider
        cmp bx, 0
        JG DIV1
        neg bx
        add Sing, 1

        DIV1:
        div bx
        mov si, Sing
        cmp si, 1
        JNZ RES
        neg ax
        
        RES:     
        mov Result,ax

        lea     dx, TextResult
        mov     ah, 09h
        int     21h
 
        mov     ax, Result
        mov     cx, 10
        call    Show_ax

        ;������� �� ����� �������
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h
 
        lea     dx, CR_LF
        mov     ah, 09h
        int     21h
        ; �����
@@Exit:
        ; �������� ������� ����� �������
        mov     ah, 01h
        int     21h
 
        mov     ax, 4c00h
        int     21h
Main    ENDP
 

 
        END     Main
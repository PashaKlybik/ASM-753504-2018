LOCALS
.model small
.stack 100h
.data
        kbdBuffer       db      80, ?, 80 dup(0)        ;����� ���������� ��� ����� ������
        CrLf            db      0Dh, 0Ah, '$'                ;������� �������� ������
        Delimiter       db      ' '                              ;����������� ���� � ������
        String          db      ?, 80 dup(0)                ;������ � ������� �����, �������
        WordForDelete   db      ?, 80 dup(0)         ;������ � ������� �����, �������
        PromptStr       db      'Enter string:', 0Dh, 0Ah, '$'
        PromptWord      db      'Enter word:', 0Dh, 0Ah, '$'
        msgNewString    db      'Result String: ', 0Dh, 0Ah, '$'
.code
 
main    proc
        mov     ax,     @data
        mov     ds,     ax
        mov     ah,     09h     ;���� ������
        lea     dx,     PromptStr
        int     21h
        lea     dx,     String
        call    GetStr
        mov     ah,     09h      ;���� ����� ��� �������� �� ������
        lea     dx,     PromptWord
        int     21h
        lea     dx,     WordForDelete
        call    GetStr
 
        ;���� ��������� ���� � ��������� �� � ��������� ������
        mov     cx,     0           ;cx - ����� ������
        mov     cl,     String
        jcxz    @@Break         ;���� ������ ������ - ��������� ���������
        mov     dx,     0          ;dx - ����� ���������� �����
        mov     dl,     WordForDelete
        or      dx,     dx
        jz      @@Break
        lea     si,     String+1  ;si - ����� ������� ������� ������
        mov     di,     si          ;di - ����� ������ ����� � ������
@@For:
        lodsb                         ;������ ���������� ������� � al, ���������� si �� 1
        cmp     al,     Delimiter           ;��������� ������ - ����������� ����?
        je      @@NewWord               ;�� - ������� � �������, ����������� ��������� � ��������
        loop    @@For           ;
        ;����� ��������� ���������� ����� � ������
        inc     si              ;��� �������� ���������� �����
@@NewWord:
        pushf
        cld
        ;�������� ����� ����
        mov     ax,     si
        sub     ax,     di
        dec     ax
        cmp     ax,     dx
        jne     @@Next
        ;��� ��������� - �������� �����
        push    si
        push    di
        push    cx
        push    es
        push    ds
        pop     es
        mov     cx,     dx
        lea     si,     WordForDelete+1
        repe    cmpsb
        pop     es
        pop     cx
        pop     di
        pop     si
        jne     @@Next
        ;��� ���������� ���� - ������� �� ������ �����
        jcxz    @@SkipCopy
        push    cx
        push    si
        push    di
        push    es
        push    ds
        pop     es
        rep     movsb
        pop     es
        pop     di
        pop     si
        pop     cx
        ;����� ��������, �������� ���������� � 1-�� ������� ��������� �����
        mov     si,     di
        dec     [String] ;��������� �� ������ �����, �� � �����������
@@SkipCopy:
        sub     [String], dl ;��������� ����� ������
@@Next:
        popf
 
        mov     di,     si
        jcxz    @@Break
        loop    @@For
@@Break:
        ;����� �����������
        mov     ah,     09h
        lea     dx,     msgNewString
        int     21h
        call    ShowString
 
        mov     ah,     09h
        lea     dx,     CrLf
        int     21h
 
@@Exit:
        mov     ax,     4C00h   ;���������� ���������
        int     21h
main    endp
 
;������ ������ � ����������
;�� �����:
;  ds:dx - ����� ������
;�� ������:
;  ds:dx - ������ � ������� (�����, �������)
GetStr  proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        pushf
        push    es
 
        mov     bx,     dx      ;���������� ������ ������
        mov     ah,     0Ah    ;������ � ����� �� ����������
        lea     dx,     kbdBuffer
        int     21h
        mov     ah,     09h  ;������� ������
        lea     dx,     CrLf
        int     21h
        ;����������� �� ������ � ���������� ������
        mov     cx,     0
        mov     cl,     [kbdBuffer+1]
        ;jcxz    @@SkipCopy
        inc     cx
        push    ds
        pop     es
        lea     si,     kbdBuffer+1
        mov     di,     bx
        cld
        rep     movsb
        mov     byte ptr [di],  '$'  ;���������� �������� ����� ������ �� ��������� ��������
@@SkipCopy:
        pop     es
        popf
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
GetStr  endp
 
ShowString      proc
.386
        pusha
        mov     cx,     0
        mov     cl,     String
        lea     si,     String
        add     si,     cx
        mov     byte ptr [si+1],'$'
 
        mov     ah,     09h
        lea     dx,     String+1
        int     21h
 
        mov     ah,     09h
        lea     dx,     CrLf
        int     21h
        popa
        ret
ShowString      endp
 
end     main
.MODEL  Small
.STACK  100h 

.DATA 
KeyBuf          db      6, 0, 6 dup(0)      
CR_LF           db      0Dh, 0Ah, '$'
 
InDividend      db      'enter the dividend: ', '$'
InDivider       db      'enter the divider: ', '$'
TextDividend    db      'dividend =  ', '$'
TextDivider     db      'divider =  ', '$'
TextResult      db      'result =  ', '$'
Error01         db      'eror',0Dh, 0Ah, '$'
Dividend        dw      ?
Divider         dw      ?
Result          dw      ?
 
.CODE
Show_ax PROC
    xor     di, di 
    
@@Conv:
    xor     dx, dx
    div     cx              
    add     dl, '0'         
    inc     di
    push    dx              
    or      ax, ax
    jnz     @@conv 
    
@@Show:
    pop     dx              
    mov     ah, 2           
    int     21h
    dec     di              
    jnz     @@show
    ret
Show_ax ENDP
 
Str2Num PROC
    push    ax
    push    bx
    push    cx
    push    dx
    push    ds
    push    es
    push    ds
    pop     es 
    mov     cl, ds:[si]
    xor     ch, ch
    inc     si
    mov     bx, 10
    xor     ax, ax
    
@@Loop:
    mul     bx         
    mov     [di], ax   
    cmp     dx, 0      
    jnz     @@Error
    mov     al, [si]   
    cmp     al, '0'
    jb      @@Error    
    cmp     al, '9'
    ja      @@Error    
    sub     al, '0'
    xor     ah, ah
    add     ax, [di]
    jc      @@Error    
    inc     si
    loop    @@Loop     
    mov     [di], ax
    clc
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
    lea     dx, InDividend
    mov     ah, 09h
    int     21h
    mov     ah, 0Ah
    mov     dx, offset KeyBuf
    int     21h
    lea     dx, CR_LF
    mov     ah, 09h
    int     21h
    lea     si, KeyBuf+1
    lea     di, Dividend
    call    Str2Num
    jnc     @@NoError
    lea     dx, Error01
    mov     ah, 09h
    int     21h
    jmp     @@Exit

@@NoError:
    lea     dx, TextDividend  
    mov     ah, 09h
    int     21h
    mov     ax, Dividend
    mov     cx, 10
    call    Show_ax
    lea     dx, CR_LF
    mov     ah, 09h
    int     21h
    lea     dx, InDivider
    mov     ah, 09h
    int     21h
    mov     ah, 0Ah
    mov     dx, offset KeyBuf
    int     21h
    lea     dx, CR_LF
    mov     ah, 09h
    int     21h
    lea     si, KeyBuf+1
    lea     di, Divider
    call    Str2Num
    jnc     @@NoError2
    lea     dx, Error01
    mov     ah, 09h
    int     21h
    jmp     @@Exit
    
@@NoError2:    
    lea     dx, TextDivider
    mov     ah, 09h
    int     21h
    mov     ax, Divider
    mov     cx, 10
    call    Show_ax
    lea     dx, CR_LF
    mov     ah, 09h
    int     21h
        
    mov     dx,0  
    mov     ax,Dividend
    mov     bx,Divider        
    div     bx 
    mov     Result,ax
    lea     dx, TextResult
    mov     ah, 09h
    int     21h 
    mov     ax, Result
    mov     cx, 10
    call    Show_ax
    lea     dx, CR_LF
    mov     ah, 09h
    int     21h 
    lea     dx, CR_LF
    mov     ah, 09h
    int     21h
        
@@Exit:
    mov     ah, 01h
    int     21h
    mov     ax, 4c00h
    int     21h
    
Main    ENDP
END     Main

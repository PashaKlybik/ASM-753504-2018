.model small
.stack 100
.data
    flag                      dw          0

    old                       dd          0
    old_2fh                   dd          0

    us                        db          'Keybord handler',10,13
                              db          'Click ''L'' for load handler',10,13
                              db          'Click ''E'' for exit',10,13
                              db          'Type: ', '$'
    load                      db          10,13,'Loaded!', 10,13,'$' 
    abort                     db          10,13,'Exit!', 10,13,'$' 
    alload                    db          10,13,'Error! Handler already loaded and active!', 10,13,'$'
    kbstate                   db          ?

    counter                   dw          ?
    symbol                    dw          0    
.code
.486
;-------------------------------------------------
jmp main

    position                  dw          0
;------------------------------------------------- ????? ???????
delete proc
     
    xor dx, dx
    mov ax, bx
    mov bx, 10
    div bx
    mov bx, ax
    push bx    
    
    
    mov bh, 0
    mov ah, 03h
    int 10h
    
    mov ah, 02h
    int 10h
    
    mov ah, 02h
    mov dl, 32
    int 21h

    mov ah, 03h
    int 10h
    
    dec dl
    
    mov ah, 02h
    int 10h 
   
    pop bx
delete endp


One_proc  proc

    mov symbol, CX

    cmp CL, 2ch
    jne J_A
    mov CX, 'z'
    inc counter
    call delete

J_A:
    cmp CL, 1eh
    jne J_B
    mov CX, 'a'
    jmp J_vowel

J_B:
    cmp CL, 30h
    jne J_C
    mov CX, 'b'
    inc counter
    call delete

J_C:
    cmp CL, 2eh
    jne J_D
    mov CX, 'c'
    inc counter
    call delete

J_D:
    cmp CL, 20h
    jne J_E
    mov CX, 'd'
    inc counter
    call delete

J_E:
    cmp CL, 12h
    jne J_F
    mov CX, 'e'
    jmp J_vowel

J_F:
    cmp CL, 21h
    jne J_G
    mov CX, 'f'
    inc counter
    call delete

J_G:
    cmp CL, 22h
    jne J_H
    mov cx, 'g'
    inc counter
    call delete

J_H:
    cmp CL, 23h
    jne J_I
    mov CX, 'h'
    inc counter
    call delete

J_I:
    cmp CL, 17h
    jne J_J
    mov CX, 'i'
    jmp J_vowel

J_J:
    cmp CL, 24h
    jne J_K
    mov CX, 'j'
    inc counter
    call delete

J_K:
    cmp CL, 25h
    jne J_L
    mov CX, 'k'
    inc counter
    call delete

J_L:
    cmp CL, 26h
    jne J_M
    mov CX, 'l'
    inc counter
    call delete

J_M:
    cmp CL, 32h
    jne J_N
    mov CX, 'm'
    inc counter
    call delete

J_N:
    cmp CL, 31h
    jne J_O
    mov CX, 'n'
    inc counter
    call delete

J_O:
    cmp CL, 18h
    jne J_P
    mov CX, 'o'
    jmp J_vowel

J_P:
    cmp CL, 19h
    jne J_Q
    mov CX, 'p'
    inc counter
    call delete

J_Q:
    cmp CL, 10h
    jne J_R
    mov CX, 'q'
    inc counter
    call delete

J_R:
    cmp CL, 13h
    jne J_S
    mov CX, 'r'
    inc counter
    call delete

J_S:
    cmp CL, 1fh
    jne J_T
    mov CX, 's'
    inc counter
    call delete

J_T:
    cmp CL, 14h
    jne J_U
    mov CX, 't'
    inc counter
    call delete

J_U:
    cmp CL, 16h
    jne J_V
    mov CX, 'u'
    jmp J_vowel

J_V:
    cmp CL, 2fh
    jne J_W
    mov CX, 'v'
    inc counter
    call delete

J_W:
    cmp CL, 11h
    jne J_X
    mov CX, 'w'
    inc counter
    call delete

J_X:
    cmp CL, 2dh
    jne J_Y
    mov CX, 'x'
    inc counter
    call delete

J_Y:
    mov CX, 'y'

J_vowel:
    mov bl, kbstate
    and bl, 01h
    mov bh, kbstate
    and bh, 02h
    shr bh, 1   
    or bl, bh
    mov bh, kbstate
    and bh, 40h
    shr bh, 6
    xor bl, bh 
    jz J_vowel_end
    sub cx, 32
    jmp J_vowel_end

J_consonant:
    mov bl, kbstate
    and bl, 01h
    mov bh, kbstate
    and bh, 02h
    shr bh, 1   
    or bl, bh
    mov bh, kbstate
    and bh, 40h
    shr bh, 6
    xor bl, bh 
    jz J_consonant_check
    sub CX, 32

J_consonant_check:
    cmp counter, 3
    jne J_consonant_end
    mov counter, 0

    mov CX, symbol

    cmp CL, 2ch
    jne J_A_check
    mov CX, 'a'
    jmp J_consonant_end

J_A_check:
    cmp CL, 1eh
    jne J_B_check
    mov CX, 'b'
    jmp J_consonant_end

J_B_check:
    cmp CL, 30h
    jne J_C_check
    mov CX, 'c'
    jmp J_consonant_end

J_C_check:
    cmp CL, 2eh
    jne J_D_check
    mov CX, 'd'
    jmp J_consonant_end

J_D_check:
    cmp CL, 20h
    jne J_E_check
    mov CX, 'e'
    jmp J_consonant_end

J_E_check:
    cmp CL, 12h
    jne J_F_check
    mov CX, 'f'
    jmp J_consonant_end

J_F_check:
    cmp CL, 21h
    jne J_G_check
    mov CX, 'g'
    jmp J_consonant_end

J_G_check:
    cmp CL, 22h
    jne J_H_check
    mov cx, 'h'
    jmp J_consonant_end

J_H_check:
    cmp CL, 23h
    jne J_I_check
    mov CX, 'i'
    jmp J_consonant_end

J_I_check:
    cmp CL, 17h
    jne J_J_check
    mov CX, 'j'
    jmp J_consonant_end

J_J_check:
    cmp CL, 24h
    jne J_K_check
    mov CX, 'k'
    jmp J_consonant_end

J_K_check:
    cmp CL, 25h
    jne J_L_check
    mov CX, 'l'
    jmp J_consonant_end

J_L_check:
    cmp CL, 26h
    jne J_M_check
    mov CX, 'm'
    jmp J_consonant_end

J_M_check:
    cmp CL, 32h
    jne J_N_check
    mov CX, 'n'
    jmp J_consonant_end

J_N_check:
    cmp CL, 31h
    jne J_O_check
    mov CX, 'o'
    jmp J_consonant_end

J_O_check:
    cmp CL, 18h
    jne J_P_check
    mov CX, 'p'
    jmp J_consonant_end

J_P_check:
    cmp CL, 19h
    jne J_Q_check
    mov CX, 'q'
    jmp J_consonant_end

J_Q_check:
    cmp CL, 10h
    jne J_R_check
    mov CX, 'r'
    jmp J_consonant_end

J_R_check:
    cmp CL, 13h
    jne J_S_check
    mov CX, 's'
    jmp J_consonant_end

J_S_check:
    cmp CL, 1fh
    jne J_T_check
    mov CX, 't'
    jmp J_consonant_end

J_T_check:
    cmp CL, 14h
    jne J_U_check
    mov CX, 'u'
    jmp J_consonant_end

J_U_check:
    cmp CL, 16h
    jne J_V_check
    mov CX, 'v'
    jmp J_consonant_end

J_V_check:
    cmp CL, 2fh
    jne J_W_check
    mov CX, 'w'
    jmp J_consonant_end

J_W_check:
    cmp CL, 11h
    jne J_X_check
    mov CX, 'x'
    jmp J_consonant_end

J_X_check:
    cmp CL, 2dh
    jne J_Y_check
    mov CX, 'y'
    jmp J_consonant_end

J_Y_check:
    mov CX, 'z'

J_consonant_end:
    mov bl, kbstate
    and bl, 01h
    mov bh, kbstate
    and bh, 02h
    shr bh, 1   
    or bl, bh
    mov bh, kbstate
    and bh, 40h
    shr bh, 6
    xor bl, bh 
    jz J_skip_this
    sub cx, 32

J_skip_this:
    ret

J_vowel_end: 
    int 16h
    ret

One_proc endp
;-------------------------------------------------        
new_handle proc        
    push ds si es di dx cx bx ax 
        
    xor ax, ax 
    in  al, 60h
    push ax 
    mov ah, 02h
    int 16h  
    mov kbstate, al
    pop ax
        
        mov cl,al
        cmp al, 32h       
        ja old_handler    
        cmp al, 10h       
        jb old_handler    
        cmp al, 1ah       
        je old_handler    
        cmp al, 1bh        
        je old_handler    
        cmp al, 1ch       
        je old_handler    
        cmp al, 1dh       
        je old_handler    
        cmp al, 27h       
        je old_handler    
        cmp al, 28h       
        je old_handler    
        cmp al, 29h       
        je old_handler    
        cmp al, 2ah       
        je old_handler    
        cmp al, 2bh       
        je old_handler  
          
        
        inc position
        mov ax, position
        cmp ax, 1
        je new
        jmp old_handler
        
new:
    dec position
    mov AH, 5
    call One_proc
    int 16h
    ;cmp symbol, 0
    ;jne J_skip_this
    ;mov CX, symbol

    ;J_skip_this:
    ;int 16h
        
        new_handler:
        jmp exit
        
        
        old_handler: 
               pop ax bx cx dx di es si ds                       
               jmp dword ptr cs:old
                
        exit:
                xor ax, ax
                mov al, 20h
                out 20h, al 
                pop ax bx cx dx di es si ds
        iret
new_handle endp

new_2fh proc
    cmp ah,0f1h 
    jne out_2fh 
    cmp al,00h 
    je inst 
    cmp al,01h  
    je off 
    jmp short out_2fh  
    inst: mov al,0ffh  
    iret    
out_2fh:
jmp cs:old_2fh 

off: push ds
push es
push dx
push ax
push bx
push cx

pop cx
pop bx
pop ax

mov ax,2509h   
lds dx,cs:old   
int 21h

mov ax,252fh    
lds dx,cs:old_2fh   
int 21h

mov es,cs:2ch  
mov ah,49h 
int 21h

push cs
pop es
mov ah,49h  
int 21h

pop dx
pop es
pop ds
iret   
new_2fh endp   


new_end:
;------------------------------------------------- ????? ????? 
main:
    mov AX, @data                       ;
    mov DS, AX                          ; ?????????? ?????? ? ?????????? DS ? ES
    mov ES, AX                          ;
        

    mov counter, 0
    lea DX, us                          ; ????????? ?????? ?? ?????? us ? ??????? DX
    mov AH, 09h                         ; ????????? ? ??????? AH ??????? ?????? ??????
    int 21h                             ; ????? ???????
    mov ah, 01h                         ; ????????? ? ??????? AH ??????? ????? ???????
    int 21h                             ; ????? ???????
    cmp AL, 'L'                         ; ????????? ???????? ? ???????? AL ? 'L'
    je J_to_l                           ; ?????? ? ????? J_L ??? ????????
    cmp AL, 'l'                         ; ????????? ???????? ? ???????? AL ? 'l'
    jne J_quick_exit                    ; ?????? ? ????? J_quick_exit ??? ????????

setflag1:
    inc flag                            ; ?????????????? ?????????? flag
        
J_to_l:
    mov AH, 0f1h                        ; ???????????? ?????? ??????????????? ???????? ??? f1h
    mov AL, 0                           ; ???????????? ?????? ?????????? ??? 0
    int 2fh                             ; ????? ???????
    cmp AL, 0ffh                        ; ????????? ???????? ???????? AL ? 0ffh (???? ??????????)
    jne J_la                            ; ?????? ? ????? J_la ??? ???????????
    lea DX, alload                      ; ????????? ?????? ?? ?????? alload ? ??????? DX
    mov AH, 09h                         ; ????????? ? ??????? AH ??????? ?????? ??????
    int 21h                             ; ????? ???????
    jmp J_unload                        ; ?????? ? ????? J_unload
       
        
J_la:
    lea dx, load                        ; ????????? ?????? ?? ?????? load ? ??????? DX
    mov ah, 09h                         ; ????????? ? ??????? AH ??????? ?????? ??????
    int 21h                             ; ????? ???????
        
        
    cli

    pushf
    push 0       
    pop ds
    mov eax, ds:[09h*4] 
    mov ebx, ds:[2fh*4]
    mov cs:[old], eax 
    mov cs:[old_2fh], ebx
        
    mov ax, cs
    mov bx, cs
    shl eax, 16
    shl ebx, 16
    mov ax, offset new_handle
    mov bx, offset new_2fh
    mov ds:[09h*4], eax
    mov ds:[2fh*4], ebx
        
    sti
        
    xor AX, AX                          ; ??????? ???????? AX
    mov ah, 31h                         ;
    MOV DX, (New_end - @code + 10FH) / 16
    int 21h                             ; ????? ???????

J_unload: 
        mov ah, 4ch                     ; ???????? ? ??????? AH ??????? ?????????? ?????????
        int 21h                         ; ????? ???????
        
J_quick_exit:
        lea dx, abort
        mov ah, 09h
        int 21h
        
        mov ah, 4ch                     ; ???????? ? ??????? AH ??????? ?????????? ?????????
        int 21h                         ; ????? ???????
        
end main
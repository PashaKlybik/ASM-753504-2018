CSEG segment
assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG    
org 100h
Start:
    jmp Init    
;residental part
Int_21h_proc proc            ;our procedure that replaces/controls standard 09h
    cmp ah,9                 ;Is it 09h?
    je Is09h
    jmp dword ptr cs:[Int_21h_vect]     ;if no, to the original int21h
Is09h:        
 pushf
    push ax
    push cx
    push dx
    push si
    push di
    push cs        
    pop es            ;ds moves into es
    cld
    mov si, dx
    stringProcessing:
        lodsb
        cmp al, '$'
        je stringHasEnded
        lea di, vowels
        mov cx, 10
        repne scasb        ;compare al with es:di
        je stringProcessing
        mov dx, [si-1]
        mov ah, 02h
        int 21h
        jmp stringProcessing
    stringHasEnded:
    pushf
    call dword ptr cs:[Int_21h_vect]
    sti
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    popf
    iret
Int_21h_vect dd ?
Int_40h_vect dd ?
vowels db "aeiouAEIOU"
int_21h_proc endp


;the end of the residental part
installMessage db "Succesfully installed.",10,13,'$'

Init:
    mov ah,35h            ;function 35h 
    mov al,21h            ;saves vector of 21h to es(segment):bx(offset)
    int 21h
    mov word ptr Int_21h_vect,bx
    mov word ptr Int_21h_vect+2,es
    mov ax,2521h        ;installing our handler on 21h 
    mov dx,offset Int_21h_proc ;ds:dx = handler
    int 21h
    mov ah, 9
    lea dx, installMessage
    int 21h 
    mov dx,offset Init
    int 27h        ;makes it residental (init = last byte)
CSEG ends
end Start
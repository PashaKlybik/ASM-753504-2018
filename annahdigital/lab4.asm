.model small
.stack 256
.data
counter dw 0
trySymbol db ?
maxLength db 80
string  db  100 dup ('$'),'$'
vowels db "AEIOUaeiou",0
stringLength dw 0
blankMessage db 10,13, "$" 
.code

;for outputting the number of words that begin with a vowel
print PROC    
    push ax
    push bx    
    push cx    
    push dx    
        
    mov bx,10
    xor cx,cx

    cycle1:
    xor dx,dx
    div bx
    inc cx
    push dx
    cmp ax,0
    JNZ cycle1

    cycle2:
    pop dx
    add dl,'0'
    mov ah,02h
    int 21h
    loop cycle2

    pop dx
    pop cx
    pop bx
    pop ax
    RET
print endp

searchForVowels proc
    push ax    
    push cx    
    push dx    
    push di
    push es
    
    xor ax,ax
    mov cx,10
    mov al,trySymbol
    lea di,vowels
    cld
    repne scasb
    jnz endIt
    inc counter
    
    endIt:
    pop es
    pop di
    pop dx
    pop cx
    pop ax
    RET
searchForVowels endp
    
findStart proc
    push ax    
    push cx        
    push di
    push es

    cld
    mov al,string[2]
    mov trySymbol,al
    call searchForVowels
    
    mov cx,stringLength
    inc cx
    lea di,string
    cld
    
    cycle3:
    mov al,32    ;space
    repnz scasb     
    jnz toTheEnd
    mov al,es:di
    mov trySymbol,al
    call searchForVowels
    jmp cycle3
    
    toTheEnd:
    pop es
    pop di
    pop cx
    pop ax
    RET
findStart endp
    
main:

    mov ax, @data
    mov ds, ax
    mov es,ax
    
    lea bx,maxLength
    mov ah, 0ah          
    lea dx,string
    int 21h 
    
    xor ax,ax
    mov al, byte[string]
    mov stringLength,ax
    
    call findStart
    
    mov dx,offset blankMessage
    mov ah,09h
    int 21h
    
    mov ax,counter
    call print
    
    mov dx,offset blankMessage
    mov ah,09h
    int 21h
    
    mov ax, 4c00h
    int 21h

end main
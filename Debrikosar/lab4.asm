.model small
.stack 256
.data
    errorStr db 'Error', 13, 10,'$'
    inputBuffer db 99, 100 dup ('$')
    strLength dw ?
    Vowels db 'AaEeIiOoUu',0
    endStr db 13, 10, '$'
    outputBuffer db 25 dup (' '),'$'

.code
сleanScreen PROC    ;Screen cleaning procedure 
    mov ax, 0600h
    mov bh, 07
    mov cx, 0000
    mov dx, 184Fh
    int 10h
  
    mov ax, 02h
    xor dx, dx  
    int 10h
сleanScreen ENDP

wordToStr PROC              ;Convert word to string   
    push ax
    push bx
    push cx
    push dx
    push di
  
    xor cx, cx
    mov bx, 10
    remainder:               ;remainder cycle
        xor dx, dx
        div bx
        add dl,'0'
        push dx                 
        inc cx
        test ax, ax
        jnz remainder

    extraction:              ;extract from stack
        pop dx 
        mov [di], dl
        inc di
        loop extraction         
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret 
wordToStr ENDP

printStr PROC
    push ax 
    mov ah, 9                 
    int 21h  
    pop ax
    ret
printStr ENDP

clear PROC
    push cx
    mov cx, 7 
    following:
        mov [di], ' '            ;Clear Buff       
        inc di              
        loop following    
    pop cx
    ret 
clear ENDP

inputStr PROC               ;Enter String
    push ax
    push dx
    mov ah, 0aH
    lea dx, inputBuffer
    int 21h
    xor ax, ax
    mov al, [inputBuffer+1]
    mov strLength, ax
    pop dx
    pop ax
    ret
inputStr ENDP

searchVowels PROC          ;Search for vowels
  push ax
  push cx
  push di
  push es

  xor ax, ax
  xor bx, bx                        
  cld
  mov cx, 10
  mov al, [si]
  lea di, Vowels
  repne scasb
  jne endSearchVowels
  inc bx

  cld
  mov cx, 10
  mov al, [si+1]
  lea di, Vowels
  repne scasb
  jne endSearchVowels 
  inc bx

  endSearchVowels:  
  pop es
  pop di
  pop cx
  pop ax
  ret
searchVowels ENDP

search PROC
  push ax
  push bx
  push cx
  push dx
  push di
  push si
    
  xor dx, dx
  xor bx, bx
  xor cx, cx 
  mov cx, [strLength]
  lea si, inputBuffer+2
  lea di, outputBuffer
  mark:
    xor ax, ax
    mov al, [si]
    mov [di], al
    cmp al, 32
    je space
    call searchVowels
    cmp bx, 2
    jc backSearch                          
    mov dx, bx
 
  backSearch:
    inc si
    inc di
    loop mark

    cmp dx, 1 
    jc  endSearch
    lea dx, outputBuffer
    call printStr
    lea di, outputBuffer
    call clear
    lea dx, endStr           
    call printStr
    jmp endSearch  
  
  space:
    cmp dx, 2 
    jc  next
    lea dx, outputBuffer
    call printStr
    lea dx, endStr           
    call printStr
  next:
    lea di, outputBuffer
    call clear
    lea di, outputBuffer
    xor dx, dx
    jmp backSearch
  endSearch:
  pop si
  pop di
  pop dx
  pop cx
  pop bx
  pop ax
ret
search ENDP
 
main:
    mov ax, @data
    mov ds, ax  
    mov es, ax
    call сleanScreen
    call inputStr 
    lea dx, endStr
    call printStr
    call search
    mov ax, 4c00h
    int 21h
end main
.model small
.stack 256
.data

message1 db 'Enter your text here:', 10, 13, '$'
maxLength db 254
len db 0
string db 253 dup(?)

.code

proc vowelStartWordAmount
    push ax
    push cx
    push dx 
    push di

    mov ah, 0ah ; получаем пользовательскую строку не более максимальной длины
    lea dx, maxLength
    int 21h
    xor bx, bx ; в bx будет количество слов, начнающихся с гласной
    xor ch, ch
    mov cl, len
    test cl, cl
    jz emptyString
    lea di, string
    cld
    mov cl, len

skipWhitespaces:
    mov al, ' '
    repe scasb
    dec di
    inc cx

checkVowel:
    jcxz endOfTheText
    mov al, [di]
    cmp al, 'A'  
    jz vowel
    cmp al, 'a'
    jz vowel
    cmp al, 'E'
    jz vowel
    cmp al, 'e'
    jz vowel
    cmp al, 'I'
    jz vowel
    cmp al, 'i'
    jz vowel
    cmp al, 'O'
    jz vowel
    cmp al, 'o'
    jz vowel
    cmp al, 'U'
    jz vowel
    cmp al, 'u'
    jnz skipTheRestLetters

vowel:
    inc bx

skipTheRestLetters:
    mov al, ' '
    repne scasb
    jcxz endOfTheText
    jz skipWhitespaces
    jmp endOfTheText

emptyString:
    mov bx, 0
    pop di
    pop dx
    pop cx
    pop ax
    ret

endOfTheText:
    pop di
    pop dx
    pop cx
    pop ax
    ret
endp

proc newLine
    push ax
    push dx

    mov dl, 0ah
    mov ah, 02h
    int 21h

    pop dx
    pop ax
    ret
endp

main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    mov ah, 09h
    lea dx, message1
    int 21h

    call vowelStartWordAmount
    push dx
    call newLine
    xor dx, dx
    mov dx, bx
    add dx, '0'
    mov ah, 02h
    int 21h
    call newLine
    pop dx

    mov ax, 4c00h
    int 21h

end main

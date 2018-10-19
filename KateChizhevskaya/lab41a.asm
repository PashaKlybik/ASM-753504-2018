.model small; вариант 4, найти и показать самое длинное слово
.stack 256
.data
    lengthMax  db 100
    lengthReal db ?
    firstPosition dw ?
    lastPosition dw ?
    result db ?
    char db ?
    wordMax db 100 dup('$'),'$'
    wordMaxLength dw 0
	maxWordFirstPosition dw 0
    string db 99, 100 dup ('$')
    newLine db 13, 10, '$'
.code

output proc
   push ax
   push dx
   push si
   push di
   push cx
   mov cx, wordMaxLength
   mov si,maxWordFirstPosition
   lea di, wordMax
   cld
   cycle1:
        lodsb
        stosb
        xor al,al
   loop cycle1
   mov dx,offset wordMax
   mov ah,9
   int 21h
   pop cx
   pop di
   pop si
   pop dx
   pop ax
   ret
endp

input proc 
    push ax
    push dx
    mov ah,0ah
    lea dx, string
    int 21h
    mov ah, 9
    mov dx, offset newLine
    int 21h 
    pop dx
    pop ax
    ret
input endp

check proc
    push di
    push bx
    push ax
    dec di
    mov lastPosition, di
    mov ax,lastPosition
    mov bx, firstPosition
    sub ax,bx
    cmp ax, wordMaxLength
    JLE endCheck
    call change
    endCheck:
    pop ax
    pop bx
    pop di
    ret
check endp

change proc
	push cx
    mov wordMaxLength,ax
	mov cx, firstPosition
	mov maxWordFirstPosition, cx
	pop cx
    ret
change endp

main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    call input
    lea di, string
    inc di
    mov al, [di]
    mov lengthReal,al
    inc di
    mov cl, lengthReal
    mov al,' '
    cld
    beginAnalysis:
        mov firstPosition, di
        repne scasb		
        cmp cx,0
        jz toInc
        toFound:
        call check
        cmp cx,0
        JZ toOutput
    jmp beginAnalysis
    toOutput:
        call output
    jmp endProgramm

    ToInc:
    inc di
    jmp toFound

endProgramm:
    mov ax, 4c00h
    int 21h   
end main	
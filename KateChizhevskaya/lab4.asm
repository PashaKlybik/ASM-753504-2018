.model small; âàðèàíò 4, íàéòè è ïîêàçàòü ñàìîå äëèííîå ñëîâî
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
    string db 100 dup ('$')
    newLine db 13, 10, '$'
.code

output proc
    push ax
    push dx
    mov dx,offset wordMax
    mov ah,9
    int 21h
    pop dx
    pop ax
    ret
endp

input proc 
    push ax
    push dx
    push bx
    lea bx,lengthMax
    mov ah,0ah
    lea dx,string
    int 21h
    mov ah, 9
    mov dx, offset newLine
    int 21h 
    pop bx
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
    push di
    push ax
    push dx
    push si
    mov cx,lastPosition
    sub cx,firstPosition
    mov wordMaxLength,cx
    mov si,di
    sub si, cx
    inc cx
    cld
    lea di, wordMax
    cld
    cycle1:
        lodsb
        stosb
        xor al,al
    loop cycle1
    pop si
    pop dx
    pop ax
    pop di
    pop cx
    ret
change endp

main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    call input
    xor ax,ax
    lea di, string
    inc di
    mov al, [di]
    mov lengthReal,al
    inc di
    xor cx,cx
    mov cl, lengthReal
    mov al,' '
    cld
    beginAnalysis:
		mov firstPosition, di
		repne scasb
		jmp found
    return:
		cmp cx,0
		JZ toOutput
    jmp beginAnalysis
    toOutput:
        call output
    jmp endProgramm

found:
    call check
    jmp return
endProgramm:
    mov ax, 4c00h
    int 21h   
end main	
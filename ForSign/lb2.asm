.model small
.stack 256
.data
    numberSystem dw 10
    errorStr db 'Error!$'
    endLine db 13, 10, '$'
    outputBuffer db '     ',13, 10,'$'
    strDiv db '/',13, 10,'$'
    strInt db 'Integer:',13, 10,'$'
    strRemainder db 'Remainder:',13, 10,'$'
    errorStrZero db 'Enter Number:',13, 10,'$'
    errorStrOverflow db 'Overflow!',13, 10,'$'
    errorStrInvalidSymbol db 'This symbol is not supported!',13, 10,'$'
.code

wordToStr PROC
  push ax
  push bx
  push cx
  push dx
  push di

  mov di, offset outputBuffer
  xor cx,cx
  remainder:                ;Division remainder
    xor dx,dx
    div numberSystem
    add dl,'0'
    push dx
    inc cx                  ;Symbol count
    test ax,ax
    jnz remainder           ;Again if not 0.
  extraction:
    pop dx
    mov [di],dl             ;SymbolBuffer
    inc di
    loop extraction

  pop di
  pop dx
  pop cx
  pop bx
  pop ax
ret
wordToStr ENDP

input PROC
  push bx
  push cx
  push dx

  xor bx,bx

iterate:  ;looped
    xor di,di
    mov ah,01h
    int 21h
    cmp  al,8                  ;cmp Backspace
    je bckspace
    cmp al,13                  ;cmp Enter
    je enterentry
    cmp al,27                  ;cmp Escape
    je escape
    sub al,'0'
    cmp al,9                   ;if dcecimal
    ja exceptionInvalidSymbol
    test al,al                 ;if zero before do not count this
    je zero
continue:
    xor cx,cx
    mov cl,al
    mov ax,bx                  ;Result of last iteration
    mul numberSystem
    cmp dx,0
    jnz exceptionOverflow
    add ax,cx
    jc  exceptionOverflow
    mov bx,ax                  ;Bx is now inputted number
    jmp iterate

enterentry:
    test bx,bx
    je exceptionNull
    mov ax,bx
    jmp endinput

bckspace:
    xchg bx,ax
    xor dx,dx
    div numberSystem            ;Stack division
    xchg bx,ax
    call remove
    jmp iterate

escape:
    xor bx,bx
    mov cx,6
    cleaning:
    mov dl,8
    mov ah,02h                   ;CleanAll
    int 21h
    call remove
    loop cleaning
    cmp di,1                     ;SomethingCheck :)
    je InvalidSymbol
    cmp di,2
    je Overflow
    jmp iterate

exceptionInvalidSymbol:
    mov di,1
    jmp escape
    InvalidSymbol:
    mov dx, offset errorStrInvalidSymbol
    call printStr
    jmp iterate

exceptionOverflow:
    mov di,2
    jmp escape
    Overflow:
    mov dx,offset errorStrOverflow
    call printStr
    jmp iterate

zero:
    cmp bx,0
    jmp continue                 ;Redefenition
    mov dl,8
    mov ah,02h                   ;Delete symbol
    int 21h
    call remove
    jmp iterate

exceptionNull:
    mov dx,offset errorStrZero
    call printStr
    jmp iterate

endinput:
  pop dx
  pop cx
  pop bx
  ret
input ENDP

clearBuffer PROC
                                                                    ; use di to get address !!!
  push cx
  mov cx,6
  following:
    mov [di],' '
    inc di
    loop following 	;Clear_SymbolBuffer
  pop cx
ret
clearBuffer ENDP

remove PROC
    push ax
    push bx
    push cx

    mov ah, 0AH   ;SymbolEntryPointer
    mov bh, 0
    mov al, ' '   ;Outputsymbol
    mov cx, 1     ;number of symbols
    int 10h

    pop cx
    pop bx
    pop ax
    ret
remove ENDP


printStr PROC
    push ax
    mov ah,9
    int 21h
    pop ax
ret
printStr ENDP

main:
    mov ax, @data
    mov ds, ax

    mov ax,02h
    xor dx,dx
    int 10h                     ; Starter Pointer

    call input              ; First number beckap
    xchg ax,bx

    push dx
    mov dx,offset strDiv
    call printStr
    pop dx

    call input              ; Division after getting next number
    xchg ax,bx
    div bx
    mov bx,dx

    mov dx,offset strInt
    call printStr
    call wordToStr                 ;Throw Integer
    mov dx,offset outputBuffer
    call printStr

    mov di,offset outputBuffer     ; Just did :)
    call clearBuffer

    mov dx,offset strRemainder
    call printStr
    mov ax,bx
    call wordToStr                  ;Throw Remainder
    mov dx,offset outputBuffer
    call printStr

    mov ax, 4c00h
    int 21h
end main

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

    xor cx,cx
    mov bx,10
    remainder:
    xor dx,dx
    div bx
    add dl,'0'
    push dx
    inc cx                  ;Symbol Count
    test ax,ax
    jnz remainder           ;Again if not0.

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
  push di
  push si

  xor bx,bx                    ;Storage
  xor si,si                    ;This allows us to save minus (if it is)

  jmp iterate
zero:
    cmp bx,0
    jmp continue                 ;Redefenition
    mov dl,8
    mov ah,02h                   ;Delete symbol
    int 21h
    call remove
    jmp iterate

signDelete:
    cmp si,0
	je positive
	mov si,0
	jmp positive

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
    cmp al,'-'                 ; cmp Minus
    je minus
    sub al,'0'
    cmp al,9                   ;if dcecimal
    ja exceptionInvalidSymbol
    test al,al
    test al,al                 ;if zero before do not count this
    je zero
continue:
    xor cx,cx
    mov cl,al
    mov ax,bx                       ;Result of last iteration
    mul numberSystem
    cmp dx,0
    jne exceptionOverflow
    add ax,cx
    jb  exceptionOverflow
    cmp si,1
    je negative
    cmp ax,32767
    jnbe exceptionOverflow
back:
    mov bx,ax                  ;Bx is now inputted number
    jmp iterate

enterentry:
    test bx,bx
	je exceptionNull
    mov ax,bx
    cmp si,1                   ;if plus -> end input
    jne endinput
    neg ax                     ;ax plus -> ax minus
	jmp endinput

bckspace:
    test bx,bx
	je signDelete
  positive:
    xchg bx,ax
    xor dx,dx
    div numberSystem            ;Stack division
    xchg bx,ax
    call remove
    jmp iterate

escape:
    xor bx,bx
	xor si,si
    mov cx,7
  cleaning:
    mov dl,8
    mov ah,02h                   ;CleanAll
    int 21h
    call remove
    loop cleaning
    cmp di,1                     ;Check perekritie
    je InvalidSymbol
    cmp di,2
    je Overflow
    jmp iterate

minus:
	cmp bx,0                      ;NumPosition
	jne exceptionInvalidSymbol
	cmp si,0
	jne exceptionInvalidSymbol
    mov si,1
	jmp iterate                   ;ContinueEntering

negative:
    cmp ax,32768
    jnbe exceptionOverflow
    jmp back                            ;IfNormal

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

exceptionNull:
	mov dx,offset errorStrZero
	call printStr
	jmp iterate

endinput:
  pop si
  pop di
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
    loop following  ;Clear_SymbolBuffer
  pop cx
ret
clearBuffer ENDP

signWordToStr PROC
    push ax
    mov di, offset outputBuffer
    test ax,ax              ;check sign
    jns notSign             ;if >= -> throw through sign computing
    mov [di],'-'
    inc di
    neg ax                  ;Ax -> negative
    notSign:
    call wordToStr          ;Unsinged confirmation
    pop ax
ret
signWordToStr ENDP

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


exception PROC
    cmp bx,-1
	jnz notException
    lea dx,errorStr
    call printStr                ;Exception if 32767 >= (-32768/-1)
    mov ax, 4c00h
    int 21h
ret
exception ENDP

main:
    mov ax, @data
    mov ds, ax

    mov ax,02h
    xor dx,dx
    int 10h                     ; Starter Pointer

    call input              ; First number beckap
    xchg ax,bx

	push dx
	lea dx,strDiv
    call printStr
    pop dx

    call input              ;Division after getting next number
    xchg ax,bx

	cmp ax,-32768
	je exception
  notException:

	cmp ax,0                    ;using obratniy code so checking if there's no error
    jl point1
    jmp point2
    point1:
    cwd
    point2:
    idiv bx                     ;Division

    mov bx,dx                   ;Here's reminder

    lea dx,strInt
    call printStr
    call signWordToStr             ;decimal
    lea dx,outputBuffer
    call printStr

    lea di,outputBuffer         ;ClearBuffer
    call clearBuffer

    lea dx,strRemainder
    call printStr
    mov ax,bx                       ;Reminder
	test ax,ax                      ;if (<0) -> to decimal positive
	jns allGood
	neg ax                          ; minus to plus
	allGood:
	lea di,outputBuffer                ; // Throw answers
    call wordToStr
    lea dx,outputBuffer
    call printStr

    mov ax, 4c00h
    int 21h
end main

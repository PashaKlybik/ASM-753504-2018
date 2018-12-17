.model small
.stack 256
.data
    systemOfNotation dw 10
    errorIsZero db 'Write POSITIVE & INTEGER value',13, 10,'$'
    errorIsOverflow db 'Sorry, but this number is too large!',13, 10,'$'
    errorIsInvalidSymbol db 'It is a wrong symbol',13, 10,'$'
    strDivMark db '/',13, 10,'$'
    strIntMark db 'The integer part:',13, 10,'$'
    strRemainderMark db 'The Remainder part:',13, 10,'$'
    endLine db 13, 10, '$'
    cleanBuffer db '      ',13, 10,'$'
.code


ShowStr PROC  ;the address of the string passed through dx
    push ax 
    mov ah,9                 
    int 21h  
    pop ax
ret
ShowStr ENDP

clearBuffer PROC ;the address of the buffer passed through di
  push cx
  mov cx,6 
  following:         
    mov [di],' '        
    inc di              
    loop following      
  pop cx
ret 
clearBuffer ENDP

convertToStr PROC           ;ax-word with number, di-buffer for string 
  push ax
  push bx
  push cx
  push dx
  push di
		
  mov di, offset cleanBuffer
  xor cx,cx                 
  remainder:                ;getting the remainder of the division
    xor dx,dx               ;Zeroing the high part of the double word
    div systemOfNotation    
    add dl,'0'              ;Conversion of the remainder to the character code
    push dx                 ;save it in stack
    inc cx                  ;incriminate count of numbers in number
    test ax,ax              ;if remainder isn't 0 then we have any numbers
    jnz remainder           ;and we will do this operation again.

  extractToBuffer:          ;extract numbers from stack to buffer
    pop dx                  
    mov [di],dl             
    inc di                 
    loop extractToBuffer          
 
  pop di
  pop dx
  pop cx
  pop bx
  pop ax
ret
convertToStr ENDP

deleteLastChar PROC        
    push ax
    push bx    
    push cx         
	
    mov ah, 0AH           ;write null symbol at the cursor position
    mov bh, 0
    mov al, ' '           
    mov cx, 1              
    int 10h       

    pop cx
    pop bx
    pop ax
    ret 
deleteLastChar ENDP

readNumber PROC  ;ax=writed number
  push bx
  push cx
  push dx
  
  xor bx,bx                     
  
goNextStr:                    ;while enter not pressed & not overflow 
    xor di,di                    
    mov ah,01h                 
    int 21h                      
    cmp  al,8                  ;is backSpace pressed?
    je isBackSpace
    cmp al,13                  ;is enter pressed?
    je isEnter  
    cmp al,27                  ;is escape pressed?
    je isEscape    
    sub al,'0'                 ;char to number
    cmp al,9                   ;is it decimal symbol?
    ja exceptionInvalidSymbol 
    test al,al                 ;if first symbol of number is 0 then goto exeption
    je isZero                  

goNextChar:
    xor cx,cx    
    mov cl,al   
    mov ax,bx                  ;save last char in ax 
    mul systemOfNotation
    cmp dx,0                   ;is overflow? 
    jnz exceptionOverflow
    add ax,cx
    jc  exceptionOverflow        
    mov bx,ax                  ;bx=writed number
    jmp goNextStr

isEnter:
    test bx,bx
    je exceptionNull           ;is str null? 
    mov ax,bx
    jmp endReadNumber           

isBackSpace:
    xchg ax,bx
    xor dx,dx
    div systemOfNotation       ;divide the number by 10 and take the integer part
    xchg ax,bx                 
    call deleteLastChar        
    jmp goNextStr
 
isEscape:
    xor bx,bx
    mov cx,6
    cleaning:
    mov dl,8
    mov ah,02h                   ;clean all 
    int 21h
    call deleteLastChar
    loop cleaning    
    cmp di,1                    
    je InvalidSymbol              
    cmp di,2
    je Overflow
    jmp goNextStr
	
exceptionInvalidSymbol:          ;if writed char isn't numeral
    mov di,1
    jmp isEscape
    InvalidSymbol:
    mov dx, offset errorIsInvalidSymbol
    call ShowStr
    jmp goNextStr

exceptionOverflow:               ;if number is too large
    mov di,2
    jmp isEscape
    Overflow:
    mov dx,offset errorIsOverflow      
    call ShowStr
    jmp goNextStr

isZero:                          ;if user writed beggining of string, but it is 0
    cmp bx,0
    jnz goNextChar                  
    mov dl,8
    mov ah,02h                   ;clean last char
    int 21h
    call deleteLastChar
    jmp goNextStr

exceptionNull:	                 ;if user press enter but buffer of number is clear 
    mov dx,offset errorIsZero    
    call ShowStr
    jmp goNextStr

endReadNumber:	
  pop dx
  pop cx
  pop bx
  ret
readNumber ENDP	

cleanWindow PROC
    mov ax,0600h
    mov bh,07
    mov cx,0000
    mov dx,184Fh
    int 10h    
    mov ax,02h
    xor dx,dx
    int 10h
ret
cleanWindow ENDP

main:
    mov ax, @data
    mov ds, ax
 
    ;call cleanWindow              
    call readNumber               ;get first number 
    xchg bx,ax                    ;first number to bx
	
    push dx                       ;save dx 
    mov dx,offset strDivMark       
    call ShowStr
    pop dx 	                      ;get dx
	
    call readNumber               ;get second number 
    xchg bx,ax                    
    div bx                         
    mov bx,dx                     ;remainder of division to bx 
 
    mov dx,offset strIntMark           
    call ShowStr
    call convertToStr             
    mov dx,offset cleanBuffer
    call ShowStr

    mov di,offset cleanBuffer     
    call clearBuffer               

    mov dx,offset strRemainderMark
    call ShowStr
    mov ax,bx                     ;show remainder
    call convertToStr
    mov dx,offset cleanBuffer
    call ShowStr 
 
    mov ax, 4c00h
    int 21h
end main
model small
stack 256
dataseg
  a dw ?
  b dw ?
  ten dw 10
  dividentMessage db "Enter the divident from the range: -32768..32767:$"
  divisorMessage db "Enter the divisor from the range: -32768..32767:$"
  errorSymbolMessage db ' - is not a numeric symbol!', 13, 10, '$'
  errorLengthMessage db 13, 10, 'Your input is not in the range -32768..32767!$'
  errorDivisionMessage db 'Division by zero is forbidden!$'
  operationResultMessage db "Operation result: $"

codeseg

;-----INPUT-----
Input proc
   push bx
   push cx
   push si
   xor si, si

   mov ah, 01h
   int 21h
   cmp al, '-'
   jne isPositive
   inc si

   read:
     mov ah, 01h
     int 21h
     isPositive:
     cmp al, 13
     je finalBlock
     cmp al, '0'
     lea dx, errorSymbolMessage
     jl Error
     cmp al, '9'
     lea dx, errorSymbolMessage
     jg Error

     sub al, '0'
     mov cl, al
     mov ax, bx
     mul ten
     cmp si, 0
     jne isNegative
            
     add ax, cx
     mov bx, ax
     cmp ax, 0
     lea dx, errorLengthMessage
     jl Error
     jmp read
     

   isNegative:
     sub ax, cx
     mov bx, ax
     cmp ax, 0
     lea dx, errorLengthMessage
     jg Error
     jmp read

   finalBlock:
     mov ax, bx
     pop si
     pop cx
     pop bx
     ret
 Input endp

 Error:
    mov ah, 09h
    int 21h
    mov ax, 4c00h
    int 21h

;-----OUTPUT-----
Output proc
   push bx
   push cx
   push dx
   xor cx, cx

    cmp ax, 0
    jg divide
    je divide
     push ax
     mov dx, '-'
     mov ah, 2
     int 21h
     pop ax
     neg ax

   divide:
     xor dx, dx
     div ten
     push dx
     inc cx
     test ax, ax
     jnz divide

   show:
     pop ax
     add ax, '0'
     mov dx, ax
     mov ah, 2
     int 21h
     loop show

    pop dx
    pop cx
    pop bx
    ret
Output endp

;-----NEW LINE-----
NewLine proc
   push ax
   push dx
   mov dx, 10
   mov ah, 2
   int 21h
   mov dx, 13
   mov ah, 2
   int 21h
   pop dx
   pop ax
   ret
NewLine endp

;-----MAIN-----
Main:
   mov ax, @data
   mov ds, ax

   lea dx, dividentMessage
   mov ah, 09h
   int 21h
   call NewLine
   call Input
   mov a, ax
   call Output
   call NewLine

   lea dx, divisorMessage
   mov ah, 09h
   int 21h
   call NewLine
   call Input
   mov b, ax
   call Output
   call NewLine

   cmp b, 0
   jz divisionByZero

   lea dx, operationResultMessage
   mov ah, 09h
   int 21h
   xor dx, dx
   mov ax, a
   cwd
   idiv b

   call Output
   call NewLine
   jmp endMain

   DivisionByZero:
     lea dx, errorDivisionMessage
     call NewLine
     mov ah, 09h
     int 21h

   EndMain:
     mov ax, 4c00h
     int 21h

end main

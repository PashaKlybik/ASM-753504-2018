model small
stack 256

dataseg
  a dw ?
  b dw ?
  ten dw 10
  dividentMessage db "Enter the divident (not more than 65,535):$"
  divisorMessage db "Enter the divisor (not more than 65,535):$"
  errorSymbolMessage db ' - is not a numeric symbol!', 13, 10, '$'
  errorLengthMessage db 'Your input exceeds 65,535!$'
  errorDivisionMessage db 'Division by zero is forbidden!$'
  operationResultMessage db "Operation result: $"

codeseg

;-----INPUT-----
 Input proc
   push bx
   push cx
   push dx
   read:
     mov ah, 01h
     int 21h

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
     add ax, cx
     mov bx, ax
     cmp dx, 0
     lea dx, errorLengthMessage
     jnz Error

     jmp read

   finalBlock:
     mov ax, bx
     pop dx
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
   div b

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

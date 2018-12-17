.model small 
.stack 256 
.data 
systemOfNotation dw 10 
error db 'error$' 
errorIsZero db 'Sorry, but integer number can not start from zero',13, 10,'$' 
errorIsOverflow db 'Sorry, but number is too large',13, 10,'$' 
errorIsInvalidSymbol db 'Sorry, it is a wrong symbol',13, 10,'$' 
endLine db 13, 10, '$' 
cleanBuffer db ' ',13, 10,'$' 
strDivMark db '/',13, 10,'$' 
strIntMark db 'The integer part:',13, 10,'$' 
strRemainderMark db 'The remainder part:',13, 10,'$' 
.code 

readNumber PROC                     ;ax = writed number 
push bx 
push cx 
push dx 
push di 
push si 

xor bx,bx                           
xor si,si                            

jmp goNextStr 
zero: 
cmp bx,0 
jnz goNextChar                      
mov dl,8 
mov ah,02h                         
int 21h 
call deleteLastChar 
jmp goNextStr 

signToPositive: 
cmp si,0 
je positive 
mov si,0 
jmp positive 

goNextStr:                          ;while enter not pressed
xor di,di                           
mov ah,01h                           
int 21h 

cmp al,8                            
je isBackSpace 

cmp al,13                           
je isEnter

cmp al,27                          
je isEscape 

cmp al,'-' 
je isMinus 
sub al,'0'
                                    
cmp al,9                            
ja exceptionInvalidSymbol 

test al,al                          
je zero                             

goNextChar: 
xor ch,ch 
mov cl,al 
mov ax,bx                            
mul systemOfNotation 

cmp dx,0                            
jne exceptionOverflow 

add ax,cx 
jb exceptionOverflow   
                                    
cmp si,1 
je isNegative 

cmp ax,32767                      
jnbe exceptionOverflow 

allIsNormal: 
mov bx,ax                           
jmp goNextStr 

isEnter: 

test bx,bx 
je exceptionNull                    
mov ax,bx 

cmp si,1                            
jne endReadNumber 

neg ax                              
jmp endReadNumber                   

isBackSpace: 

test bx,bx 
je signToPositive 
positive: 
xchg ax,bx 
xor dx,dx 
div systemOfNotation                  
xchg ax,bx                        
call deleteLastChar                     
jmp goNextStr 

isEscape: 
xor bx,bx 
xor si,si 
mov cx,7 

cleaningChars: 
mov dl,8 
mov ah,02h                         
int 21h 
call deleteLastChar 
loop cleaningChars 

cmp di,1                            
je isInvalidSymbol 

cmp di,2 
je isOverflow 
jmp goNextStr 

isMinus:                             
cmp bx,0                            
jne exceptionInvalidSymbol 

cmp si,0 
jne exceptionInvalidSymbol 

mov si,1 
jmp goNextStr                        

isNegative: 
cmp ax,32768                        
jnbe exceptionOverflow              
jmp allIsNormal                          

exceptionInvalidSymbol: 
mov di,1 
jmp isEscape 

isInvalidSymbol: 
mov dx, offset errorIsInvalidSymbol 
call printStr 
jmp goNextStr 

exceptionOverflow: 
mov di,2 
jmp isEscape

isOverflow: 
mov dx,offset errorIsOverflow 
call printStr 
jmp goNextStr 

exceptionNull: 
mov dx,offset errorIsZero       
call printStr 
jmp goNextStr 

endReadNumber: 
pop si 
pop di 
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
cleanWindow ENDP 

numberToStr PROC                     ;AX - number DI - Buffer 
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
inc cx                               
test ax,ax                           
jnz remainder                       

stackToBuffer:                       
pop dx                               
mov [di],dl                          
inc di                               
loop stackToBuffer 
pop di 
pop dx 
pop cx 
pop bx 
pop ax 
ret 
numberToStr ENDP 

signNumberToStr PROC                     ; AX - number DI - Buffer.
push ax 
mov di, offset cleanBuffer 
test ax,ax                          
jns isNotSign                       
mov [di],'-'                        
inc di                             
neg ax                              

isNotSign: 
call numberToStr                      
pop ax 
ret 
signNumberToStr ENDP 

printStr PROC                       
push ax 
mov ah,9 
int 21h 
pop ax 
ret 
printStr ENDP 

clearBuffer PROC                     
push cx 
mov cx,7  
clearNext:                          
mov [di],' ' 
inc di 
loop clearNext 
pop cx 
ret 
clearBuffer ENDP 

deleteLastChar PROC                 
push ax 
push bx 
push cx 

mov ah, 0AH                         
mov bh, 0 
mov al, ' '                         
mov cx, 1                           
int 10h 

pop cx 
pop bx 
pop ax
ret 
deleteLastChar ENDP 

main: 
mov  ax, @data 
mov  ds, ax 

call cleanWindow                  
call readNumber                  
xchg bx,ax                         ;first number to bx 

push dx                             
lea  dx,strDivMark                   
call printStr 
pop  dx                              

call readNumber                     
xchg bx,ax                          

cmp  ax,0                        
jl   point1                          
jmp  point2 
point1: 
cwd 
point2: 
idiv bx                            
mov  bx,dx                           
lea  dx,strIntMark 
call printStr 
call signNumberToStr                
lea  dx,cleanBuffer 
call printStr 
lea  di,cleanBuffer                 
call clearBuffer                   
lea  dx,strRemainderMark 
call printStr 
mov  ax,bx                          
test ax,ax                         
jns  isPositive                     
neg  ax    
                          
isPositive: 
lea  di,cleanBuffer 
call numberToStr 
lea  dx,cleanBuffer 
call printStr 

mov  ax, 4c00h 
int  21h 
end  main
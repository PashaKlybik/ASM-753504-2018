.model small
.stack 256
.data
    a 			dw 1
    b 			dw 2
    c 			dw 4
    d 			dw 3
    resultL 	dw 0
    resultH 	dw 0
    message 	db 'Hello world!', 13, 10, '$'
.code
main:
    mov ax, @data
    mov ds, ax
    
    mov ax, a
    add ax, b

    mov ah, 9
    mov dx, offset message
    int 21h

;------------------------------------
    MOV Ax,a
    MOV Bx,b
    MOV Cx,c
    MOV Dx,d
    			; if(a OR (a + 1) == b)  
    INC Ax		
    OR Ax,a
    CMP Ax,Bx
    JZ result1
				; if(a AND b == c OR d)  
    MOV Ax,a
    MOV Bx,b
    AND Ax,Bx
    OR Cx,Dx
    CMP Ax,Cx
    JZ result2
    
    JMP result3
 
result1:		; result1 = (a * b + c) % d
    MOV Ax,a
    
    MUL b
    ADD Ax,Cx
    ADC Dx,0
    DIV d
    MOV resultL, Dx
    MOV resultH,0
	MOV Ax,resultL
    JMP return
    
result2:		; result2 = b AND (b - 1)
    MOV Ax,a
    MOV Bx,b
    MOV Cx,c
    MOV Dx,d
    DEC Bx
    AND Bx,b
    MOV resultL,Bx
    MOV resultH,0
	MOV Ax,resultL
    JMP return
    			; result3 = c % d + b * a
result3:		
    MOV Ax,a
    MOV Bx,b
    MOV Cx,c
    MOV Dx,d
    MUL Bx
    MOV resultL, Ax ; save of low word
    MOV resultH, Dx	;high word
    
    MOV Ax, c	; c % d
    XOR Dx,Dx	;ax:dx / d, high word should be empty, because AX:DX is being devided by 16 bit 
    DIV d
   
	MOV Ax,resultL   
    ADD Ax, Dx
    ADC ResultH,0
return:
;------------------------------------   
    mov ax, 4c00h
    int 21h
end main
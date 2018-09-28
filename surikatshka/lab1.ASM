.model small
.stack 256
.data
    a 		dw 14
    b 		dw 58
    c 		dw 24
    d 		dw 18
    tmp1 	dw 0
    tmp2 	dw 0
    tmp3 	dw 0
    resultL 	dw 0
    resultH 	dw 0
    message db 'Hello world!', 13, 10, '$'
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
    MOV Cx, c
    MOV Dx,d
    MOV tmp1, Ax
    
    INC tmp1		; if(a OR (a + 1) == b)  
    OR tmp1,Ax
    CMP tmp1,Bx
    JZ result1
    
    MOV tmp2,Ax		; if(a AND b == c OR d)  
    AND tmp2,Bx
    MOV tmp3,Cx
    OR tmp3,Dx
    MOV Ax,tmp2
    CMP Ax,tmp3
    JZ result2
    
    JMP result3
 
result1:	; result1 = (a * b + c) % d
    MOV Ax,a
;    MOV Dx,b
    
    MUL b
    ADD Ax,Cx
    ADC Dx,0
    DIV d
    MOV resultL, Dx
    MOV resultH,0
	MOV Ax,resultL
    JMP return
    
result2:		; result2 = b AND (b - 1)
    ;XOR tmp1,tmp1
    MOV Bx, b
    MOV tmp1, Bx
    DEC tmp1
    AND Bx,tmp1
    MOV resultL,Bx
    MOV resultH,0
	MOV Ax,resultL
    JMP return
    
result3:		; result3 = c % d + b * a
    MOV Ax,a
    ;XOR tmp2,tmp2
    MUL Bx
    MOV resultL, ax ; save of low word
    MOV resultH, dx	;high word
    
    mov ax, c	; c % d
    xor dx,dx	;ax:dx / d, high word should be empty, because AX:DX is being devided by 16 bit 
    div d
    
    ADD resultL, dx
    ADC ResultH,0
	MOV Ax,resultL


return:
;------------------------------------   
    mov ax, 4c00h
    int 21h
end main
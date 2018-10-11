.model small
.stack 256
.data
 
	;help lines 

	newLine			  db 0Dh,0Ah,'$' ;'\n'
	helpLineDividend  db 'Enter Divident(or enter for zero):','$'
	helpLineDivider   db 'Enter Divider(exept zero(enter)):','$' 
	helpLineQuotient  db 'The qoutient = ','$'
	helpLineReminder  db 'The reminder = ','$'
	helpLineZDivision db 'Cannot be divided by 0.','$'

    count			  dw 0  ;counter 
	ten				  dw 10 ;constant value 
   
.code
printHelpLine PROC ;print of help lines or \n
	push Ax
	push Dx
	MOV Ah,09h
	INT 21h
	pop Dx
	pop Ax
	RET
ENDP

integerInput PROC ;enter of integer
	PUSH Bx 
	Push Cx
	Push Dx
	XOR Bx,Bx
	XOR Cx,Cx

@@cycle1:
	MOV Ah, 07h ;function with reads character without echo
	INT 21h
	CMP Al, 0Dh ;code of enter
	JZ @@exit
	CMP AL,30h
	JC @@cycle1
	CMP Al,3ah
	JNC @@cycle1
	CMP Bx,6554		;control of number which will be certainly overflowing after multiplication by 10
	JGE @@cycle1	;great or equal
	SUB Al, 30h 	;susbsctraction of zero code
	MOV Cl, Al
	MOV Ax,Bx
	MUL ten
	CMP Dx,0
	JNZ @@cycle1
	ADD Ax,Cx
	JC @@cycle1 	;after addition overflow flag(JC) check 
	MOV Bx, Ax
	MOV Dl,Cl
	ADD Dl,30h
	MOV Ah,02h
	INT 21h
	JMP @@cycle1

@@exit:
	MOV Ax,Bx
	POP Dx
	POP Cx
	POP Bx
	RET
integerInput ENDP

integerOutput PROC ;output of integer numbers
	PUSH Dx
	PUSH Cx
	XOR Cx,Cx

@@cycleDiv:
	MOV Dx,0
	DIV ten
	PUSH Dx
	INC Cx
	CMP ax,0
	JNZ @@cycleDiv
	
@@cycle2:
	POP Dx
	ADD Dx,'0'
	MOV Ah,02h
	INT 21h
	LOOP @@cycle2

	POP Cx
	POP Dx
	RET
integerOutput ENDP

main:
    MOV ax, @data
    MOV ds, ax

;------------------------------------
	lea  DX, helpLineDividend
	CALL PrintHelpLine
	CALL integerInput
	MOV Bx,Ax

	lea Dx, newLine			;\n
	CALL PrintHelpLine

enterDivider2:
	lea Dx, helpLineDivider	;adress of string for printing it in helpLine procedure
	CALL PrintHelpLine
	CALL integerInput
	MOV Cx,Ax
	CMP Cx,0
	JZ enterDivider1		;zero divider check
	JMP division

enterDivider1:
	lea Dx, helpLineZDivision
	CALL PrintHelpLine
	Xor Ax,Ax
	Xor Cx,Cx
	JMP enterDivider2
	
division:
	MOV Ax,Bx
	XOR Dx,Dx
	DIV Cx
	push Dx

	lea Dx, newLine			;\n
	CALL PrintHelpLine

	lea Dx, helpLineQuotient
	CALL PrintHelpLine
	CALL integerOutput

	lea Dx, newLine			;\n
	CALL PrintHelpLine

	lea Dx, helpLineReminder
	CALL PrintHelpLine
	pop Ax
	CALL integerOutput

	lea Dx, newLine			;\n
	CALL PrintHelpLine

	

    
;------------------------------------   
    MOV ax, 4c00h
    int 21h
end main

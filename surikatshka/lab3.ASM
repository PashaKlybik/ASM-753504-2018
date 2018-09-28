	.model small
.stack 256
.data
 
	;help lines 
	
	newLine     	 db 0Dh,0Ah,'$' ;'\n'
	helpLineDividend db 'Enter Divident(or enter for zero):','$'
	helpLineDivider  db 'Enter Divider(exept zero(enter)):','$' 
	helpLineQuotient db 'The qoutient = ','$'
	helpLineReminder db 'The reminder = ','$'
	helpLineZDivision db 'Cannot be divided by 0.','$'

    count			 dw 0 ;counter 
	ten				 dw 10 ;constant value 
   
.code
printHelpLine PROC ;print of help lines or \n
	PUSH Ax
	PUSH Dx
	MOV Ah,09h
	INT 21h
	POP Dx
	POP Ax
	RET
ENDP

integerInput PROC ;enter of integer 
	PUSH Bx
	PUSH Cx
	PUSH Dx
	PUSH Si

	XOR Bx,Bx
	XOR Si,Si
	XOR Cx,Cx
	MOV count,0

@@cycle1:
	MOV Ah, 07h  ;function with reads character without echo
	INT 21h
	
	
	CMP Al,'-' ;code of minus 2dh
	;CMP Si,0
	;CMP Bx,0
	JNZ numberNotNeg
	CMP Si,0
	JNZ @@cycle1
	MOV Si,1
	MOV Cx,count
	CMP Cx,0
	JNZ @@cycle1
	MOV Dl,'-'
	MOV Ah,02h
	INT 21h 
	JMP @@cycle1

numberNotNeg:	 
	CMP Al, 0Dh ;code of  enter
	JZ @@exit
	CMP AL,30h
	JC @@cycle1
	CMP Al,3ah
	JNC @@cycle1
	CMP Bx,3277
	JGE @@cycle1	;great or equal
	
	INC count
	SUB Al, 30h ;susbsctraction of zero code
	MOV Cl, Al
	MOV Ax,Bx
	MUL ten
	CMP Dx,0
	JNZ @@cycle1
	ADD Ax,Cx
	CMP Si,1
	JZ LBorder
	TEST Ax,8000h   	;старший бит
	JNZ @@cycle1
LBorder:
	CMP Ax,8001h
	JAE @@cycle1
	MOV Bx, Ax
	MOV Dl,Cl
	ADD Dl,30h
	MOV Ah,02h
	INT 21h
	JMP @@cycle1

@@exit:
	MOV Ax,Bx   
	CMP Si,1
	JNZ extraction
	NEG Ax

extraction:	
	POP Si
	POP Dx
	POP Cx
	POP Bx
	RET
integerInput ENDP

integerOutput PROC ;output of integer numbers
	PUSH Dx
	PUSH Cx
	MOV count,0

	TEST Ax,8000h
	JZ @@cycleDiv
	PUSH Ax
	MOV Dx, '-'

	MOV Ah, 02h
	INT 21h
	POP Ax
	NEG Ax

@@cycleDiv:
	MOV Dx,0
	DIV ten
	PUSH Dx
	INC count
	CMP ax,0
	JZ stackOutput
	JMP @@cycleDiv
stackOutput:
	MOV Cx,count

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
	XOR Ax,Ax 
	LEA  DX, helpLineDividend
	CALL PrintHelpLine
	CALL integerInput
	MOV Bx,Ax

	LEA Dx, newLine
	CALL PrintHelpLine

enterDivAgain:
	LEA Dx, helpLineDivider	;adress of string for printing it in helpLine procedure
	CALL PrintHelpLine
	CALL integerInput
	MOV Cx,Ax
	CMP Cx,0
	JZ zeroDivider
	JMP division

zeroDivider:
	LEA Dx, helpLineZDivision
	CALL PrintHelpLine
	XOR Ax,Ax
	XOR Cx,Cx
	JMP enterDivAgain


division:

	MOV Ax,Bx
	CWD
	TEST Dx, 8000h ;if divident is positive
	JZ dividePositive
	IDIV Cx
	TEST Ax,8000h
	JZ posQuotient	 ;if quotient (ax) negative
	DEC Ax
	ADD Dx,Cx
	PUSH Dx
	JMP outputResult
	
posQuotient:		;if quotient (ax) negative
	INC Ax
	SUB Dx,Cx
	PUSH Dx
	JMP outputResult
	

dividePositive:
	IDIV Cx
	PUSH Dx

outputResult:
	LEA Dx, newLine
	CALL PrintHelpLine

	LEA Dx, helpLineQuotient
	CALL PrintHelpLine
	CALL integerOutput

	LEA Dx, newLine
	CALL PrintHelpLine

	LEA Dx, helpLineReminder
	CALL PrintHelpLine
	POP Ax
	CALL integerOutput

	LEA Dx, newLine
	CALL PrintHelpLine

	

    
;------------------------------------   
   
   MOV  ax, 4c00h
    INT 21h
end main

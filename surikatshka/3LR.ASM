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

	ten				 dw 10 ;constant value 
   
.code
printHelpLine PROC 	;print of help lines or \n
	PUSH Ax
	MOV Ah,09h
	INT 21h
	POP Ax
	RET
ENDP

integerInput PROC 	;enter of integer 
	PUSH Bx
	PUSH Cx
	PUSH Dx
	PUSH Si
	PUSH Di

	XOR Bx,Bx
	XOR Si,Si
	XOR Cx,Cx
	XOR Di,Di

InputCycle:
	MOV Ah, 07h  	;function which reads character without echo
	INT 21h
	
	
	CMP Al,'-' 		;code of minus 2dh
	JNZ numberNotNeg
	CMP Si,0	
	JNZ InputCycle
	MOV Si,1
	CMP Di,0		; minus cannot be entered if digits were entered. Appropriate check of Di register
	JNZ InputCycle
	MOV Dl,'-'
	MOV Ah,02h
	INT 21h 
	JMP InputCycle

numberNotNeg:	 
	CMP Al, 0Dh		;code of  enter
	JZ @@exit
	CMP AL,30h		;chek of lower bound
	JC InputCycle
	CMP Al,3ah		;check of upper bound
	JNC InputCycle
	CMP Bx,3277
	JGE InputCycle	;great or equal (signed)
	
	INC Di 			;flag of numbers entered amount if Di==0 minus can be entered 
	SUB Al, 30h 	;susbsctraction of zero code
	MOV Cl, Al
	MOV Ax,Bx
	MUL ten
	CMP Dx,0		;check on overflow
	JNZ InputCycle
	ADD Ax,Cx
	CMP Si,1
	JZ LBorder
	TEST Ax,8000h   	;high bit
	JNZ InputCycle
	JMP SaveAndOutput

LBorder:				;check of negative overflow
	CMP Ax,8001h		
	JAE InputCycle		;greater or equal (unsigned)

SaveAndOutput:
	MOV Bx, Ax 			;save of intermediate number
	MOV Dl,Cl
	ADD Dl,30h
	MOV Ah,02h
	INT 21h
	JMP InputCycle

@@exit:
	MOV Ax,Bx   
	CMP Si,1
	JNZ restoreRegisters
	NEG Ax

restoreRegisters:	
	POP Di
	POP Si
	POP Dx
	POP Cx
	POP Bx
	RET
integerInput ENDP

integerOutput PROC ;output of integer numbers
	PUSH Dx
	PUSH Cx
	XOR Cx,Cx

	TEST Ax,8000h	;check of negative number
	JZ @@cycleDiv

	PUSH Ax
	MOV Dx, '-'		;output of minus symbol
	MOV Ah, 02h
	INT 21h
	POP Ax
	NEG Ax

@@cycleDiv:
	MOV Dx,0
	DIV ten
	PUSH Dx
	INC Cx
	CMP ax,0
	JZ OutputCycle
	JMP @@cycleDiv

OutputCycle:
	POP Dx
	ADD Dx,'0'
	MOV Ah,02h
	INT 21h
	LOOP OutputCycle

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
	CWD					;copy highest bit of Ax register in Dx register
	TEST Dx, 8000h 		;if divident is positive
	JZ dividePositive
	IDIV Cx				
	TEST Ax,8000h
	JZ positiveQuotient		
	DEC Ax 					;if quotient (ax) negative
	ADD Dx,Cx
	PUSH Dx
	JMP outputResult
	
positiveQuotient:			;if quotient (ax) positive
	INC Ax
	SUB Dx,Cx
	PUSH Dx
	JMP outputResult
	
dividePositive:
	IDIV Cx					;if divident is positive
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

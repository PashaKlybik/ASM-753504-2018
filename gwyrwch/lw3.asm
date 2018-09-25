.model small
.stack 256
.data
	__cnt_digits dw 0

    a dw 65535
    ten dw 10
    s db "Incorrect input$"
    zero db "Division by zero$"
.code 

endl PROC
	PUSH dx
	PUSH ax

	MOV dx, 0AH
	MOV ah, 02h
	INT 21h
	
	POP ax
	POP dx
	RET
endl ENDP

uprintf PROC
	PUSH cx
	MOV cx, 0
	PUSH dx
	PUSH ax
	MOV dx, 0 

	division :
	    DIV ten
	    PUSH dx
	    MOV dx, 0
	   	INC cx

	    CMP ax, 0
	    JZ true

	    JMP division

	true:

	CMP cx, 0
	JZ zero_came
	JMP non_zero_came
	
	zero_came:
		PUSH 0
		MOV cx, 1
	
	non_zero_came:
		POP dx
		ADD dx, '0'
		MOV ah, 02h
		INT 21h
	LOOP non_zero_came

	POP ax
	POP dx
	POP cx
	RET
uprintf ENDP

printf PROC
	PUSH bx
	PUSH dx
	PUSH ax

	CWD
	CMP dx, 0

	JNZ minus
	JMP plus

	minus:
		MOV bx, ax

		MOV dx, '-'
		MOV ah, 02h
		INT 21h

		MOV ax, bx
		NEG ax
	plus:

	CALL uprintf

	POP ax
	POP dx
	POP bx
	RET
printf ENDP

scanf PROC
	PUSH si
	PUSH dx
	PUSH bx
	PUSH cx

	scanf_prep:
	MOV bx, 0
	MOV dx, 0
	MOV __cnt_digits, 0

	MOV ah, 01h
	INT 21h

	CMP al, '-'
	JZ negative
	
	; positive
	MOV si, 0
	JMP skip_reading

	negative:
		MOV si, 1
		MOV ax, 0
	
	lo_op:
		MOV ah, 01h
		INT 21h

		skip_reading:

		CMP al, 13
		JZ good_input

		CMP al, 48 ; '0' = 48 '9' = 57 //47

		JC bad_input

		CMP al, 58

		JNC bad_input

		MOV cl, al ; bx = bx * 10 + al - 48

		MOV ax, bx
		MUL ten
		MOV bx, ax

		CMP dx, 0 ; dx == 0 else too large
		JNZ bad_input 

		SUB cl, 48
		MOV ch, 0
		ADD bx, cx

		INC __cnt_digits

		JC bad_input
	JMP	lo_op
	good_input:
		CMP __cnt_digits, 0
		JZ lo_op

		MOV ax, bx
		JMP validate_range
	bad_input:
		LEA dx, s
		MOV ah, 09h
		INT 21h

		MOV ax, 0
		CALL endl
		JMP scanf_prep
	validate_range:
		; ax > 32767 + si
		; -[1, 2, 3, 4, 32768]
		; -[65535, 65534, 65533, 65532]
		ADD si, 32767
		CMP ax, si
		JA bad_input ; <= for unsigned

		SUB si, 32767
		CMP si, 1

		JNZ scanf_finish
		NEG ax
		JMP scanf_finish
	scanf_finish:
		POP cx
		POP bx
		POP dx
		POP si
	RET
scanf ENDP
	
main:
    MOV ax, @data
    MOV ds, ax

    CALL scanf
    CALL printf
    CALL endl

    MOV cx, ax

    CALL scanf
    CALL printf
    CALL endl

    MOV dx, cx
    MOV cx, ax
    MOV ax, dx

    MOV dx, 0  
    CMP cx, 0
    JZ div_by_zero

    CWD

    IDIV cx

    CALL printf
    CALL endl
    JMP end_main 

    div_by_zero:
    	LEA dx, zero
		MOV ah, 09h
		INT 21h

	end_main:
	    MOV ax, 4c00h
	    int 21h

end main

.model small
.stack 256
.data
    __cnt_digits dw 0
    ten dw 10
    invalid_input_s db "Incorrect input$"
    zero db "Division by zero$"
.code 

endl PROC
	PUSH dx
	PUSH ax

	MOV dl, 0AH
	MOV ah, 02h
	INT 21h
	
	POP ax
	POP dx
	RET
endl ENDP

printf PROC
	PUSH ax
	PUSH cx
	PUSH dx

	MOV cx, 0
	MOV dx, 0 

	division :
	    DIV ten
	    PUSH dx
	    MOV dx, 0
	   	INC cx

	    CMP ax, 0
	    JNZ division 

	CMP cx, 0
	JNZ non_zero_came

	PUSH 0
	MOV cx, 1
	
	non_zero_came:
		POP dx
		ADD dx, '0'
		MOV ah, 02h
		INT 21h
	LOOP non_zero_came

	POP dx
	POP cx
	POP ax
	RET
printf ENDP

scanf PROC
	PUSH bx
	PUSH cx
	PUSH dx

	MOV bx, 0
	MOV dx, 0
	MOV __cnt_digits, 0

	reading:
		MOV ah, 01h
		INT 21h

		CMP al, 13
		JZ good_input

		CMP al, 48 ; '0' = 48 '9' = 57 //47
		JC bad_input

		CMP al, 58 ;
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
	JMP	reading

	good_input:
		CMP __cnt_digits, 0
		JZ reading

		MOV ax, bx
		JMP finish

	bad_input:
		LEA dx, invalid_input_s
		MOV ah, 09h
		INT 21h

		MOV bx, 0
		MOV dx, 0
		MOV ax, 0
		MOV __cnt_digits, 0
		CALL endl
	JMP reading
		
	finish:
		POP dx
		POP cx
		POP bx
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

    DIV cx

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

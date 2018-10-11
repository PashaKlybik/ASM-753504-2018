.model small
.stack 256
.data
	__cnt_digits dw 0
    ten dw 10
    s db "Incorrect input$"
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

;unsigned printf
uprintf PROC
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
uprintf ENDP

printf PROC 
	PUSH bx
	PUSH dx
	PUSH ax

	CWD
	CMP dx, 0
	JZ plus

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
	
	reading:
		MOV ah, 01h
		INT 21h

		skip_reading:

		CMP al, 8 ; backspace 
		JZ backspace

		CMP al, 13
		JZ good_input

		CMP al, 48 ; '0' = 48 '9' = 57 
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
		ADD bx, cx ; if overflow CF = 1

		INC __cnt_digits

		JC bad_input
	JMP	reading

	backspace:
		CMP __cnt_digits, 0
		JZ erase_minus ; -\b

		MOV ax, bx
		DIV ten
		MOV bx, ax

		MOV dl, ' '
		MOV ah, 02h
		INT 21h

		MOV dl, 8
		MOV ah, 02h
		INT 21h
		
		MOV dl, 0
		DEC __cnt_digits
		JMP reading

	erase_minus:
		MOV dl, ' '
		MOV ah, 02h
		INT 21h

		MOV dl, 8
		MOV ah, 02h
		INT 21h

		MOV dl, 0
		JMP scanf_prep

	good_input:
		CMP __cnt_digits, 0
		JZ jump_scanf_prep ; too long jump 

		MOV ax, bx
		JMP validate_range

	jump_scanf_prep:
		JMP scanf_prep

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

    MOV dx, cx ;swap ax cx
    MOV cx, ax
    MOV ax, dx

    MOV dx, 0  
    CMP cx, 0
    JZ div_by_zero

    CMP ax, 8000h ;-32768 
	JNZ save_division
	CMP cx, 0FFFFh ;-1
	JNZ save_division

	LEA dx, s
	MOV ah, 09h
	INT 21h
	JMP end_main

	save_division:
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
	    INT 21h

end main
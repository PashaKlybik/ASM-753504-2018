; 4) if a ^ 2 = b * c
;         if c * b = d / b 
;            result = a OR b
;         else
;            result = c
;    else
;    	result = c * a - b

.model small
.stack 256
.data
    a dw 13
    b dw 13
	c dw 13
	d dw 2197
.code
main:
    mov ax, @data
    mov ds, ax
 
    mov ax, a 	;  ax contains a
    mul a 	;  ax contains a*a
	mov bx, ax ;  bx contains a*a
	mov ax, b
	mul c 	;  ax contains b*c
	cmp ax, bx  	; is a ^ 2 = b * c
	JZ true_main_condition

	div b 	; ax contains  c
	mul a 	
	sub ax, b 	;ax = c * a - b
	JMP finish
	
	true_main_condition :
		mov cx, ax 	; cx contains b*c
		mov ax, d
		div b  	; ax contains d / b
		cmp ax, cx
		JNZ false_nested_condition 

	mov ax, a
	OR ax, b 
	JMP finish

	false_nested_condition :
		mov ax, c 
	
	finish:
	    mov ax, 4c00h
	    int 21h
end main
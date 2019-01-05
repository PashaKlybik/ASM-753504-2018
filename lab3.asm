model small			
.stack 100h         

.data
devident dw 0
devider dw 0
temp dw 0
unusial dw -32768
inputdevident db "Enter devident: ", '$'
inputdevider db "Enter devider: ", '$'
results db "Result: ", '$'
repeat db 13, 10,"Repeat please!", 13, 10, '$'
exzero db "Division by zero!", 13, 10, '$'
n db 10,"$"
u dw 10
currentpos dw ?
isnegative dw ?
cel dw ?
.code

InputInt proc
	mov currentpos, 0
	mov isnegative, 0

	inputsymbol:
		add currentpos, 1

		mov ah, 01h
		int 21h
		xor ah, ah

		cmp ax, 43
		jz plus

		cmp ax, 45
		jz minus	

	usialint:
		cmp ax, 13
		jz firstend
		cmp ax, 48
		jc error
		cmp ax, 57
		jz usialint
		jnc error

	next1:
		sub al, 48
		mov ah, 0
		mov bx, ax
		mov ax, temp
		mul u
		jc error
		add ax, bx
		jc error
		mov temp, ax
		jmp inputsymbol

	plus:
		cmp currentpos, 1
		jz positive
		jmp error

	positive:
		mov isnegative, 0
		jmp inputsymbol

	minus:
		cmp currentpos, 1
		jz negative
		jmp error

	negative:
		mov isnegative, 1
		jmp inputsymbol

	error:
		mov currentpos, 0
		mov isnegative, 0
		lea dx, repeat
		mov ah, 09h
		int 21h
		mov ax, 0
		mov temp, ax
		jmp inputsymbol

	toneg:
		neg temp
		jmp secondend

	firstend:
		cmp isnegative, 1
		jz toneg

	secondend:
		mov cx, temp
		cmp cx,unusial
		jz error

	ret
InputInt endp

OutputInt proc 

	test ax, ax 
	jns out1

	mov  cx, ax 
    mov ah, 02h
    mov dl, '-'
    int 21h
    mov ax, cx
    neg ax

    out1:
		xor cx, cx
		next:
			xor dx, dx
			div u
			push dx
			xor dx, dx
			inc cx
			cmp ax, 0
			jnz next

		cycle:
			pop dx
			xor dh, dh
			add dl, 48
			mov ah, 02h
			int 21h
			loop cycle
			
			ret
OutputInt endp

func proc
	push ax
	push dx

	lea dx, n
	mov ah, 09h
	int 21h

	pop dx
	pop ax

	ret
func endp

main:
	mov ax, @data
	mov ds, ax
	lea dx, inputdevident
	mov ah, 09h
	int 21h
	call InputInt
	mov ax, temp

	push temp
	pop devident
	mov ax, devident
	mov temp, 0

	lea dx, inputdevider
	mov ah, 09h
	int 21h
	call InputInt
	mov ax, temp

	push temp
	pop devider
	mov ax, devider
	mov temp, 0

	cmp devider, 0
	jz label1

	mov ax, devident
	cwd
	idiv devider

	mov cel, ax

	lea dx, results
	mov ah, 09h
	int 21h
	mov ax, cel

	call outputint

	call func

	mov ah, 4Ch
	int 21h

	label1:
	lea dx, exzero
	mov ah, 09h
	int 21h

	mov ah, 4Ch
	int 21h
END main 
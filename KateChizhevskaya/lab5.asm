.model small
.stack 256
.data
	rows dw ?
	colunms dw ?
	biggest_number dw ?
	quantity dw ?
	minus db ?
	array dw 100 dup($)
	rows_messege  db 'Entry number of rows', 13, 10, '$'
	colunms_messege  db 'Entry number of colunms', 13, 10, '$'
	matrix_messege  db 'Entry number for matrix', 13, 10, '$'
	number_messege  db 'Entry the biggest number', 13, 10, '$'
	new_line db 13, 10, '$'
	tab_entry db 09, '$'
.code
allOutput proc
		cmp ax,0
		jl special
		continue:
		call output
	ret
	allOutput endp

	special:
	call specialOutput
	jmp continue

	specialOutput proc
		 push ax
		 push dx
		 mov dl, '-'
		 mov ah, 02h
		 int 21h
		 pop dx
		 pop ax
		 neg ax
	ret
	specialOutput endp

    output proc
		push ax
		push cx
		push dx
		push bx
		xor cx,cx  
		mov bx,10

    count:
		xor dx,dx
		div bx
		add dl,'0'
		push dx
		inc cx
		test ax,ax
		jnz count

     fromStackLast:
		pop dx
		mov ah, 02h
		int 21h
		loop fromStackLast
		mov dl, ' '
		mov ah, 02h
		int 21h
		pop bx
		pop dx
		pop cx
		pop ax
		ret
		output endp

messege_output proc
	push ax
	mov ah, 9
    int 21h
	pop ax
	ret
messege_output endp
allInput proc
		push bx
		push dx
		push cx
		XOR BX,BX
		CALL input 
		cmp minus,1;  if - was inputed
		JZ MinusNumber
		continue1:
		XCHG AX,BX
		pop cx
		pop dx
		pop bx
		ret
allInput endp
MinusNumber:
			neg Bx
jmp continue1 
input proc
			PUSH AX
			PUSH CX
			PUSH DX
			MOV AH,01h
			int 21h;
			cmp al,'-'
			JZ MinusInput
			mov minus,0
			sub AL,'0'
			CMP AL,13;end of the input 
			JZ end1
			MOV CH,0
			MOV CL,AL
			CMP CX,221
			JZ end1
			MOV AX,BX
			MOV BX,10
			MUL BX
			XOR DX,DX
			ADD AX, CX
			XCHG AX,BX
			XOR AX,AX
		begin:
			MOV AH,01h
			int 21h;
			sub AL,'0'
			CMP AL,13;end of the input 
			JZ end1
			MOV CH,0
			MOV CL,AL
			CMP CX,221
			JZ end1
			MOV AX,BX
			MOV BX,10
			MUL BX
			XOR DX,DX
			ADD AX, CX
			XCHG AX,BX
			XOR AX,AX
			JMP begin
		end1:
			POP AX
			POP CX
			POP DX
		ret
input endp
MinusInput:
			mov minus,1			
JMP begin

output_last proc
	push cx
	push ax
	push dx
	push si
	mov cx,rows
	mov si,0
	rows_cycle:
		push cx
		mov cx,colunms
		columns_cycle:
			push bx
			mov ax, colunms
			sub ax,cx 
			mov ax, array[si]
			inc si
			inc si
			call allOutput
			mov dx, offset tab_entry
			call messege_output
			xor ax,ax
			xor dx,dx
			pop bx
			loop columns_cycle
		pop cx
		mov dx, offset new_line
		call messege_output
		xor ax,ax
		xor dx,dx
		loop rows_cycle
		pop si
		pop dx
		pop ax
		pop cx
	ret
output_last endp


main:
    mov ax, @data
    mov ds, ax

	xor ax,ax
	mov dx, offset rows_messege
	call messege_output 
	xor dx,dx
	call allInput
	mov rows,ax
	xor ax,ax
	mov dx, offset colunms_messege
	call messege_output
	xor dx,dx
	call allInput
	mov colunms,ax
	xor bx,bx
	mov bx, rows
	mul bx
	mov quantity, ax
	xor ax,ax
	xor bx,bx
	mov cx,quantity
	matrix_entry:
		mov dx, offset matrix_messege
		call messege_output 
		xor dx,dx
		call allInput
		mov array[bx], ax
		inc bx
		inc bx
		xor ax,ax
	loop matrix_entry
	mov dx, offset number_messege
	call messege_output 
	call allInput
	xor bx,bx
	mov biggest_number, ax
	mov cx,quantity
	matrix:
		push ax
		mov ax,array[bx]
		cmp ax,biggest_number
		JGE actions
		continue47:
		inc bx
		inc bx
		pop ax
	loop matrix
	call output_last
	jmp eng_programm

	actions:
		mov array[bx],0
		jmp continue47

	eng_programm:
		mov ax, 4c00h
		int 21h
end main
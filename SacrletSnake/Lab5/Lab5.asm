.model small
.stack 256

.data
	buffer1 db '       $'
	buffer2 db '       $'
	originalArray dw 10*10 dup (?)
	sapceStr db '  $'
	endline db 13,10,'$'

.code
Begin:
	mov ax, @data
    mov ds, ax

	call InputNumber
	call FunctionOfOutput
	push ax
	call InputNumber
	call FunctionOfOutput
	mov bx,ax
	pop ax
	call InputArray
	call OutputArray
	call OutputChangedArray

	mov ax, 4c00h
	int 21h

FunctionOfOutput proc
	call ClearBuffer
	call OutputWithSign
	call EndStr
	ret
FunctionOfOutput endp

InputNumber proc
	push dx
	mov al,7
	call InputString
	call StringToNumberWithSign
	pop dx
	ret
InputNumber endp

InputString proc
	push cx
	mov cx,ax
	mov ah,10
	mov [buffer1],al
	mov byte[buffer1+1],0
	mov dx,offset buffer1
	int 21h
	mov al,[buffer1+1]
	add dx,2
	mov ah,ch
	pop cx
	ret
InputString endp

StringToNumberWithoutSign proc
	push cx
	push dx
	push bx
	push si
	push di	
	mov si,dx
	mov di,10
	xor ah,ah
	mov cx,ax
	cmp cx,0
	jz StdError
	xor ax,ax
	xor bx,bx
Transform:
	mov bl,[si]
	inc si
	cmp bl, '0'
	jl StdError
	cmp bl,'9'
	jg StdError
	sub bl,'0'
	mul di
	jc StdError
	add ax,bx
	jc StdError
	loop Transform
	jmp StdExit
StdError:
	xor ax,ax
	stc
StdExit:
	pop di
	pop si
	pop bx
	pop dx
	pop cx
	ret
StringToNumberWithoutSign endp

StringToNumberWithSign proc
	push bx
	push dx
	test al,al
	jz StdWithSignError
	mov bx,dx
	mov bl,[bx]
	cmp bl,'-'
	jne NoSign
	inc dx
	dec al
NoSign:
	call StringToNumberWithoutSign
	jc StdWithSignExit
	cmp bl,'-'
	jne NumberPlus
	cmp ax,32768
	ja StdWithSignError
	neg ax
	jmp StdEnd
NumberPlus:
	cmp ax,32767
	ja StdWithSignError
StdEnd:
	clc 
	jmp StdWithSignExit
StdWithSignError:
	xor ax,ax
	stc
StdWithSignExit:
	pop dx
	pop bx
	ret

PrintString:
	push ax
	mov ah,9
	xchg dx,di
	int 21h
	pop ax
	ret
StringToNumberWithSign endp

EndStr proc
	push di
	mov di,offset endline
	call PrintString
	pop di
	ret
EndStr endp

SpaceStr proc
	push di
	mov di,offset spaceStr
	call PrintString
	pop di
	ret
SpaceStr endp

OutputString proc
	push ax
	push cx
	push bx
	push dx
	xor cx,cx
	mov bx,10
TransformToString:
	xor dx,dx
	div bx
	add dl,'0'
	push dx
	inc cx
	test ax,ax
	jnz TransformToString
IntoTheStack:
	pop dx
	mov [di],dl
	inc di
	loop IntoTheStack
	pop dx
	pop bx
	pop cx
	pop ax
	ret
OutputString endp

OutputWithSign proc
	push ax
	mov di,offset buffer2
	test ax,ax
	jns OutputWithoutSign
	mov byte ptr[di],'-'
	inc di
	neg ax
OutputWithoutSign:
	call OutputString
	mov di,offset buffer2
	call PrintString
	pop ax
	ret
OutputWithSign endp

ClearBuffer proc
	push cx
	mov cx,7
	lea dx,[buffer2]
Clear:
	mov byte ptr[di],' '
	inc di
	loop Clear
	pop cx
	ret
ClearBuffer endp

InputArray proc
	push cx
	mov cx,ax
	push ax
	mov si,0
InputColumnOfArray:
	push cx
	mov cx,bx
	InputStringOfArray:
		call InputNumber
		mov originalArray[si],ax
		call FunctionOfOutput
		inc si
		inc si
		loop InputStringOfArray
	pop cx
	call EndStr
	dec cx
	cmp cx,0
	jnz InputColumnOfArray
	pop ax
	pop cx	
	ret
InputArray endp
	
OutputArray proc
	push cx
	mov cx,ax
	push ax
	mov si,0
	mov ah,09h
	lea dx,originalArray
OutputColumnOfArray:
	push cx
	mov cx,bx
	OutputStringOfArray:
		mov ah,02h
		mov dx,originalArray[si]
		add dx,30h
		int 21h
		call SpaceStr
		inc si
		inc si
		loop OutputStringOfArray
	pop cx
	call EndStr
	dec cx
	cmp cx,0
	jnz OutputColumnOfArray
	pop ax
	pop cx
	ret
OutputArray endp

OutputChangedArray proc
	call EndStr
	push cx
	mov cx,ax
	push ax
	call InputNumber
	call FunctionOfOutput
	call EndStr
	push ax
	mov si,0
	mov ah,09h
	pop ax
	lea dx,originalArray
OutputChangedColumnOfArray:
	push cx
	mov cx,bx
	OutputChangedStringOfArray:		
		cmp originalArray[si],ax
		jle Less
		push ax
		mov ax,0
		mov originalArray[si],ax
		pop ax
	Less:
		mov dx,originalArray[si]
		add dx,30h
		push ax
		mov ah,02h
		int 21h
		pop ax
		call SpaceStr
		inc si
		inc si
		loop OutputChangedStringOfArray
	pop cx
	call EndStr
	dec cx
	cmp cx,0
	jnz OutputChangedColumnOfArray
	pop ax
	pop cx
	ret
OutputChangedArray endp

end Begin

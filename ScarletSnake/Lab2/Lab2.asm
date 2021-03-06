.model small
.stack 256

.data
	buffer1 db '      $'
	buffer2 db '      $'
	endline db 13,10,'$'

.code
Begin:
	mov ax, @data
    mov ds, ax

IllegalInput:
	call InputNumber
	call FunctionOfOutput
	push ax
	call InputNumber
	call FunctionOfOutput
	mov bx,ax
	pop ax
	cmp bx,0
	jz IllegalInput
	xor dx,dx
	div bx
	call FunctionOfOutput

	mov ax, 4c00h
	int 21h

FunctionOfOutput:
	call ClearBuffer
	call OutputWithoutSign
	call EndStr
	ret

InputNumber:
	push dx
	mov al,7
	call InputString
	call StringToNumberWithoutSign
	pop dx
ret

InputString:
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

StringToNumberWithoutSign:
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
	cmp ax,65535
	ja StdError
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

	PrintString:
	push ax
	mov ah,9
	xchg dx,di
	int 21h
	pop ax
	ret

EndStr:
	push di
	mov di,offset endline
	call PrintString
	pop di
	ret

OutputString:
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

OutputWithoutSign:
	push ax
	mov di, offset buffer2
	call OutputString
	mov di,offset buffer2
	call PrintString
	pop ax
	ret

ClearBuffer:
	push cx
	mov cx,7
	lea dx,[buffer2]
Clear:
	mov byte ptr[di],' '
	inc di
	loop Clear
	pop cx
	ret

end Begin
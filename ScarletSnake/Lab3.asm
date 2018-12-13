.model small
.stack 256

.data
	buffer1 db '       $'
	buffer2 db '       $'
	illegalstr db 13,10,'Illegal input$'
	tryagain db 13,10,'Try again!$'
	endline db 13,10,'$'

.code
Begin:
	mov ax, @data
    mov ds, ax

IllegalInputNull:
	call InputNumber
	call FunctionOfOutput
	cmp ax,0
	jz IllegalInputNull
	push ax
	call InputNumber
	call FunctionOfOutput
	mov bx,ax
	pop ax
	cmp bx,0
	jz IllegalInputNull
	xor dx,dx
	cwd
	idiv bx
	call FunctionOfOutput

	mov ax, 4c00h
	int 21h

IllegalInput proc
	push dx
	xor dx,dx
	mov di,offset illegalstr
	call PrintString
	call EndStr
	mov di,offset tryagain
	call PrintString
	pop di
	ret
IllegalInput endp	

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
	call IllegalInput
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
	call IllegalInput 
	stc
StdWithSignExit:
	pop dx
	pop bx
	ret
StringToNumberWithSign endp

PrintString proc
	push ax
	mov ah,9
	xchg dx,di
	int 21h
	pop ax
	ret
PrintString endp

EndStr proc
	push di
	mov di,offset endline
	call PrintString
	pop di
	ret
EndStr endp

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

end Begin

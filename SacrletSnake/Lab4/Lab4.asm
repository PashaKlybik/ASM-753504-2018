.model small
.stack 256

.data
    string db 200, 200 dup('$')

.code
 Begin:
	mov ax,@data
	mov ds,ax

	mov es,ax    
 	lea di,string
	mov dx,di
	mov ah,0ah
	int 21h
	call NextStr
	inc dx
	call Delete
	mov ah,09h
	int 21h
	call NextStr

	mov ax,4c00h
	int 21h

Delete proc 
	push bx
	push ax
	push cx
	xor bx,bx
	mov si,dx
	mov di,dx
CheckOfSymbol:
    mov al,[si]
	mov cx,bx
	repne scasb
	je Peer
	mov di,dx
	add di,bx
	mov [di],al
	inc bx
Peer:
	inc si
	cmp byte ptr [si],'$'
	je EndStr
	mov di, dx
	jmp CheckOfSymbol
EndStr:
	mov byte ptr [di],'$'
	pop cx
	pop ax
	pop bx
	ret
Delete endp

NextStr proc
    push ax
    push dx
    mov ah,02h
    mov dl,10
    int 21h
    pop dx
    pop ax
    ret
NextStr endp
 
end Begin 

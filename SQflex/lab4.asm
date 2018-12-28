.model small
.stack 256
.data
    string db 250, 250 dup('$')
.code
 main:
	  mov ax, @data
	  mov ds, ax
	mov es, ax    
 	lea di, string
	mov dx, di
	mov ah, 0ah
	int 21h
	call SEQUENTSTR
	inc dx
	call REMOVE
	mov ah, 09h
	int 21h
	call SEQUENTSTR
	mov ax, 4c00h
	int 21h
  REMOVE proc
	push cx
	push bx
	push ax
	xor bx, bx
	mov si, dx
	mov di, dx
      ControlSimbol:
     	     mov al, [si]
	     mov cx, bx
	     repne scasb
	     je Equal
	     mov di, dx
	     add di, bx
	     mov [di], al
	     inc bx
     Equal:
	     inc si
	     cmp byte ptr [si], '$'
	     je Finish
	     mov di, dx
	     jmp ControlSimbol
     Finish:
	     mov byte ptr [di], '$'
	     pop ax
	     pop bx
	     pop cx
	     ret
REMOVE endp
 SEQUENTSTR proc
    push ax
    push dx
    mov ah, 02h
    mov dl, 10
    int 21h
    pop dx
    pop ax
    ret
SEQUENTSTR endp
 
end main 
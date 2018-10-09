.model small
.stack 256
.data
counter dw 0
trysymbol db ?
maxlen db 80
string  db  100 dup ('$'),'$'
vowels db "AEIOUaeiou",0
len dw 0
endmessage db 10,13, "$" 
.code

;for outputting the number of words that begin with a vowel
printfromax PROC	
	push ax
	push bx	
	push cx	
	push dx	
		
	mov bx,10
	xor cx,cx

	cycle1:
	xor dx,dx
	div bx
	inc cx
	push dx
	cmp ax,0
	JNZ cycle1

	cycle2:
	pop dx
	add dl,'0'
	mov ah,02h
	int 21h
	loop cycle2

	pop dx
	pop cx
	pop bx
	pop ax
	RET
printfromax endp

searchforvowels proc
	push ax	
	push cx	
	push dx	
	push di
	push es
	
	xor ax,ax
	mov cx,10
	mov al,trysymbol
	lea di,vowels
	cld
	repne scasb
	jnz endit
	inc counter
	
	endit:
	pop es
	pop di
	pop dx
	pop cx
	pop ax
	RET
searchforvowels endp
	
findstart proc
	push ax	
	push cx		
	push di
	push es

	cld
	mov al,string[2]
	mov trysymbol,al
	call searchforvowels
	
	mov cx,len
	inc cx
	lea di,string
	cld
	
	cycle3:
	mov al,32	;space
	repnz scasb 	
	jnz totheend
	mov al,es:di
	mov trysymbol,al
	call searchforvowels
	jmp cycle3
	
	totheend:
	pop es
	pop di
	pop cx
	pop ax
	RET
findstart endp
	
main:

	mov ax, @data
	mov ds, ax
	mov es,ax
	
	lea bx,maxlen
	mov ah, 0ah          
	lea dx,string
    int 21h 
	
	xor ax,ax
	mov al, byte[string]
	mov len,ax
	
	call findstart
	
	mov dx,offset endmessage
	mov ah,09h
	int 21h
	
	mov ax,counter
	call printfromax
	
	mov dx,offset endmessage
	mov ah,09h
	int 21h
	
	mov ax, 4c00h
	int 21h

end main
.model small
.stack 256
.data
    a dw 7
    b dw 13
	c dw 13
	d dw 5
.code
main:
    mov ax, @data
    mov ds, ax
 
    mov ax, a ;  ax contains a
    mul a ;  ax contains a*a
	mov bx, ax ;  bx contains a*a
	mov ax, b
	mul c ;  ax contains b*c
	cmp ax, bx  
	JNZ false
 
	true :
	mov cx, ax ; cx contains b*c
	mov ax, d
	div b  ; ax contains d / b
	cmp ax, cx
	JZ true1
	JMP false1 ;

	false :
	div b
	mul a
	sub ax, b ;
	JMP finish
 
	true1 :
	mov ax, a
	OR ax, b ;
	JMP finish
 
	false1 :
	mov ax, c ;
	
	finish:
 
    mov ax, 4c00h
    int 21h
end main
.model small
.stack 256
.data
	a dw 5
	b dw 4
	c dw 6
	d dw 7
.code
main:
	mov ax, @data
	mov ds,ax
	
	mov ax, a
	cmp ax, b
	jb label1
	mov ax, b
label1:
	cmp ax, c
	jb label2
	mov ax, c
label2:
	cmp ax, d
	jb label3
	mov ax, d
label3:
	
			
	mov ax, 4c00h
	int 21h
end main
			
	

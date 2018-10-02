.model small
.stack 256
.data
    a dw 3
    b dw 13
    c dw 14
    d dw 17
.code
main:
    mov ax, @data
    mov ds, ax
    mov ax, [a]
    mov bx,[b]
    mul ax
    mov dx,a
    mul dx
    mov cx,ax ; in cx a^3
    mov ax,bx
    mul bx
    mov bx,ax; in bx b^2
    CMP cx,bx ;a^3 and b^2
    JG FirstAction
    JMP Next
    FirstAction:
		mov ax,[c]
		mov dx,[d]
		mul dx
		mov cx, ax; in cx c*d
		mov ax,a
		mov bx, b
		div bx
		mov bx,ax ; in bx a/d
		CMP cx,bx
    JZ Test1 ;ZF=1
		mov ax,[c] ; first true, second false
		mov dx,[d]
		mul dx
		mov dx,[b]
		ADD ax,dx ; in ax c*d+b
    JMP End1
	Test1:
		Jnc SecondAction; CF=0
		mov ax,[c] ; first true, second false
		mov dx,[d]
		mul dx
		mov dx,[b]
		ADD ax,dx ; in ax c*d+b
	JMP End1
		SecondAction:
		mov ax,[a]
		mov cx,[b]
		AND ax,cx
	JMP End1
    Next:
		mov ax,c; both both are not true
	End1:
		mov ax, 4c00h
		int 21h
end main
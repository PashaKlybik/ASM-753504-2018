.model small
.stack 256
.data
    intermediateNumber dw ?
    input db "input1.txt", 0
    output db "output.txt", 0
    char db ?
    rows dw ?
    colunms dw ?
    biggestNumber dw ?
    quantity dw ?
    minus db ?
    array dw 100 dup($)
    newLine db 13, 10, '$'
    tabEntry db 09, '$'
    fileDescriptor dw ?
.code

messegeOutput proc
    push ax
    mov ah, 9
    int 21h
    pop ax
    ret
messegeOutput endp

fileInput proc
    push bx
    push dx
    push cx
    mov bx,fileDescriptor
    xor ax,ax
    jmp inputF
    continue147:
    mov ax,intermediateNumber
    cmp minus,1;  if - was inputed
    JZ MinusNumber1
    continue11:		
        pop cx
        pop dx
        pop bx
ret
fileInput endp

MinusNumber1:
    neg ax
jmp continue11 

inputF:
    PUSH AX
    PUSH CX
    PUSH DX
    mov ah,3fh
    lea dx, char
    mov cx, 1
    int 21h
    xor ax,ax
    mov al,char
    xor cx, cx
    cmp al, '-'
    JZ MinusInput1
    mov minus,0
    sub AL,'0'
    mov intermediateNumber,ax
    xor ax,ax
begin1:
    mov bx,fileDescriptor
    xor ax,ax
    mov ah, 3fh
    lea dx, char
    mov cx, 1
    int 21h
    mov al, char
    cmp ax, 32
    jz end11
    sub AL,'0'
    CMP AL, 16
    JZ end11
    xor cx, cx
    MOV CH,0
    MOV CL,AL
    CMP CX,20
    JZ end11
    MOV AX,intermediateNumber
    MOV BX,10
    MUL BX
    XOR DX,DX
    ADD AX, CX
    mov intermediateNumber,ax
    JMP begin1

end11:
    POP DX
    POP CX
    POP AX
jmp continue147

MinusInput1:
    mov minus,1		
    mov intermediateNumber, 0
JMP begin1

allOutput proc
    cmp ax,0
    jl special
    continue:
    call outputt
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

outputt proc
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
outputt endp

outputLast proc
	push cx
	push ax
	push dx
	push si
	mov cx,rows
	mov si,0
	rowsCycle:
        push cx
        mov cx,colunms
        columnsCycle:
            push bx
            mov ax, colunms
            sub ax,cx 
            mov ax, array[si]
            inc si
            inc si
            call allOutput
            mov dx, offset tabEntry
            call messegeOutput
            xor ax,ax
            xor dx,dx
            pop bx
            loop columnsCycle
	    pop cx
	    mov dx, offset newLine
	    call messegeOutput
	    xor ax,ax
	    xor dx,dx
	    loop rowsCycle
	    pop si
	    pop dx
	    pop ax
	    pop cx
ret
outputLast endp

main:
    mov ax, @data
    mov ds, ax

    xor cx, cx
    xor ax,ax
    mov ah, 3dh ;file input
    lea dx, input
    int 21h
    jc engProgramm
    mov fileDescriptor,ax

    xor ax,ax
    xor dx,dx
    call fileInput
    mov rows,ax

	xor ax,ax
	call fileInput
	mov colunms,ax
	xor bx,bx
	mov bx, rows
	mul bx
	mov quantity, ax

	xor ax,ax
	call fileInput
	xor bx,bx
	mov biggestNumber, ax

	xor ax,ax
	xor bx,bx
	mov cx,quantity
	matrixEntry:
        xor dx,dx
        call fileInput
        mov array[bx], ax
        inc bx
        inc bx
        xor ax,ax
	loop matrixEntry
	
	xor bx,bx
	mov cx,quantity
	matrix:
        push ax
        mov ax,array[bx]
        cmp ax,biggestNumber
        JL continue47		
        mov array[bx],0
        continue47:
        inc bx
        inc bx
        pop ax
	loop matrix
	call outputLast
jmp engProgramm

engProgramm:
	mov ax, 4c00h
	int 21h
end main
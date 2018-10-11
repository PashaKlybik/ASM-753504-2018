.model small
.stack 256
.data
    firstInput dw ?
    secondInput dw ?
    minusNumberc dw 0
    minus db ?
    error1  db 'Error!', 13, 10, '$'
.code
main:
    mov ax, @data
    mov ds, ax

    call allInput
    call allOutput
    mov firstInput,ax
    xor ax,ax
    call allInput
    call allOutput
    mov secondInput,ax
    cmp secondInput, 0
    jz error2
    xor ax,ax
    mov ax,firstInput
    div secondInput
    cmp minusNumberc,1
    jz special1
    pr1:
    call allOutput
    jmp endprogramm

    error2: 
        push ax
        push dx
        mov ah, 9
        mov dx, offset error1
        int 21h
        pop dx
        pop ax
        jmp endprogramm

    special1:
        neg ax
        jmp pr1

    allInput proc
        XOR BX,BX
        CALL input 
        cmp minus,1; if - was inputed
        JZ MinusNumber
        continue1:
        XCHG AX,BX
    ret
    allInput endp

    allOutput proc
        cmp ax,0
        jl special
        continue:
        call output
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

    output proc
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
        output endp

    MinusNumber:
        neg Bx
        jmp continue1 

    input proc
        PUSH AX
        PUSH CX
        PUSH DX
        MOV AH,01h
        int 21h;
		xor ah,ah
        cmp al,'-'
        JZ MinusInput
        mov minus,0
        CMP AL,13;end of the input 
        JZ end1
        sub AL,'0'
        MOV CH,0
        MOV CL,AL
        cmp CX,0 
        jl error
        cmp CX,9
        jg error
        MOV AX,BX
        MOV BX,10
        MUL BX
        jc error
        XOR DX,DX
        ADD AX, CX
        jc error
        XCHG AX,BX
        XOR AX,AX

    begin:
        MOV AH,01h
        int 21h;
		xor ah,ah
        CMP AL,13;end of the input 
        JZ end1
        sub AL,'0'
        MOV CH,0
        MOV CL,AL
        cmp CX,0 
        jl error
        cmp CX,9
        jg error
        MOV AX,BX
        MOV BX,10
        MUL BX
        jc error
        XOR DX,DX
        ADD AX, CX
        jc error
        XCHG AX,BX
        XOR AX,AX
        JMP begin
    end1:
        POP AX
        POP CX
        POP DX
    ret
    input endp
    
    error: 
        mov ah, 9
        mov dx, offset error1
        int 21h
        POP AX
        POP CX
        POP DX
    JMP endprogramm
		
    MinusInput:
        push cx
        mov cx, minusNumberc
        add cx,1
        mov  minusNumberc,cx
        pop cx
        mov minus,1			
        JMP begin
			
    endprogramm:
    mov ax, 4c00h
    int 21h   
end main	
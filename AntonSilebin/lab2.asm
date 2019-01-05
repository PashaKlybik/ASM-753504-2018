.8086
.model small
.386
.stack 100h
.data
    str_task1          db '----Task 1----', 13, 10, 'Printing number from AX register', 13, 10, 'Your number is: ', '$'
    str_task2          db '----Task 2----', 13, 10, 'Entering number', 13, 10, '$'
   	str_task3          db '----Task 3----', 13, 10, 'Number dividing', 13, 10, '$'
    str_zero_dividing  db 'ERROR! Divider cannot be zero. Please, try again', 13, 10, '$'
    str_enter_number   db 'Please, enter number: ', '$'
    str_enter_dividend db 'Please, enter dividend: ', '$'
    str_enter_divider  db 'Please, enter divider: ', '$'
    str_your_quotient  db 'Your quotient is: ', '$'
    str_you_entered    db 'You entered: ', '$'
    str_endline        db 13, 10, '$'
    str_point          db '.', '$'
    buffer             db 7 dup(?)
.code

start:
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di
    xor bp, bp

    mov ax, @data
    mov ds, ax

    call task1
    call task2
    call task3

    jmp exit

exit:
    mov ah, 4ch
    mov al, 0
    int 21h

print_string proc near
    push ax
	mov ah, 09h
    xchg dx, di
    int 21h
    xchg dx, di

    pop ax
    ret
print_string endp

convert_udec_number_to_str proc near
    push ax
    push cx
    push dx
    push bx
    xor cx, cx
    mov bx, 10

wtuds_lp1:
    xor dx, dx
    div bx
    add dl,'0'
    push dx
    inc cx
    test ax, ax
    jnz wtuds_lp1

wtuds_lp2:
    pop dx
    mov [di], dl
    inc di
    loop wtuds_lp2

    pop bx
    pop dx
    pop cx
    pop ax
    ret
convert_udec_number_to_str endp

print_number_udec proc near
    push di
    lea di, buffer
    push di
    call convert_udec_number_to_str
    mov byte ptr [di], '$'
    pop di
    call print_string
    pop di
    ret
print_number_udec endp

print_endline proc near
    push di
    lea di, str_endline
    call print_string

    pop di
    ret
print_endline endp

read_symbol proc near
	mov ah, 07H
	int 21h
	ret
read_symbol endp

print_symbol proc near
    push ax
    mov ah, 02h
    int 21h

    pop ax
    ret
print_symbol endp

convert_symbol_to_digit proc near
    sub al, '0'
    cmp al, 0
    jl cstd_error
    cmp al, 9
    jg cstd_error
    clc
    ret

cstd_error:
    add al, '0'
    stc
    ret
convert_symbol_to_digit endp

convert_digit_to_symbol proc near
    cmp al, 0
    jl cdts_error
    cmp al, 9
    jg cdts_error
    add al, '0'
    ret

cdts_error:
    stc
    ret
convert_digit_to_symbol endp

read_digit proc near
	call read_symbol
	call convert_symbol_to_digit
	ret
read_digit endp

print_digit proc near
    push ax
    push dx
    
    call convert_digit_to_symbol
    mov dl, al
    call print_symbol

    pop dx
    pop ax
    ret
print_digit endp

read_number proc near
	push bx
	push cx
	xor ax, ax
	xor bx, bx
	mov cl, 5
	mov ch, cl

rn_read:
	call read_digit
	jc rn_symbol_read
	cmp ch, 0
	jg rn_digit_read
	jmp rn_read

rn_digit_read:
	cmp ch, 4
	jz rn_check_nil

rn_ok:
	clc
	call check_overflow
	jc rn_read
	clc
	imul bx, 10
	add bl, al
	call print_digit
	dec ch
	jmp rn_read

rn_check_nil:
	cmp bx, 0
	jz rn_read
	jmp rn_ok

rn_symbol_read:
	clc
	cmp al, 08h
	jz rn_symbol_backspace 
	cmp al, 0Dh
	jz rn_symbol_enter
	jmp rn_read

rn_symbol_enter:
	cmp ch, 5
	jnz rn_exit
	jmp rn_read

rn_symbol_backspace:
	cmp ch, cl
	jb rn_sb_print
	jmp rn_read

rn_sb_print:
	push dx
	push cx
	mov ax, bx
	mov cx, 10
	div cx
	mov bx, ax
	pop cx
	pop dx
	call print_backspace
	inc ch
	jmp rn_read

rn_exit:
	call print_enter
	mov ax, bx
	pop cx 
	pop bx
	ret
read_number endp

check_overflow proc near
    push ax
    push bx
    push cx
    push dx

    mov ch, 0
    mov dx, 10
    mov cl, al
    mov ax, bx
    mul dx
    jc co_exit
    add ax, cx

co_exit:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
check_overflow endp

print_enter proc near
	push ax
	push dx
	mov ah, 02h
	mov dl, 10
	int 21h
	mov dl, 13
	int 21h

	pop dx
	pop ax
	ret
print_enter endp

print_backspace proc near
	push ax
	push dx

	mov ah, 02h
	mov dl, 08h
	int 21h
	mov dl, ' '
	int 21h
	mov dl, 08h
	int 21h

	pop dx
	pop ax
	ret
print_backspace endp

task1 proc near
    push ax

    lea di, str_task1
    call print_string
    mov ax, 34535
    call print_number_udec
    call print_endline

    pop ax
    ret
task1 endp

task2 proc near
	push ax

	lea di, str_task2
	call print_string
	lea di, str_enter_number
	call print_string
	call read_number
	lea di, str_you_entered
	call print_string
	call print_number_udec
	call print_endline

	pop ax
	ret
task2 endp

task3 proc near
    push ax
    push bx
    push cx
    push dx

    lea di, str_task3
    call print_string
    lea di, str_enter_dividend
    call print_string
    call read_number
    lea di, str_you_entered
    call print_string
    call print_number_udec
    call print_endline
    mov bx, ax
task3_enter_divider:
    lea di, str_enter_divider
    call print_string
    call read_number
    cmp ax, 0
    jz task3_zero_dividing
    lea di, str_you_entered
    call print_string
    call print_number_udec
    call print_endline
    xchg ax, bx
    call division
    lea di, str_your_quotient
    call print_string
    call print_number_udec
    lea di, str_point	
    call print_string
    mov ax, bx
    call print_number_udec
    call print_endline
    jmp task3_exit

task3_zero_dividing:
    lea di, str_zero_dividing
    call print_string
    jmp task3_enter_divider

task3_exit:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
task3 endp
;  input: AX -> dividend
;         BX -> divider
; output: AX -> quotient
;         BX -> remainder
division proc near
    push cx
    push dx

    xor dx, dx
    div bx

    push ax
    mov ax, dx
    mov cx, 100
    mul cx
    div bx
    mov bx, ax
    pop ax

    pop dx
    pop cx
    ret
division endp

end start
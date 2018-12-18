=.8086
.model small
.386
.stack 100h
.data
    number_string db 13, 10, 'Your number: ', '$'
    buffer db 7 dup(?)
    str_endline db 13, 10, '$'
.code

main:

    mov ax, @data
    mov ds, ax

    call task

    jmp exit

exit:
    mov ah, 4ch
    mov al, 0
    int 21h

task proc near
    push ax

    lea di, number_string
    call print_string
    mov ax, 123
    call print_number_decimal
    call print_endline

    pop ax
    ret
task endp

print_string proc near
    push ax
    mov ah, 09h
    xchg dx, di
    int 21h
    xchg dx, di
    pop ax
    ret
print_string endp

convert_decimal_number_to_string proc near
    push ax
    push cx
    push dx
    push bx
    xor cx, cx
    mov bx, 10

to_stack_loop:
    xor dx, dx
    div bx
    add dl,'0'
    push dx
    inc cx
    test ax, ax
    jnz to_stack_loop

from_stack_loop:
    pop dx
    mov [di], dl
    inc di
    loop from_stack_loop

    pop bx
    pop dx
    pop cx
    pop ax
    ret
convert_decimal_number_to_string endp

print_number_decimal proc near
    push di
    lea di, buffer
    push di
    call convert_decimal_number_to_string
    mov byte ptr [di], '$'
    pop di
    call print_string
    pop di
    ret
print_number_decimal endp

print_endline proc near
    push di
    lea di, str_endline
    call print_string

    pop di
    ret
print_endline endp

end main
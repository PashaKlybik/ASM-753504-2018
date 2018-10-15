.model small
.stack 256
.data
    a dw 134
    buffer db 255 DUP (0)
    wrser_str db 10,"wrong symbol error", 10, '$' 
    ovf_str db 10,"overflow", 10, '$'
    dbz_str db 10,"dividing by zero error", 10, '$'
    dividend db "dividend: $"
    divider db 10,"divider: $"
    result db 10,"result: $"
    separator db "------------------------", 10, '$'
.code
        
print_word proc    
    mov bx, 10
    xor cx,cx
    
    loop1:
    xor dx,dx
    div bx
    push dx
    inc cx
    cmp ax,0
    jnz loop1
        
    cycle:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop cycle
        
    ret
print_word endp

new_row proc
    push dx
    push ax
    mov dl, 10
    mov ah, 02h
    int 21h
    pop ax
    pop dx
    ret
new_row endp
 
; OUT: DX - addr str 
; AL - length str
input proc    
    mov ah, 0Ah
    mov byte [buffer],253
    mov dx, offset buffer + 1
    int 21h
    add dx, 2
    mov al, [buffer+2]
    ret       
input endp

str_to_word proc
    mov si,dx          
    mov di,10          
    xor cx,cx
    mov cl,al          
       
    xor ax,ax          
    xor bx,bx          
    ret
str_to_word endp

str_handler proc
    cycle_sh:
    mov bl,[si]            
    inc si             
    cmp bl,'0'         
    jl wrong_symbol_error         
    cmp bl,'9'         
    jg wrong_symbol_error         
    sub bl,'0'         
    mul di             
    jc overflow_error         
    add ax,bx          
    jc overflow_error         
    loop cycle_sh      
    
    ret
str_handler endp

main:   
    mov ax, @data
    mov ds, ax
        
    lea dx, dividend
    mov ah, 09h
    int 21h
    
    call input
    call str_to_word
    call str_handler
    push ax
    
    lea dx, divider
    mov ah, 09h
    int 21h
    call input
    call str_to_word
    call str_handler    
    
    cmp ax,0
    jz div_by_zero_error
    push ax
    
    lea dx, result
    mov ah, 09h
    int 21h
    
    pop ax    
    mov bx, ax
    pop ax
    xor dx,dx
    div bx
    call print_word
    call new_row
    jmp exit
    
    div_by_zero_error:
    lea dx, dbz_str
    jmp show_error
    
    wrong_symbol_error:
    lea dx, wrser_str
    jmp show_error
    
    overflow_error:
    lea dx, ovf_str
    
    show_error:
    mov ah, 09h
    int 21h 
    lea dx, separator
    mov ah, 09h
    int 21h 
    jmp main    
    
    exit:          
    mov ax, 4c00h
    int 21h
end main
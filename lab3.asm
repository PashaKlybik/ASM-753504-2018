.model small
.stack 256
.data
    buffer db 255 DUP (0)
    wrser_str db 10,"wrong symbol error", 10, '$' 
    ovf_str db 10,"overflow", 10, '$'
    dbz_str db 10,"dividing by zero error", 10, '$'
    emptop_str db 10,"empty operand error" , 10, '$' 
    dividend db "dividend: $"
    divider db 10,"divider: $"
    result db 10,"result: $"

.386

.code
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

input_signed_word proc
    push dx               
    call input_str  
    call str_to_signed_word
    pop dx                  
    ret 
input_signed_word endp
 
; OUT: DX - addr str 
; AL - length str
input_str proc
    push cx         
    mov cx,ax       
    mov ah,0Ah      
    mov [buffer],al 
    mov byte[buffer+1],0   
    mov dx, offset buffer  
    int 21h         
    mov al,[buffer+1]  
    add dx,2           
    mov ah,ch          
    pop cx             
    ret
input_str endp
    
str_to_unsigned_word proc
    push bx

    mov si,dx          
    mov di,10          
    xor cx,cx
    mov cl,al          
       
    xor ax,ax          
    xor bx,bx       
    
    handler_loop:
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
    loop handler_loop   
    
    pop bx 
     
    ret   
str_to_unsigned_word endp

str_to_signed_word proc
    push bx         
    push dx

    test al,al      
    jz empty_operand_error  
    mov bx,dx       
    mov bl,[bx]     
    cmp bl,'-'      
    jne unsigned      
    inc dx          
    dec al          
unsigned:
    call str_to_unsigned_word
    jc stsdw_exit   
    cmp bl,'-'      
    jne positive_op  
    cmp ax,32768    
    ja overflow_error  
    neg ax  
    jmp negative_op    
positive_op:
    cmp ax,32767    
    ja overflow_error  
negative_op:
    clc             
    jmp stsdw_exit              
stsdw_exit:
    pop dx          
    pop bx
    ret
str_to_signed_word endp

print_word proc  
    push bx
    push cx
    push dx
  
    mov bx, 10
    xor cx,cx
    
    reader_loop:
    xor dx,dx
    div bx
    push dx
    inc cx
    cmp ax,0
    jnz reader_loop
        
    print_loop:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop print_loop

    pop dx
    pop cx
    pop bx
    
    ret
print_word endp

dividing proc
    push cx
    push dx
    
    mov cx, bx
    xor cx, ax
    cmp cx, 32768
    jc positive
    push ax
    mov dl, '-'
    mov ah, 02h
    int 21h    
    pop ax
    
    positive:
    cmp ax, 32768
    jc direct_code_1
    neg ax
    direct_code_1:
    cmp bx, 32768
    jc direct_code_2
    neg bx
    direct_code_2:
    xor dx,dx
    div bx
    
    pop dx
    pop cx
    
    ret
dividing endp

main:       
    mov ax, @data
    mov ds, ax
    
    lea dx, dividend
    mov ah, 09h
    int 21h    
    call input_signed_word
    call new_row
    push ax
    
    lea dx, divider
    mov ah, 09h
    int 21h
    call input_signed_word
    cmp ax, 0
    jz div_by_zero_error
    call new_row
    mov bx, ax
    pop ax
    
    push ax
    lea dx, result
    mov ah, 09h
    int 21h
    pop ax
    call dividing
    
    call print_word
    
    jmp main_exit
    
div_by_zero_error:
    lea dx, dbz_str
    jmp show_error
    
wrong_symbol_error:
    lea dx, wrser_str
    jmp show_error
    
overflow_error:
    lea dx, ovf_str
    jmp show_error

empty_operand_error: 
    lea dx, emptop_str    

show_error:
    mov ah, 09h
    int 21h  

main_exit:
    
    mov ax, 4c00h
    int 21h
end main
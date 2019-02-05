.model small
.stack 100h
.data

input_message db 'Input: $'
output_message db 'Ouput: $'
error_message db 'Error. Input error! Try again!',10,13,'$'
str1 db 100 dup("?"); 
len1 dw 0
str2 db 100 dup("?"); 
len2 dw 0
rez dw 0
result dw 0


.code

assume ds:@data, es:@data
input proc                     
    mov AH, 3fh                       
    lea DX, str1                       
    mov CX, 100                       
    mov BX, 0                          
    int 21h                           
    sub AX, 3                        
    mov len1, AX                    

ret                           
input endp

output proc
    push cx
    push dx
    push bx
    push ax

    mov bx, 10
    xor cx,cx 
    
    test ax, ax

    for1:
    xor dx, dx 
    div bx

    push dx 
    inc cx  
    test ax,ax  
    jnz for1
    mov ah, 02h 

    for2:
    pop dx  
    add dl, 30h 
    int 21h
    loop for2

    pop ax  
    pop bx
    pop dx
    pop cx
    ret

output endp

do_work proc
    
    lea di,str1
    xor bx,bx
    mov cx,len1
    
    
cntn:
    cmp bx, 0
    jz first   
    cmp byte ptr[di],20h
    jnz not_needed
    
    first:
    
    
    cmp byte ptr[di+bx],'a' ;a
    jz needed
    cmp byte ptr[di+bx],'A' ;A
    jz needed
    cmp byte ptr[di+bx],'e' ;e
    jz needed
    cmp byte ptr[di+bx],'E' ;E
    jz needed
    cmp byte ptr[di+bx],'i' ;i
    jz needed
    cmp byte ptr[di+bx],'I' ;I
    jz needed
    cmp byte ptr[di+bx],'o' ;o
    jz needed
    cmp byte ptr[di+bx],'O' ;O
    jz needed
    cmp byte ptr[di+bx],'u' ;u
    jz needed
    cmp byte ptr[di+bx],'U' ;U
    jz needed
    jmp not_needed
    needed:
    
    inc result

    
    not_needed:
    
    mov bx, 1
    inc di

    loop cntn
    mov ax, result
ret
do_work endp

start:
    mov ax, @data 
    mov ds, ax
    mov es, ax
    
    call input                     
    mov AX, len1                        
    cmp AX, 0                          
    jne J_preparing                    
    jmp J_programm_end                 

J_preparing:
    call do_work
    call output
    call J_programm_end

J_programm_end:
    mov ah, 4ch                         
    int 21h                             

end start
model small                    
.stack 100h         

.data
devident dw 0
devider dw 0
inputdevident db "Enter devident: ", '$'
inputdevider db "Enter devider: ", '$'
results db "Result:", 13, 10, "integer = ", '$'
fractional db ", fractional = $"
exzero db "Division by zero!", 13, 10, '$'
repeat db 13, 10,"Repeat please!", 13, 10, '$'
n db 10,"$"
u dw 10
temp dw 0
ost dw ?
cel dw ?
.code

InputInt proc   

        entersymbol:
        mov ah, 01h 
        int 21h
        xor ah, ah 
        cmp ax, 13 
        jz firstend
        cmp ax, 48 
        jc error   
        cmp ax, 57 
        jz next1  
        jnc error 

        next1:
                sub al, 48
                xor ah, ah  
                mov bx, ax  
                mov ax, temp 
                mul u
                jc error
                add ax, bx 
                jc error
                mov temp, ax 
                jmp entersymbol

        error:
                lea dx, repeat 
                mov ah, 09h
                int 21h
                xor ax, ax
                mov temp, ax
                jmp entersymbol 

        firstend:
        ret

InputInt endp 

OutputInt proc
        xor cx,cx 

        next2:
                xor dx, dx
                div u
                push dx
                xor dx, dx
                inc cx
                cmp ax, 0 
                jnz next2  

        cycle:
                pop dx 
                mov DH, 0
                add dl, 48
                mov ah, 02h
                int 21h 
                loop cycle 
                ret
OutputInt endp 

func proc
        push ax
        push dx

        lea dx, n
        mov ah, 09h 
        int 21h

        pop dx
        pop ax

        ret
func endp

main:  
mov ax, @data        
mov ds, ax     

lea dx, inputdevident   
mov ah, 09h
int 21h
call InputInt  
push temp
pop devident
mov temp, 0

lea dx, inputdevider    
mov ah, 09h
int 21h
call InputInt
push temp
pop devider
mov temp, 0 

cmp devider, 0
jz label1 

mov ax, devident
cwd  
div devider

mov cel, ax 
mov ost, dx 

lea dx, results        
mov ah, 09h
int 21h    
mov ax, cel  
call outputint

lea dx, fractional      
mov ah, 09h
int 21h
mov ax, ost 
call outputint

call func

mov ah, 4Ch
int 21h     

label1:
lea dx, exzero       
mov ah, 09h
int 21h  
        
mov ah, 4Ch
int 21h
END main
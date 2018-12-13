.model small
.stack 1000
.data
        old dd 0 
        s db "abc", '$'
.code
.486
        count db 0 
 
new_handle proc far      
        push ds si es di dx cx bx ax 
        
        xor ax, ax 
        xor dx, dx
        in  ax, 60h           ; ввод значения из порта ввода      
        cmp ax, 38h           ; &
        je switch             ; если =

        mov dl, count
        cmp dl, 1
        je old_handler        ; если =

        cmp al, 12h        
        mov dl, 'f'
        je new_handler
        cmp al, 15h      
        mov dl, 'z'
        je new_handler
        cmp al, 16h        
        mov dl, 'v'
        je new_handler
        cmp al, 17h        
        mov dl, 'j'
        je new_handler
        cmp al, 18h        
        mov dl, 'p'
        je new_handler
        cmp al, 1Eh        
        mov dl, 'b'
        je new_handler
        jmp old_handler

        switch:

        mov al, 1
       	add count, al
       	mov al, count
       	cmp al, 2
       	jne exit
       	mov count, 0
       	jmp exit

        new_handler:
         		
       	mov ah, 02h
       	int 21h
  	;mov ah, 02h
       	;int 21h
	jmp exit
       
        old_handler:

        pop ax bx cx dx di es si ds                       
        jmp dword ptr cs:old        
                
        exit:
        xor ax, ax
        mov al, 20h
        out 20h, al 
        pop ax bx cx dx di es si ds 
        iret                        
new_handle endp
 
 
new_end:
 
start:
        mov ax, @data
        mov ds, ax
        
        cli                         ; сброс флага IF
        pushf                       ; сохр. регистров в стеке
        push 0        
        pop ds
        mov eax, ds:[09h*4]         ; сохранение селектора
        mov cs:[old], eax 
        
        mov ax, cs
        shl eax, 16                 ; сдвид влево            
        mov ax, offset new_handle   
        mov ds:[09h*4], eax         
        sti 
        
        xor ax, ax
        mov ah, 31h
        MOV DX, (New_end - @code + 10FH) / 16 
        INT 27H 
end start
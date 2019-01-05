.model small
.386 ; for movzx
.stack 100h

.data 
     thri dw 3 
     index dw 0
     n dw 0
     a dw 0 
     b dw 0
     c dw 0 
     max db 200
     len db ?                  
     inputstruing db 200 dup('$')
     stringvowellen db 12
     stringvowel db "aeiouyAEIOUY$"
     message1 db "Starting line:$"
     message2 db "End line:$"
 .code
 
    search proc 
        push ax
        push dx
        mov dl, inputstruing[si+ 1] 
        cmp dl, ' '
        jne repeat
        inc si
        jmp exit 

        repeat:
        mov dl, inputstruing[si]
        cmp dl,' '
        jz exit 
        inc si
        jmp repeat
        
        exit: 
        pop dx
        pop ax
        
        ret
    search endp

    stringnew proc
        push ax
        push dx
        mov ah, 02h
        mov dl, 13
        int 21h
        mov dl, 10
        int 21h
        pop dx
        pop ax
        
        ret
    stringnew endp

    delwordbeginvowel proc
        push bx
        push cx
        push dx
        push si
        movzx cx, len 
        mov c, cx
        xor si, si
        searchvowel:
            push cx
            push ax 
            mov al, inputstruing[si]
            lea di, stringvowel
            movzx cx, stringvowellen
            repne scasb
            jne letternext
            
            checkbeginning:
            cmp si, 0
            jz beginningofword	
            mov dl, inputstruing[si- 1] 
            cmp dl, ' '
            jne letternext
            
            beginningofword:
            pop ax
            mov a, si
            call search
            mov b, si
            mov si, a
            mov ax, b 
            sub ax, a
            add ax, 1
            mov b, ax 
            
            return:
            mov ax, si
            add ax, b 
            mov a, si
            mov si, ax
            mov dl, inputstruing[si]
            mov si, a 
            mov inputstruing[si], dl
            cmp c, si
            jz next1
            inc si
            jmp return
            
            next1:
            xor si, si
            push ax
            pop ax
            pop cx
        
        loop searchvowel
        jmp label1	
        
        letternext:
        inc si	
        pop ax
        pop cx
        loop searchvowel
        
        label1:
        pop si
        pop dx
        pop cx
        pop bx
        
        ret
    delwordbeginvowel endp

 main:
    mov ax, @data
    mov ds, ax
    mov es, ax
    call stringnew 
    lea dx, message1 
    mov ah, 09h 
    int 21h 
    call stringnew 
     
    lea dx, max
    mov ah, 0Ah
    int 21h
    call stringnew 
    call delwordbeginvowel
    call delwordbeginvowel
    call stringnew 
    lea dx, message2 
    mov ah, 09h 
    int 21h 
    call stringnew 
    mov dx, offset inputstruing
    mov ah, 09h
    int 21h
    call stringnew 
    call stringnew 
    
    mov ax, 4Ch
    int 21h	
 END main 
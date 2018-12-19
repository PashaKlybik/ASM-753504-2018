.8086
.model small
.386
.stack 100h
.data 
    thri dw 3 
    index dw 0
    n dw 0
    a dw 0 
    b dw 0
    c dw 0 
    max db 100
    length db ?                  
    input_str db 100 dup('$')
    vowel_str_length db 12
    vowel_str db "AEIOUYaeiouy$"
    your_str_msg db "your string:$"
    result_msg db "result:$"
 .code
 
    search proc 
        push ax
        push dx

        mov dl, input_str[si+ 1] 
        cmp dl, ' '
        jne repeat  
        inc si
        jmp exit_search

        repeat:
            mov dl, input_str[si]
            cmp dl,' '
            jz exit_search
            inc si
            jmp repeat
        
        exit_search: 
            pop dx
            pop ax
            ret
    search endp

    input proc
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
    input endp

    words_start_vowels proc
        push bx
        push cx
        push dx
        push si	
        movzx cx, length 
        mov c, cx
        xor si, si

        word_loop:
            push cx
            push ax  
            
            mov al, input_str[si]
            lea di, vowel_str
            movzx cx, vowel_str_length
            repne scasb  ;сравнение с гласной
            jne next_byte

            cmp si, 0   ;проверка на начало
            jz if_begining	
            mov dl, input_str[si- 1] 
            cmp dl, ' '
            jne next_byte

            if_begining:
                pop ax
                mov a, si
                call search
                mov b,si
                mov si,a
                mov ax,b 
                sub ax,a
                add ax,1
                mov b,ax 

            return:
                mov ax, si
                add ax,b 
                mov a, si
                mov si, ax
                mov dl,input_str[si]
                mov si,a 
                mov input_str[si], dl
                cmp c, si
                jz continue
                inc si
                jmp return

            continue:
                mov si,0
                push ax
                pop ax
                pop cx
        loop word_loop

        jmp exit_word_vowels

        next_byte:
        inc si	
        pop ax
        pop cx
        loop word_loop
        exit_word_vowels:
            pop si
            pop dx
            pop cx
            pop bx
    ret
    words_start_vowels endp

 main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    call input 
    lea dx, your_str_msg 
    mov ah, 09h 
    int 21h 
    call input 
     
    lea dx, max
    mov ah, 0ah
    int 21h
    call input 

    call words_start_vowels
    call words_start_vowels
    
    call input 
    lea dx, result_msg 
    mov ah, 09h 
    int 21h 
    call input 
    
    mov dx, offset input_str
    mov ah,09h
    int 21h
    call input 

    mov ax, 4c00h
    int 21h	
 end main 
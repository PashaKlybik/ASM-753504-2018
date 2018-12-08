model small
stack 256
dataseg
    string db 200 dup('$')
    newString db 200 dup('$')
    maxWord db 32 dup('$')
    minWord db 32 dup('$')
    max dw 0
    maxPos dw 0
    min dw 200
    minPos dw 0
codeseg


;-----INPUT-----
Input proc      ; Reads the line before 'Enter' is hit (200 symbols)
    push ax
    push si
        xor si, si
        ReadLoop:
            mov ah, 01h             
            int 21h
            cmp al, 13
            je finish
            mov string[si], al
            inc si
            cmp si, 200
            je finish
        jmp ReadLoop
    finish:
    pop si
    pop ax
    ret
Input endp


;-----OUTPUT-----
Output proc    
    push ax
    push si
        mov ah, 09h
        int 21h
    pop si
    pop ax
    ret
Output endp


;-----NEW LINE-----
NewLine proc
    push ax
    push dx
        mov dx, 10
        mov ah, 2   
        int 21h 
        mov dx, 13
        mov ah, 2   
        int 21h 
    pop dx
    pop ax
    ret
NewLine endp

;-----COPY WORD-----
CopyWord proc
    ContinueCopy:
        lodsb
        stosb
        cmp al, ' '
        je EndCopy
        cmp al, '$'
        je EndCopy
        jmp ContinueCopy
    EndCopy:
    ret
CopyWord endp

;-----SWAP WORDS-----
SwapWords proc ;Swaps max & min words in a string
    push ax
    push si
    push di
    push cx
    push dx
    push bx
    xor si, si
    xor cx, cx
    lea si, string 
    Read:     ;Looks for lengh & position of max and min words
        inc cx
        lodsb 
        mov dx, 1
        cmp al, '$'
        je LastOne
        xor dx, dx
        cmp al, ' '
        jne Read
        cmp cx, 1
        je Zero
        LastOne:
            cmp cx, max
            jb IsItMin
            ; if it's max word for now
            mov max, cx
            push si
                sub si, max
                mov maxPos, si
            push di
                lea di, maxWord
                call CopyWord
            pop di 
            pop si
            jmp Zero
        IsItMin:
            cmp cx, min
            ja Zero
            ; if it's min word for now
            mov min, cx
            push si
                sub si, min
                mov minPos, si
            push di
                lea di, minWord
                call CopyWord
            pop di
            pop si
        Zero:
        mov cx, 0
        cmp dx, 1
        jne Read
    FinishRead:
    lea si, string
    lea di, newString
    InsertNew:
        cmp si, minPos
        je InsertMax
        cmp si, maxPos
        je InsertMin
        lodsb
        stosb
        cmp al, '$'
        jne InsertNew
        je Endf
	;Pastes max word into string (ingnoring the min one)
        InsertMax:
            add si, min
            sub si, 1
            push si
                lea si, maxWord
                ReadMaxLoop:
                    lodsb
                    cmp al, '$'
                    je FinishMaxInsert
                    cmp al, ' '
                    je FinishMaxInsert
                    stosb
                jmp ReadMaxLoop
            FinishMaxInsert:
            pop si
        jmp InsertNew
	;Pastes min word into string (ignoring the max one)
        InsertMin:
            add si, max
            sub si, 1
            push si
                lea si, minWord
                ReadMinLoop:
                    lodsb
                    cmp al, '$'
                    je FinishMinInsert
                    cmp al, ' '
                    je FinishMinInsert
                    stosb
                jmp ReadMinLoop
            FinishMinInsert:
            pop si
        jmp InsertNew
    Endf:
    pop bx
    pop dx
    pop cx
    pop di
    pop si
    pop ax
    ret
SwapWords endp

;-----MAIN-----
main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    call Input
    call NewLine
    call SwapWords
    lea dx, newString
    call Output
    call NewLine

    mov ah, 4ch
    int 21h
end main

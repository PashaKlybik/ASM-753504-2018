.model small
.stack 256
.data

i dw 0
prev dw 0

sourceString db 64 dup('$'), '$'
finalString db 64 dup(' '), '$'

partsLengthsArray db 4 dup(0)
indexOfPart dw 0

len dw ?
cnt db 0    ; 0, 1, 2 in logic of number of words to swap

left dw 0   ; pointer to sourceString
leftOfFinalString dw 0
right dw 0
lastProcessedChar dw 0

fileName db 'input.txt', 0
handle dw 0

.code

ASSUME ds:@data,es:@data     

endl proc
    push dx
    push ax

    mov dl, 0AH
    mov ah, 02h
    int 21h
    
    pop ax
    pop dx
    ret
endl endp

SwapWordsInRange proc   ; swap words in range like  " lpol  lpoo "
    push ax
    push bx
    push cx
    push i
    push left

    mov ax, prev
    mov right, ax

    lea bx, partsLengthsArray     ; set pointer of partsLengthsArray to indexOfPart
    mov indexOfPart, bx
    mov byte ptr[bx], 0

    ; cx = right - left + 1
    mov cx, right
    sub cx, left
    inc cx

    mov ax, left
    mov i, ax
    mov lastProcessedChar, ' '

    iterateRange:
        ; :: cmp [i], ' '
        mov si, i
        lods sourceString
        cmp al, ' '

        pushf   ; push flags to stack
        pop ax

        cmp lastProcessedChar, ' '
        pushf
        pop bx

        xor ax, bx 
        ; al = 0 if two spaces came or two NOTspaces came
        and al, 01000000b   ; zf flag only (6-x flag) (al lowest register)
        
        cmp al, 0
        ; if ((s[i] == ' ' xor s[i - 1] != ' '))
        jz continueInsideLoop
        
        inc indexOfPart 
        ; clear array[index]
        mov bx, indexOfPart
        mov byte ptr[bx], 0

        continueInsideLoop:
            ; :: mov ax, [i]
            mov ah, 0
            mov si, i
            lods sourceString

            ; current symbol is last processed    
            mov lastProcessedChar, ax

            inc i ; move pointer 
            
            ; :: inc [indexOfPart] 
            ; partsLengthsArray[currentPart]++
            mov si, indexOfPart
            lods partsLengthsArray
            inc al
            mov di, indexOfPart
            stos partsLengthsArray
    loop iterateRange

    lea ax, partsLengthsArray       ; set pointer of partsLengthsArray to indexOfPart
    mov indexOfPart, ax

    cld     ; reset flag DF - from begin to end of the string

    call InitLeftPointerFinalStr

    mov di, leftOfFinalString 

    mov si, indexOfPart
    mov ah, 0
    lods partsLengthsArray     ; lods writes to al
    add di, ax      ; spaces at the begining of new range

    mov bx, left
    mov cx, 3
    ; si = left + a[0] + a[1] + a[2]
    getSecondWordFromRange:
        ; :: add bx, [indexOfPart]
        mov si, indexOfPart
        mov ah, 0
        lods partsLengthsArray

        add bx, ax
        inc indexOfPart
    loop getSecondWordFromRange

    ; :: mov cx, [indexOfPart] 
    ; now *indexOfPart = partsLengthsArray[3] 
    mov si, indexOfPart
    mov ch, 0
    lods partsLengthsArray
    mov cl, al     ; cx = partsLengthsArray[3]
    mov dx, cx

    mov si, bx
    rep movs finalString, sourceString
    
    ; di = leftOfFinalString + a[0] + a[2] + a[3]
    ; add dx, [indexOfPart]
    add dx, leftOfFinalString ;di
    mov bx, left ;si

    call getPrev ;get a[2]
    add dx, ax

    call getPrev ;get a[1]
    mov cx, ax

    call getPrev ;get a[0]
    add dx, ax


    ; :: add bx, [indexOfPart]
    add bx, ax

    mov di, dx
    mov si, bx

    rep movs finalString, sourceString

    pop left
    pop i
    pop cx
    pop bx
    pop ax

    ret
SwapWordsInRange endp

getPrev proc
    dec indexOfPart ; get a[i]
    mov si, indexOfPart
    mov ah, 0
    lods partsLengthsArray

    ret
getPrev endp

InitLeftPointerFinalStr proc
    push ax
    push bx

    lea ax, finalString
    mov leftOfFinalString, ax

    mov ax, left
    lea bx, sourceString

    sub ax, bx
    add leftOfFinalString, ax

    pop bx
    pop ax

    ret
InitLeftPointerFinalStr endp


main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    mov ah,3dh  ; open file
    xor al,al   ; only reading
    mov dx, offset fileName        
    xor cx,cx   ; usual file
    int 21h                 

    mov [handle],ax    ; save file descriptor 
 
    mov bx,ax               
    mov ah,3Fh    ; reading from file
    mov dx, offset sourceString    ; buffer
    mov cx,64
    int 21h                 
    mov bx, offset sourceString
    add bx,ax    ; in ax amount of read bytes
    mov byte ptr[bx],'$'        
    
    mov len, ax    ; len ~ string length

    mov bx, offset finalString
    add bx, ax

    mov byte ptr[bx],'$'
    
    mov cx, len

    lea ax, sourceString
    mov i, ax

    mov prev, ax
    mov left, ax
    inc i
    dec cx

    cmp cx, 0
    jz inputEnded ; one word only

    iterateInput:
        ; if now == ' ' && previous != ' '

        ; cmp [i], ' ' ; 
        mov si, i
        lods sourceString

        cmp al, ' '
        jnz continueLoop
    
        ; cmp [prev], ' '; 
        mov si, prev
        lods sourceString

        cmp al, ' '
        jz continueLoop
        
        inc cnt

        cmp cnt, 2
        jnz continueLoop

        call SwapWordsInRange   ;(left, prev)

        mov cnt, 0
        mov ax, i
        mov left, ax

        continueLoop:        
            inc i
            inc prev
    loop iterateInput

inputEnded:
    mov bx, prev
    cmp byte ptr[bx], ' '
    jz skipAdding

    inc cnt

skipAdding:
    cmp cnt, 2
    jnz justCopy

    call SwapWordsInRange
    jmp exit

justCopy: ; if words % 2 = 1
    mov cx, prev
    sub cx, left
    inc cx

    call InitLeftPointerFinalStr

    mov si, left
    mov di, leftOfFinalString

    rep movs finalString, sourceString
    
exit:
    lea dx, finalString
    mov ah, 09h
    int 21h

    mov ah,3eh    ; close file
    mov bx,[handle]    ; file descriptor
    int 21h                 

    ; call endl
    mov ax, 4c00h
    int 21h
end main

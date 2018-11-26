.model small
.stack 256
.data

cntDigits dw 0
ten dw 10
incorrectInput db "Incorrect input$"
n dw ?
m dw ?

matrix1 dw 128 dup(0)
matrix2 dw 128 dup(0)

inputFileName db 'input.txt', 0
outputFileName db 'output.txt', 0

handle dw 0

singlechar db ?

pt1 dw ?
pt2 dw ?

.code

assume ds:@data,es:@data     

printCharToFile proc
    push bx
    push ax
    push dx
    push cx

    mov singlechar, al

    mov bx, [handle]
    mov ah, 40h
    mov dx, offset singlechar
    mov cx, 1
    int 21h 

    pop cx
    pop dx
    pop ax
    pop bx
    ret
printCharToFile endp

endl proc
    push ax

    mov al, 0AH
    call printCharToFile
    
    pop ax
    ret
endl endp

space proc
    push ax

    mov al, 32
    call printCharToFile
    
    pop ax
    ret
space endp

uprintf proc
    push ax
    push cx
    push dx

    mov cx, 0
    mov dx, 0 

    division :
        div ten
        push dx
        mov dx, 0
        inc cx

        cmp ax, 0
        jnz division

    cmp cx, 0
    jnz nonZeroCame
    
    push 0
    mov cx, 1
    
    nonZeroCame:
        pop dx
        add dx, '0'
        mov ax, dx
        call printCharToFile
    loop nonZeroCame

    pop dx
    pop cx
    pop ax
    ret
uprintf endp

printf proc 
    push bx
    push dx
    push ax

    cwd
    cmp dx, 0
    jz plus

    mov bx, ax

    mov dx, '-'
    mov ax, dx
    call printCharToFile

    mov ax, bx
    neg ax

    plus:
        call uprintf

    pop ax
    pop dx
    pop bx
    ret
printf endp

getCharFromFile proc
    push bx
    push dx
    push cx

    mov bx, [handle]
    mov ah, 3Fh ; reading from file
    mov dx, offset singlechar ; buffer
    mov cx, 1
    int 21h     

    mov al, singlechar

    pop cx
    pop dx
    pop bx
    ret
getCharFromFile endp

scanf proc
    push si
    push dx
    push bx
    push cx

    scanfPrep:
    mov bx, 0
    mov dx, 0
    mov cntDigits, 0

    call getCharFromFile

    cmp al, '-'
    jz negative
    
    mov si, 0
    jmp skipReading

    negative:
        mov si, 1
    
    reading:
        call getCharFromFile

        skipReading:

        cmp al, 9
        jz goodInput

        cmp al, 10
        jz goodInput

        cmp al, 32
        jz goodInput

        cmp al, 48 
        jc badInput 

        cmp al, 58
        jnc badInput

        mov cl, al 

        mov ax, bx
        mul ten
        mov bx, ax

        cmp dx, 0 
        jnz badInput 

        sub cl, 48
        mov ch, 0
        add bx, cx 

        inc cntDigits

        jc badInput
    jmp reading

    goodInput:
        cmp cntDigits, 0
        jz scanfPrep 

        mov ax, bx
        jmp validateRange

    badInput:
        lea dx, incorrectInput
        mov ah, 09h
        int 21h

        mov ax, 4c00h
        int 21h
    validateRange:
        add si, 32767
        cmp ax, si
        ja badInput 

        sub si, 32767
        cmp si, 1

        jnz scanfFinish
        neg ax

    scanfFinish:
        pop cx
        pop bx
        pop dx
        pop si
    ret
scanf endp

inputArray proc
    push cx

    mov pt1, ax
    mov cx, n

    inputArrayOuter:
        push cx
        mov cx, m
        inputArrayInner:
            call scanf
            mov bx, pt1
            mov word ptr[bx], ax
            add pt1, 2
        loop inputArrayInner
        pop cx
    loop inputArrayOuter
    
    pop cx
    ret
inputArray endp

outputArray proc
    push cx

    mov cx, n
    outputArrayOuter:
        push cx
        mov cx, m
        outputArrayInner:
            mov bx, pt1
            mov ax, word ptr[bx]

            call printf
            call space
            add pt1, 2
        loop outputArrayInner
        pop cx
        call endl
    loop outputArrayOuter

    pop cx
    ret
outputArray endp

closeFile proc 
    push ax
    push bx

    mov ah,3eh    ; close file
    mov bx,[handle]    ; file descriptor
    int 21h

    pop bx
    pop ax
    ret
closeFile endp

solve proc
    push dx
    push bx
    push ax
    push cx

    mov cx, n
    solveOuter:
        push cx
        mov cx, m
        solveInner:
            mov bx, pt2
            mov dx, word ptr[bx]

            mov bx, pt1
            mov ax, word ptr[bx]

            cmp ax, dx

            jge skip
            mov ax, dx
            skip:

            mov word ptr[bx], ax

            add pt1, 2
            add pt2, 2
        loop solveInner
        pop cx
    loop solveOuter

    pop cx
    pop ax
    pop bx
    pop dx
    ret
solve endp

openFile proc near
    push cx

    xor al, al
    xor cx, cx
    int 21h
    mov [handle], ax

    pop cx
    ret
openFile endp

main:
    mov ax, @data
    mov ds, ax
    mov es, ax    

    mov dx, offset inputFileName
    mov ah, 3dh

    call openFile
 
    call scanf
    mov n, ax
    call scanf
    mov m, ax

    lea ax, matrix1
    call inputArray

    lea ax, matrix2
    call inputArray

    call closeFile

    lea ax, matrix1
    mov pt1, ax
    lea ax, matrix2
    mov pt2, ax

    call solve

    mov dx, offset outputFileName
    mov ah, 3ch

    call openFile

    lea ax, matrix1
    mov pt1, ax
    call outputArray

    call closeFile
    mov ax, 4c00h
    int 21h
end main

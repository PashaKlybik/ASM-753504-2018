CSEG segment 
assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG 
org 80h            
    cmdLength db ?	
    cmdLine db ? 
org 100h 

Start: 
jmp Init 
 
;-----INTERRUPTION HANDLER----- 
Int_21h_proc proc 
    cmp ah,9              
    je Ok_09 
        jmp dword ptr cs:[Int_21h_vect] 
    Ok_09: 
        pushf
        push dx
        push cx
        push bx
        push si
        push di
        push es
            ;deny interruption
            cli
            cld
            push cs
            pop es
            mov cx, BufLen
            mov si, dx
            lea dx, buffer
            mov di, dx
            CopyStringToBuff:
                cmp byte ptr ds:[si], '$'        
                je AddDollarToEnd
                cmp cx, 0
                je BufferIsFull
                movsb
                ;process copied symbol
                push si
                dec di                         
                lea si, vowels
                mov bl, byte ptr cs:[di]
                CmpWithVowelArray:
                    cmp byte ptr cs:[si], '$'
                    ;if not vowel we skip it
                    je NextChar
                    cmp bl, byte ptr cs:[si]
                    je IsVowel
                    inc si
                    jmp short CmpWithVowelArray
                    NextChar:
                        inc di
                        dec cx
                    IsVowel:
                        pop si
                        jmp short CopyStringToBuff
                AddDollarToEnd:                       
                    movsb
                    dec si
            BufferIsFull:
                push ds
                push cs
                pop ds
                pushf
                call dword ptr cs:[Int_21h_vect]
                pop ds
                mov cx, BufLen
                mov di, dx
                cmp byte ptr ds:[si], '$'
                jne CopyStringToBuff
        ;allow interruption
        sti
        pop es
        pop di
        pop si
        pop bx
        pop cx
        pop dx
        popf
        iret
    BufLen = 50
    vowels db "aeiouyAEIOUY$"
    buffer db BufLen dup (?), '$'       
int_21h_proc endp 

;create 40th interruption handler to check whether 21st interruption is set
Int_40h_proc proc 
    cmp ah, 2
    je Ok_02
    jmp dword ptr cs:[Int_40h_vect] 
    Ok_02: 
        mov al, 1
        iret   
int_40h_proc endp

;empty 40th interruption handler
int_40h_empty proc
    iret
int_40h_empty endp


Int_21h_vect dd ?
Int_40h_vect dd ?

;-----MESSAGES-----
wasInstalled db 'Interruption was installed',0Dh,0Ah,'$'
invalidArguments db 'Arguments are invalid',0Dh,0Ah,'$'
notInstalled db 'Interruption was not installed',0Dh,0Ah,'$'
isInstalled db 'Interruption is installed successfully',0Dh,0Ah,'$'
unableToRemove db 'Interruption can not be removed',0Dh,0Ah,'$'


;-----INIT-----
Init: 
    ;get command line arguments
    cmp byte ptr cmdLength, 0
    je ZeroArgs
    cmp byte ptr cmdLength, 3
    jne CmdError
    cmp byte ptr cmdLine[1],'-'
    jne CmdError
    cmp byte ptr cmdLine[2],'d'
    jne CmdError
    
    ;pass -d to command line
    xor al, al
    mov ah, 2
    int 40h
    cmp al, 0
    jne CantUninstall
    ;if not setup
    lea dx, notInstalled
    jmp MessageAndExit
    ;if setup
    CantUninstall:
    lea dx, unableToRemove
    jmp MessageAndExit
    
    ;no argumets were passed to the programm
    ZeroArgs:
        xor al, al
        mov ah, 2
        int 40h
        cmp al, 0
        je Install
        lea dx, wasInstalled
        jmp MessageAndExit

    ;pass wrong arguments
    CmdError:
        lea dx, invalidArguments
        jmp MessageAndExit
    
    ;interruptions setup
    Install:
        mov ah,35h 
        mov al,21h 
        int 21h 

        mov word ptr Int_21h_vect,bx
        mov word ptr Int_21h_vect+2,es 
        
        mov ah,35h 
        mov al,40h 
        int 21h 

        mov word ptr Int_40h_vect,bx
        mov word ptr Int_40h_vect+2,es 

        mov ax,2521h 
        lea dx, Int_21h_proc    
        int 21h 

        mov ax,2540h 
        lea dx, int_40h_proc    
        int 21h 
        
        mov ah, 9
        lea dx, isInstalled
        int 21h
        
        lea dx, Init 
        int 27h 
    
    ;print message and exit
    MessageAndExit:
        mov ah, 9
        int 21h
        mov ax, 4c00h
        int 21h

    CSEG ends 
end Start 
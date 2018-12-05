CSEG segment
assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG
org 80h        
    cmdLength db ?    
    cmdLine db ?
org 100h

start: 
jmp initialization 
 
int21hProc proc 
    cmp ah,9              
    je keyPressed
        jmp dword ptr cs:[int21hVect]
    keyPressed:
        push dx
        push di
        push si
        push es
        push ds
        pop es
        mov isActive, 1
        mov di, dx
        mov si, dx
        lineHandler:
            lodsb
            cmp al, '$'
            je finish
            cmp al, 'a'
            jl upperCase
            cmp al, 'z'
            jg skip
            sub al, 20h
            jmp skip
            upperCase:
                cmp al, 'A'
                jl skip
                cmp al, 'Z'
                jg skip
                add al, 20h
            skip:
                stosb
                jmp lineHandler
        finish:
        pushf                 
        call dword ptr cs:[int21hVect] 
        pop es
        pop si
        pop di
        pop dx                
    iret                      
int21hProc endp 
  
int40hProc proc 
    cmp ah, 2
    je case40
    jmp dword ptr cs:[int40hVect] 
    case40: 
        mov al, 1
        iret   
int40hProc endp

int40hEmpty proc
    iret
int40hEmpty endp
 
    isActive db 0
    int21hVect dd ?
    int40hVect dd ?
    isInstalled db 'pROGRAMM IS ALREADY INSTALLED', 13, 10, '$'
    errorMessage db 'iNPUT ERROR!', 13, 10, '$'
    notInstalled db 'Programm is not installed', 13, 10, '$'
    deleted db 'Uninstalled',13, 10, '$'
    installed db 'iNSTALLED',13, 10
              db 'tHIS PROGRAMM CHANGE THE CASE OF TYPED LETTERS', 13, 10, '$'            
                   
initialization: 
    cmp byte ptr cmdLength, 0
    je nullArg
    cmp byte ptr cmdLength, 3
    jne inputError
    cmp byte ptr cmdLine[1],'-'
    jne inputError
    cmp byte ptr cmdLine[2],'u'
    jne inputError
    
    uninstall:
        xor al, al
        mov ah, 2
        int 40h
        cmp al, 0
        jne restore
        lea dx, notInstalled
        jmp exit
        
        restore:
            mov ax,3540h 
            int 21h 
            mov word ptr int40hVect,bx
            mov word ptr int40hVect+2,es 
            
            mov ax, 2540h
            lea dx, int40hEmpty
            int 21h
            
            mov ax,3521h 
            int 21h 
            mov word ptr int21hVect, bx
            mov word ptr int21hVect+2, es 
        
            mov ax,2521h 
            lea dx, int21hProc
            int 21h
            lea dx, deleted
            mov ah, 9
            int 21h
        
            lea dx, initialization 
            int 27h 
    nullArg:
        xor al, al
        mov ah, 2
        int 40h
        cmp al, 0
        je installation
        lea dx, isInstalled
        jmp exit
        
    inputError:
        lea dx, errorMessage
        jmp exit
    
    installation:
        mov ax,3521h  
        int 21h 
        mov word ptr int21hVect, bx
        mov word ptr int21hVect + 2, es 
        
        mov ax,3540h 
        int 21h 
        mov word ptr int40hVect, bx
        mov word ptr int40hVect + 2, es 
        
        mov ax, 2521h 
        lea dx, int21hProc    
        int 21h
        
        mov ax, 2540h  
        lea dx, int40hProc    
        int 21h 
        
        xor ax, ax
        mov ah, 9
        lea dx, installed
        int 21h
        
        lea dx, initialization 
        int 27h 
    
    exit:
        mov ah, 9
        int 21h
        mov ax, 4c00h
        int 21h
    CSEG ends 
end start
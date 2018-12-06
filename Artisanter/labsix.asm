.model tiny
.code
org 2Ch 
    enviroment dw ?
org 80h
    cmdLen  db ?
    cmdLine db ?
org 100h

start: 
jmp init
 
    int9hVect dd ?
    handlerId dw 2103h
    
int9hProc proc 
    push ax
    
    xor ax, ax
    in al, 60h
    cmp al, 2   
    jb standartHandler
    cmp al, 11
    ja standartHandler

    mov al, 20h  
    out 20h, al  ;сброс контроллера прерывания
    pop ax
    iret
    standartHandler:
        pop ax
        pushf                 
        call dword ptr cs:[int9hVect]              
        iret                      
int9hProc endp 
    
init:   
    mov ax, 3509h
    int 21h
    mov word ptr int9hVect, bx
    mov word ptr int9hVect + 2, es
    
    cmp byte ptr cmdLen, 0 
    jz tryInstall
    cmp byte ptr cmdLen, 3
    ja invalidArgs
    cmp byte ptr cmdLine[1], '-'
    jnz invalidArgs
    cmp byte ptr cmdLine[2], 'd'
    jnz invalidArgs
    
    cmp es:handlerId, 2103h
    je unistall
    lea dx, notInstalledMsg
    jmp exit
    
    unistall: 
        mov handlerId, 0ABBAh
        push ds
        mov ax, 2509h
        mov dx, word ptr es:int9hVect
        mov ds, word ptr es:int9hVect+2
        int 21h
        
        pop ds
        lea dx, uninstalledMsg
        jmp exit
        
    tryInstall:
        cmp es:handlerId, 2103h
        jne install
        lea dx, isInstalledMsg
        jmp exit
    
    install:
        mov handlerId, 2103h
        mov ax, 2509h
        mov dx, offset int9hProc
        int 21h
        
        mov ah, 49h
        mov es, enviroment
        int 21h
        
        lea dx, installedMsg
        mov ah, 09h
        int 21h
        mov dx, offset init
        int 27h 
        
    invalidArgs:
        lea dx, invalidArgsMsg
    exit:
        mov ah, 9h
        int 21h
        mov ax, 4c00h
        int 21h     
    
    isInstalledMsg  db 'Handler is already installed', 13, 10, '$'
    notInstalledMsg db 'Handler is not installed', 13, 10, '$'
    uninstalledMsg  db 'Handler has been uninstalled',13, 10, '$'
    installedMsg    db 'Handler is installed',13, 10, '$'  
    invalidArgsMsg  db 'Invalid arguments', 13, 10, '$'
    
end start
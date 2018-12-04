CSEG segment ; начало сегмента
assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG 
org 80h            ; по смещению 80h от начала PSP находятся:
    cmdLength db ?       ; длина командной строки
    cmdLine db ?       ; и сама командная строка
org 100h  ; т.к. 100Н байтов под управляющими структурами
Start: 
jmp Init 
 
Int_21h_proc proc 
    cmp ah,9              
    je Our 
        jmp dword ptr cs:[Int_21h_vect] ; если не 9 прерывание, запускаем обычный обработчик
    Our: 
        push dx 
        push di
        push si
        push es
        push ds
        pop es
        mov IsActive, 1
        mov	di, dx
        mov si, dx
        Loopy:
            lodsb
            cmp al, '$'
            je Finish
            cmp al, 'a'
            jl Check
            cmp	al, 'z'
            jg Ignore
            sub	al, 20h
            jmp Ignore
            Check:
                cmp al, 'A'
                jl Ignore
                cmp	al, 'Z'
                jg Ignore
                add	al, 20h
            Ignore:
                stosb
                jmp Loopy
        Finish:
        pushf                 
        call dword ptr cs:[Int_21h_vect] 
        pop es
        pop si
        pop di
        pop dx                
    iret                      
int_21h_proc endp 
  
Int_40h_proc proc 
    cmp ah, 2
    je Our40
    jmp dword ptr cs:[Int_40h_vect] 
    Our40: 
        mov al, 1
        iret   
Int_40h_proc endp

Int_40h_empty proc
    iret
Int_40h_empty endp

IsActive db 0
Int_21h_vect dd ?
Int_40h_vect dd ?
ISInstalled db 'Has been already installed', 13, 10, '$'
iSError db 'error', 13, 10, '$'
NotInstalled db 'Has not been already installed', 13, 10, '$'
Deleted db 'Deleted',13, 10, '$'
Installed db 'Installed',13, 10, '$'

 Init: 
    cmp byte ptr cmdLength, 0
    je ZeroArgs
    cmp byte ptr cmdLength, 3
    jne Error
    cmp byte ptr cmdLine[1],'-'
    jne Error
    cmp byte ptr cmdLine[2],'d'
    jne Error
    
    Deleting:
        xor al, al
        mov ah, 2
        int 40h
        cmp al, 0
        jne ReturnOld
        lea dx, NotInstalled
        jmp Exit
		
         ReturnOld:
            mov ah,35h 
            mov al,40h 
            int 21h 
            mov word ptr Int_40h_vect,bx
            mov word ptr Int_40h_vect+2,es 
			
            mov ax, 2540h
            lea dx, Int_40h_empty
            int 21h
            
            mov ah,35h 
            mov al,21h 
            int 21h 
            mov word ptr Int_21h_vect, bx
            mov word ptr Int_21h_vect+2, es 
        
            mov ax,2521h 
            lea dx, Int_21h_proc
            int 21h
            lea dx, Deleted
            mov ah, 9
            int 21h
        
            lea dx, Init 
            int 27h 
     ZeroArgs:
        xor al, al
        mov ah, 2
        int 40h
        cmp al, 0
        je Install
        lea dx, ISInstalled
        jmp Exit
		
     Error:
        lea dx, iSError
        jmp Exit
    
    Install:
        mov ah,35h ; вектор обработчика прерывания
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
        lea dx, Int_40h_proc    
        int 21h 
        
		xor ax,ax
        mov ah, 9
        lea dx, Installed
        int 21h
        
        lea dx, Init 
        int 27h 
    
    Exit:
        mov ah, 9
        int 21h
        mov ax, 4c00h
        int 21h
     CSEG ends 
end Start  
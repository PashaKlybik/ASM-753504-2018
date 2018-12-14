CSEG segment           ; начало сегмента

assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG 

org 80h                ; по смещению 80h от начала PSP находятся:
    cmdLength db ?     ; длина командной строки
    cmdLine db ?       ; командная строка
org 100h               ; 100Н байтов под управляющими структурами

Start: 
jmp Init 
 
Int_21h_proc proc      ;Обработка прерывания
    cmp ah,9              
    je Next 
    jmp dword ptr cs:[Int_21h_vect] ; если не 9 прерывание, запускаем обычный обработчик
	
  Next: 
    push di
    push si
    push dx 
    push es
    push ds                          ; Передача значения ds в es при помощи стека
    pop es
    mov Active,1
    mov	di,dx
    mov si,dx
	xor ax,ax
  Loopy:
    lodsb            ;Запись в ax байта
    cmp al,'$'
    je Finish
    cmp al,'a' 
    jl Check
    cmp	al,'z'
    jg Skip
    sub	al,20h
    jmp Skip
  Check:
    cmp al,'A'
    jl Skip
    cmp	al,'Z'
    jg Skip
    add	al,20h
  Skip:
    stosb
    jmp Loopy
  Finish:
    pushf                 
    call dword ptr cs:[Int_21h_vect] 
    pop es
    pop dx 
    pop si
    pop di	
iret                      
int_21h_proc endp 
  
Int_40h_proc proc                   
    cmp ah, 2
    je If40
    jmp dword ptr cs:[Int_40h_vect] 
  If40: 
    mov al, 1
iret   
Int_40h_proc endp

Int_40h_empty proc
iret
Int_40h_empty endp

Active db 0
Int_21h_vect dd ?
Int_40h_vect dd ?
InstalledStr db 'Already installed!', 13, 10, '$'
NotInstalled db 'Not installed!', 13, 10, '$'
ErrorStr db 'ERROR!', 13, 10, '$'
DeletedStr db 'DELETED!',13, 10, '$'
InstalledStr db 'INSTALLED!',13, 10, '$'

Init:                            ;Процедура установки прерывания
    cmp byte ptr cmdLength, 0    ;Проверка аргументов командной строки
    jz Zero
    cmp byte ptr cmdLength, 3
    jnz ErrorProc
    cmp byte ptr cmdLine[1],'-'
    jnz ErrorProc
    cmp byte ptr cmdLine[2],'d'
    jnz ErrorProc
    
  Deleting:
    xor ax,ax
    mov ah,2
    int 40h
    cmp al, 0
    jne Standard
    lea dx,NotInstalled          ;Если прерывание небыло установлено до этого 
    jmp Exit
		
  Standard:
    mov ah,35h 
    mov al,40h 
    int 21h 
    mov word ptr Int_40h_vect,bx
    mov word ptr Int_40h_vect + 2,es 
			
    mov ax,2540h
    lea dx,Int_40h_empty
    int 21h
    mov ah,35h 
    mov al,21h 
    int 21h 
    mov word ptr Int_21h_vect,bx
    mov word ptr Int_21h_vect + 2,es 
        
    mov ax,2521h 
    lea dx,Int_21h_proc
    int 21h
    lea dx,DeletedStr
    mov ah,9
    int 21h
        
    lea dx,Init 
    int 27h 
  Zero:
    xor ax,ax
    mov ah,2
    int 40h
    cmp al,0
    je Install
    lea dx,InstalledStr
    jmp Exit
		
  ErrorProc:
    lea dx, ErrorStr
    jmp Exit
    
  Install:
    mov ah,35h ; вектор обработчика прерывания
    mov al,21h 
    int 21h 
    mov word ptr Int_21h_vect,bx
    mov word ptr Int_21h_vect + 2,es 
    
    mov ah,35h 
    mov al,40h 
    int 21h 
    mov word ptr Int_40h_vect,bx
    mov word ptr Int_40h_vect + 2,es 

    mov ax,2521h 
    lea dx,Int_21h_proc    
    int 21h 

    mov ax,2540h  
    lea dx,Int_40h_proc    
    int 21h 
    
    xor ax,ax
    mov ah,9
    lea dx,InstalledStr
    int 21h
	
    lea dx,Init 
    int 27h 
    
  Exit:
    mov ah,9
    int 21h
    mov ax,4c00h
    int 21h
  CSEG ends
  
end Start  
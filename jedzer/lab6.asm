; Лабораторная работа 6
; Необходимо перекрыть указанный в задании обработчик прерывания и заставить его выполнять нужные действия. 
; В большинстве случаев необходим вызов предыдущего обработчика. 
; Также должна быть отдельная небольшая программа, демонстрирующая работу перекрытого обработчика. 
; Программа должна состоять из резидентной части и инсталяционной части. 
; Первая из них отвечает за работу с перекрываемым прерыванием. 
; А инсталяционная часть должна вызываться при старте программы и отвечать за установку обработчиков.
; Инсталяционная часть должна уметь прочитать командную строку:
;     а) если нам не передается параметров:
;         - если обработчик уже установлен: выдать сообщение об этом и выйти из программы
;         - если обработчик еще не установлен: сохранить адрес старого обработчика, установить наш обработчик, 
;           выйти из программы, оставив активной резидентную часть.
;     б) если нам передается параметр "-d":
;         - если обработчик уже установлен: поставить вместо нашего обработчика заглушку и выйти
;         - если обработчик еще не установлен: выдать сообщение об ошибке и выйти
;     в) любой другой параметр: сообщение об ошибке и выход

; В простейшем случае проверку на активность нашей программы можно реализовать при помощи флага. 
; Для более высокой оценки необходимо использовать мультиплексорное прерывание.


; 2) Перекрыть девятую функцию прерывания 21h таким образом, чтобы в выводимой строке маленькие буквы заменялись большими, 
; а большие на маленькие.

CSEG segment 
assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG 
org 80h            ; по смещению 80h от начала PSP находятся:
    cmdLength db ?       ; длина командной строки
    cmdLine db ?       ; и сама командная строка
org 100h 
Start: 
jmp Init 
 
Int_21h_proc proc 
    cmp ah,9              
    je Ok_09 
        jmp dword ptr cs:[Int_21h_vect] 
    Ok_09: 
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
            jl Next
            cmp	al, 'z'
            jg Ignore
            sub	al, 20h
            jmp Ignore
            Next:
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
    je Ok_02
    jmp dword ptr cs:[Int_40h_vect] 
    Ok_02: 
        mov al, 1
        iret   
int_40h_proc endp

int_40h_empty proc
    iret
int_40h_empty endp


IsActive db 0
Int_21h_vect dd ?
Int_40h_vect dd ?
msgAlreadyInstalled db 'ERROR: Already installed',0Dh,0Ah,'$'
msgCmdArgsErr db 'ERROR: Command line arguments are invalid',0Dh,0Ah,'$'
msgNotInstalled db 'ERROR: Not installed',0Dh,0Ah,'$'
msgUninstalled db 'SUCCESS: Uninstalled',0Dh,0Ah,'$'
msgInstalled db 'SUCCESS: Installed',0Dh,0Ah,'$'

Init: 
    cmp byte ptr cmdLength, 0
    je ZeroArgs
    cmp byte ptr cmdLength, 3
    jne CmdError
    cmp byte ptr cmdLine[1],'-'
    jne CmdError
    cmp byte ptr cmdLine[2],'d'
    jne CmdError
    
    IsSlashD:
        xor al, al
        mov ah, 2
        int 40h
        cmp al, 0
        jne ReturnPrev
        lea dx, msgNotInstalled
        jmp MessageAndExit

        ReturnPrev:
            mov ah,35h 
            mov al,40h 
            int 21h 

            mov word ptr Int_40h_vect,bx
            mov word ptr Int_40h_vect+2,es 

            mov ax, 2540h
            lea dx, int_40h_empty
            int 21h
            
            mov ah,35h 
            mov al,21h 
            int 21h 

            mov word ptr Int_21h_vect, bx
            mov word ptr Int_21h_vect+2, es 
        
            mov ax,2521h 
            lea dx, Int_21h_proc
            int 21h

            lea dx, msgUninstalled
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
        lea dx, msgAlreadyInstalled
        jmp MessageAndExit

    CmdError:
        lea dx, msgCmdArgsErr
        jmp MessageAndExit
    
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
        lea dx, msgInstalled
        int 21h
        
        lea dx, Init 
        int 27h 
    
    MessageAndExit:
        mov ah, 9
        int 21h
        mov ax, 4c00h
        int 21h

    CSEG ends 
end Start 
.model tiny
.code
org 2Ch 
envSeg dw ? ; сегментный адресс окружения DOS

org 80h     ; параметры командной строки
cmdLen db ?
cmdLine db ?

org 100h    ; COM file

start:

jmp init ; инициализация резидента

installFlag dw 0AAAAh
int09hVector dd ?

int09hHandler proc far
    push ax
    xor ax, ax

    in al, 60h ; получаем скан-код символа

    cmp al, 02h  
    jb oldHandler
    cmp al, 0BH
    ja oldHandler
    
    mov al, 2Eh
    jmp exit

oldHandler:
    pop ax
    jmp dword ptr cs:[int09hVector] 

exit:
    xor ax,ax
    mov al, 20h
    out 20h, al 
    pop ax  
    iret
int09hHandler endp

init proc near
    mov ax, 3509h   ; получаем адрес обработчика 09h
    int 21h
    mov word ptr int09hVector, bx ; и сохраняем его
    mov word ptr int09hVector + 2, es

    cmp byte ptr cmdLen, 0 ; резидент хотят установить
    jz toInstall
    cmp byte ptr cmdLen, 3
    ja invalidParams

    cmp byte ptr cmdLine[0], ' '
    jnz invalidParams
    cmp byte ptr cmdLine[1], '-'
    jnz invalidParams
    cmp byte ptr cmdLine[2], 'd' ; резидент хотят удалить
    jnz invalidParams

    cmp es:installFlag, 0AAAAh
    jnz notInstalled

    lea dx, succUninstalledMsg
    mov ah, 09h
    int 21h
    mov ax, 2509h
    mov ds, word ptr es:int09hVector+2
    mov dx, word ptr es:int09hVector
    int 21h
    mov ax, 4c00h
    int 21h

invalidParams:
    lea dx, invalidParamsMsg
    jmp msgExit

alreadyInstalled:
    lea dx, alreadyInstalledMsg
    jmp msgExit

notInstalled:
    lea dx, notInstalledMsg
    
msgExit:
    mov ah, 09h
    int 21h
    mov ax, 4c00h
    int 21h

toInstall:
    cmp es:installFlag, 0AAAAh
    jz alreadyInstalled

    mov ax, 2509h  ; устанавливаем резидентную часть
    mov dx, offset int09hHandler ; DS:DX - адресс нашего обработчика
    int 21h

    mov ah, 49h ; освобождаем память из-под окружения DOS
    mov es, word ptr envSeg
    int 21h

    lea dx, succInstalledMsg
    mov ah, 09h
    int 21h
    mov dx, offset init  ; выгружаем init
    int 27h ; завершаем выполнение, оставшись резидентом

invalidParamsMsg    db 'Invalid parametres', 13, 10, '$'
alreadyInstalledMsg db 'Already running', 13, 10, '$'
notInstalledMsg     db 'Error, there is no resident', 13, 10, '$'
succInstalledMsg    db 'Successfully installed', 13, 10, '$'
succUninstalledMsg  db 'Successfully uninstalled', 13, 10, '$'

init endp

end start
.model tiny
.code
org 100h
Begin:
jmp Modification

Resident proc
	in al,60h
	cmp al,3Bh				
	jne IsF2
	mov ah,5
	mov cx,'H'
	int 16h
	mov ah,5
	mov cx,'e'
	int 16h
	mov ah,5
	mov cx,'l'
	int 16h
	mov ah,5
	mov cx,'p'
	jmp Finish
IsF2:
	in al,60h
	cmp al,3Ch
	jne IsF3
	mov ah,5
	mov cx,'S'
	int 16h
	mov ah,5
	mov cx,'a'
	int 16h
	mov ah,5
	mov cx,'v'
	int 16h
	mov ah,5
	mov cx,'e'
	jmp Finish
IsF3:
	in al,60h
	cmp al,3Dh
	jne IsF4
	mov ah,5
	mov cx,'O'
	int 16h
	mov ah,5
	mov cx,'p'
	int 16h
	mov ah,5
	mov cx,'e'
	int 16h
	mov ah,5
	mov cx,'n'
	jmp Finish
IsF4:
	in al,60h
	cmp al,3Eh
	jne IsF5
	mov ah,5
	mov cx,'E'
	int 16h
	mov ah,5
	mov cx,'d'
	int 16h
	mov ah,5
	mov cx,'i'
	int 16h
	mov ah,5
	mov cx,'t'
	jmp Finish
IsF5:
	in al,60h
	cmp al,3Fh
	jne ToOldInt09h
	mov ah,5
	mov cx,'C'
	int 16h
	mov ah,5
	mov cx,'o'
	int 16h
	mov ah,5
	mov cx,'p'
	int 16h
	mov ah,5
	mov cx,'y'
	jmp Finish
Finish:
	jmp dword ptr cs : int09hVect
ToOldInt09h :
	jmp dword ptr cs : int09hVect

	int09hVect dd ?
Resident endp

Modification:
	mov ax,3509h
	int 21h   
	mov word ptr int09hVect,bx
	mov word ptr int09hVect+2,es
	mov ax,2509h
	mov dx,offset Resident
	int 21h
	mov dx,offset Modification
	int 27h
	
end Begin
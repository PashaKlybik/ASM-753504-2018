.model tiny
.code
org 100h
main:
jmp Modification

Resident proc
	in al,60h
	cmp al,1Eh				
	jne IsE
	mov al,30h
	jmp Finish
IsE:
	in al,60h
	cmp al,12h
	jne IsI
	mov al,21h
	jmp Finish
IsI:
	in al,60h
	cmp al,17h
	jne IsO
	mov al,24h
	jmp Finish
IsO:
	in al,60h
	cmp al,18h
	jne IsU
	mov al,19h
	jmp Finish
IsU:
	in al,60h
	cmp al,16h
	jne IsY
	mov al,2Fh
	jmp Finish
IsY:
	in al,60h
	cmp al,15h
	jne ToOldInt09h
	mov al,2Ch
	jmp Finish
Finish:
	jmp dword ptr cs : int15hVect
ToOldInt09h :
	jmp dword ptr cs : int15hVect

	int15hVect dd ?
Resident endp

Modification:
	mov ax,3515h
	int 21h   
	mov word ptr int15hVect,bx
	mov word ptr int15hVect+2,es
	mov ax,2515h
	mov dx,offset Resident
	int 21h
	mov dx,offset Modification
	int 27h
	
end main

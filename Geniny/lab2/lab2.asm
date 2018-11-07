.model small
.stack 256
.data
	errorMessage db 'Error!$'
	endLine      db 13, 10, '$'
	firstBufStr  db '     $'
	secondBufStr db '     $'
	divChar      db '/$'
	equalityChar      db '=$'
.code
	main:
    mov ax, @data
    mov ds, ax
	
	call MainProc

	
	end_metka:
	
	mov ax, 4c00h
	int 21h
	
	
	block_error:
	mov di, offset error_str
	call print_str
	call print_endline
	jmp end_metka
	

	MainProc:

		call input__word
		
		jc block_error      
		
		call word_to_str
		mov di, offset buffer2
		call print_str
		call print_endline
		
		mov di, offset str_div
		call print_str
		call print_endline
		
		mov bx,ax
		
		mov di, offset buffer1
		call clear
		mov di, offset buffer2
		call clear
		xor di,di	
		call input__word
		
		jc block_error 

		call word_to_str
		mov di, offset buffer2
		call print_str
		call print_endline
		
		xor dx,dx
		xchg ax,bx 
		div bx 
		
		mov di, offset str_rovno
		call print_str
		call print_endline
		
		mov di, offset buffer1
		call clear
		mov di, offset buffer2
		call clear
		
		call word_to_str
		mov di, offset buffer2
		call print_str
		call print_endline
	
    ret
	
	BufClear:
	
		push cx
		mov cx,6 
		
		clearing:                
			mov [di],' '        
			inc di              
		loop clearing
			
		pop cx
		
	ret	


end main

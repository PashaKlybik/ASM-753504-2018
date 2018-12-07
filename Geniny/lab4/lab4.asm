.model small
.stack 256
.data
    
  endlSymbol db 13,10,'$'
  firstStr db 39,40 dup('$')
  secondStr db 20 dup('$')
  strLength dw ?
		
.code

PrintStr proc

  push ax

  mov ah,9 
  int 21h
  xor dx,dx
  
  pop ax
	
  ret
PrintStr endp

EnterStr proc

  push ax
  push dx
  
  xor ax,ax
  xor dx,dx
  mov ah,0Ah
  lea dx,firstStr
  int 21h
  xor ax,ax
  mov al,[firstStr+1]           
  mov strLength,ax   
  
  pop dx
  pop ax
  
  ret
EnterStr endp

  assume ds:@data,es:@data
main:

  mov ax,@data
  mov ds,ax 
  mov es,ax 
  call EnterStr
  xor ax,ax
  lea dx, endlSymbol
  call PrintStr

  cld 
  lea di,secondStr
  lea si,firstStr
  add si,2
  lods firstStr
  stos secondStr
  dec di
  dec si
  xor ax,ax
  mov cx,strLength
	
  comparing:
    cmps secondStr,firstStr
      jcxz toExit
      je equalSymbol
      jne notEqualSymbol
	  
      equalSymbol:
        dec cx
        dec di 
      jmp comparing
	
      notEqualSymbol:
        dec cx
        xor ax,ax
        dec si
        lods firstStr
        xor ah,ah
        stos secondStr
        dec di
      jmp comparing
      
  toExit:
    lea dx,secondStr
    call PrintStr
    lea dx,endlSymbol
    call PrintStr
    mov ax,4c00h
    int 21h
		
end main

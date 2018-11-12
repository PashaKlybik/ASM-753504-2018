.model small 
.stack 100h 

.data
a DW 1
b DW 8
c DW 11
d DW 4

.code

Begin:
mov ax,@data
mov ds, ax 

mov ax,a
mov bx,b
mov cx,c
mov dx,d

cmp bx,ax
JGE IfBmore

cmp cx,ax
JGE IfCmore

cmp dx,ax
JGE IfDmore
jmp EXIT

IfBmore:
cmp cx,bx
JGE IfCmore
cmp dx,bx
JGE IfDmore
mov ax,b
jmp EXIT

IfCmore:
cmp dx,cx
JGE IfDmore
mov ax,c
jmp EXIT

IfDmore:
mov ax,d

EXIT:
mov ax,4C00h
int 21h
end Begin
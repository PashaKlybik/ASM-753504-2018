mov es, ax 
mov ax,a
mov si,a
mov bx,b
cmp ax,bx
ja ifakicker
mov ax,bx
jmp gotoc
ifakicker:cmp si,bx
ja comparemin
mov si,si
comparemin:mov si,bx
gotoc:
mov cx,c
cmp ax,cx
ja ifkicker
mov ax,cx
ifkicker: mov ax,ax
cmp cx,si
ja ifminrest
mov si,cx
jmp gotod
ifminrest:mov si,si
gotod:
mov dx,d
cmp ax,dx
ja ifamax
mov ax,dx
jmp gotosplit
ifamax: mov ax,ax
cmp si,dx
ja ifdxmin
mov si,si
jmp split
ifdxmin: mov si,dx
split:
gotosplit:
sub ax,si
mov ax,4c00h 
int 21h
end main

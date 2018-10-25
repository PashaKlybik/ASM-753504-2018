model small
.stack 100h      
.code  
    x1     db     1  
    x2     db     3
    x3     db     2
    x4     db     4
start:
    mov    al,x1
    cmp    al,x2
    jg    skip1; jg - ">"
    mov    al,x2
skip1:
    cmp    al,x3
    jg    skip2
    mov    al,x3
skip2:
    cmp    al,x4
    jg    skip3
    mov    al,x4 
skip3:
    mov    ax,4c00h
    int    21h
    end start
.model small
.stack 256
.data
nullbuffer      db      0Ah, 0Dh, '$'
inputedbuffer     DB      255, 0, 256 DUP (0);
.code

assume  ds:@data,es:@data

main PROC
        mov     ax,@data        ;data segment
        mov     ds,ax
        mov     es,ax

        mov     dx,offset inputedbuffer   ;input
        mov     ah,0Ah
        int     21h
        xor     cx,cx
        mov     al,[inputedbuffer+1]      ;if zero bytes readed -> making number cycle
        mov     cl,al           ;string length - > count
        test    al,al
        jz      Exit

        mov     ah,09h
        mov     dx,offset nullbuffer    ; next string

        int     21h

        mov     si,offset inputedbuffer+2

        mov dh,0Dh              ;number you don't input (comparely)

                Cycle:
                mov     dl,[si]         ;get symbol
                cmp     dl,' '          ;compare
                jne     Print           ;if not - > output
                cmp dx,'  '             ;if before
                je Looping             ;don't print

                Print:
                mov     ah,02h
                int     21h

                Looping:
                mov dh,dl               ;save symbol for test 38
                inc     si              ;next symbol
                loop    Cycle

                Exit:
                cmps nullbuffer, inputedbuffer ; just in case
                mov     AX,4C00h        ;out
                int     21h             ;of the programm

main    ENDP

END main

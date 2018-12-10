.model tiny
;CSEG segment
;assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG   
;.stack 256

.code
org 100h
TsrStart:

    JMP main

    OldHandler21            dw 2 dup(?)
    OldHandler2F            dw 2 dup(?)
    VowelMap                db "AaEeIiOoUu",0
    MapSize                 equ ($-VowelMap)-1   ; $ adress of current line after 0

DirtyPoem PROC
    CLD                                         ; DirectionFlag = 0 => incrementing Si
    MOV     Si, Dx                              ; address of source string
StringChecking:
    LODSB                                       ; loading one bite in Al
    CMP     Al, '$'
    JE      EndOfString

    MOV     Di, offset VowelMap                 ; string to be compared with
    MOV     Cx, MapSize                         ; in Cx is length of source String
    REPNE SCASB                                 ; register Al for scannning
    JE      StringChecking                      ; if the symbol is in vowelMap 

    MOV     Dl, Al                              ;printing a symbol
    MOV     Ah, 02h
    PUSHF 
    CALL    DWORD PTR Cs:[OldHandler21]           ;calling old handler 21h interrupt
    JMP     StringChecking

EndOfString:
    RET
ENDP 
;my handler
DosInterruptHandler PROC
    CMP     Ah, 09h
    JNE     toOldHandler21

    PUSHF
    PUSH    Ax
    PUSH    Ds
    PUSH    Es
    PUSH    Dx

    MOV     Ax, Cs                              ;refference to our segment with code and data
    MOV     Es, Ax

    PUSH    Si
    PUSH    Di 
    PUSH    Cx

    CALL    DirtyPoem
    
    POP     Cx
    POP     Di
    POP     Si

    POP     Dx
    POP     Es
    POP     Ds
    POP     Ax
    POPF
    IRET

toOldHandler21:
    JMP     DWORD PTR Cs:[OldHandler21]
ENDP 

MultiplexInterruptHandler PROC
    CMP     Ax, 0BF00h
    JNE     toOldHandler2F

    MOV     Al, 0FFh                              ;refference to our segment with code and data
    IRET

toOldHandler2F:
    JMP     DWORD PTR Cs:[OldHandler2F]
ENDP    

InitPart:
SharespereSonet         db "When, in disgrace with fortune and men's eyes",0dh,0Ah
                            db    "I all alone beweep my outcast state",0dh,0Ah
                            db    "And trouble deaf heaven with my bootless cries",0dh,0Ah
                            db    "And look upon myself and curse my fate,",0dh,0Ah
                            db    "Wishing me like to one more rich in hope,",0dh,0Ah
                            db    "Featured like him, like him with friends possess'd,",0dh,0Ah
                            db    "Desiring this man's art and that man's scope,",0dh,0Ah
                            db    "With what I most enjoy contented least;",0dh,0Ah, '$'
    SharespereSonetContinue db "Yet in these thoughts myself almost despising,",0dh,0Ah
                            db    "Haply I think on thee, and then my state,",0dh,0Ah
                            db    "Like to the lark at break of day arising",0dh,0Ah
                            db    "From sullen earth, sings hymns at heaven's gate;",0dh,0Ah
                            db    "For thy sweet love remember'd such wealth brings",0dh,0Ah
                            db    "That then I scorn to change my state with kings.",0dh,0Ah,'$'
    
main:
    MOV     Ax, Cs
    MOV     Ds, Ax
    MOV     Es, Ax

;test call of 09h function of 21h interruption
    LEA     Dx, SharespereSonet
    MOV     Ah, 09h
    INT     21h
    LEA     Dx, SharespereSonetContinue
    MOV     Ah, 09h
    INT     21h
;------------------------------------
    MOV Ax, 0BF00h
    INT 2Fh
    CMP Al, 0FFh                                 ; returning code: ff- installed,
                                                                 ;00h not installed, able to install, 
                                                                 ;01h not installed, disabled
    JE endProg

;saving Old Handler2f 
    MOV     Ax,352Fh                            ; АН = 35h, AL = number of interrupt
    INT     21h                                 ; DOS function: get address of interrupt handler
                                                   
    MOV     Cs:OldHandler2F, Bx                   ; returns offset of old Handler in Bx  
                                                                       
    MOV     Cs: OldHandler2F+2, Es                ; returns segment address in ES

; Setting our handler
    PUSH    Ds                                  ;saving address of our data segment
    MOV     Ax, 252Fh                           ; АН = 25h, AL = number of interrupt
    MOV     Dx, Cs                              ; address of new handler's segment
    MOV     Ds, Dx                              ; in DS
    MOV     Dx, offset MultiplexInterruptHandler      ; offset in DX
    INT     21h                                 ; DOS function: set new interrupt handler
    POP     Ds
;------------------------------------
;saving Old Handler21 
    MOV     Ax,3521h                            ; АН = 35h, AL = number of interrupt
    INT     21h                                 ; DOS function: get address of interrupt handler
                                                   
    MOV     Cs:OldHandler21, Bx                   ; returns offset of old Handler in Bx  
                                                                       
    MOV     Cs:OldHandler21+2, Es                ; returns segment address in ES

; Setting our handler
    PUSH    Ds                                  ;saving address of our data segment
    MOV     Ax, 2521h                           ; АН = 25h, AL = number of interrupt
    MOV     Dx, Cs                              ; address of new handler's segment
    MOV     Ds, Dx                              ; in DS
    MOV     Dx, offset DosInterruptHandler      ; offset in DX
    INT     21h                                 ; DOS function: set new interrupt handler
    POP     Ds                                                
;------------------------------------

;leaving program in memory as resident
    LEA Dx, InitPart
    INT 27h
;restore old handler
   ; LDS     dx,  DWORD PTR Cs:OldHandler21        ; segment addres in DS and offset in DX
    ;MOV     ax,2521h                            ; АН = 25h, AL = interrupt number
    ;INT     21h                                 ; DOS function: set new interrupt handler

;------------------------------------   
endProg:
    MOV     ax, 4c00h
    INT     21h
;CSEG ends

end TsrStart

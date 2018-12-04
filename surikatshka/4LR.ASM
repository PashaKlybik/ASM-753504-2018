.model small
.stack 256
.data

    ;const
MaxStringLength         equ     60 
    ;help lines and strings
    
    newLine             db 0Dh,0Ah,'$' ;'\n'
    helpLineEnterString db 'Enter a sting of symbols (or enter for zero):','$'
    
    maxLength           db MaxStringLength + 1
    realLength          db 0
    sourceString        db MaxStringLength dup(' '),0        
    resultString        db MaxStringLength dup(' '),'$'
    counts              db 256 dup(0)           ;array for repeating symbols, where index of arr is a code of symbol 
    repeatSymbolsArray  db MaxStringLength dup (0)    

    helpLineDivider     db 'The result (coloured symbols are the repeating ones):', '$' 
    FailHelpLine        db 'No Repeating Symbols found.',0ah,0dh,'$'
 
   
.code
printHelpLine PROC                              ;print of help lines or \n
        PUSH    Ax
        MOV     Ah, 09h
        INT     21h
        POP     Ax
        RET
ENDP

initialSearchRepeatings PROC
        PUSH    Bx
        PUSH    Cx
        PUSH    Dx
        PUSH    Si
        PUSH    Di

        XOR     Dx, Dx
        XOR     Cx, Cx
        MOV     Cl, realLength
        XOR     Si, Si
        XOR     Bx, Bx

@@searchRepeatingLoop:    
        MOV     Bl, [sourceString + Si]
        MOV     Di, Bx
        INC     [counts + Di]
        INC     Si
        CMP     [counts + Di], 2
        JNE      @@goNext
        MOV     Di, Dx                          ;at first time = 0
        MOV     [repeatSymbolsArray + Di], Bl
        INC     Dx                              ;we found repeating symbol

@@goNext:        
        LOOP    @@searchRepeatingLoop
        MOV     Ax, Dx                          ;amount of repeated symbols

        POP     Di
        POP     Si
        POP     Dx
        POP     Cx
        POP     Bx
        RET
ENDP

replaceRepeatingSymbols PROC
        PUSH    Bx
        PUSH    Cx
        PUSH    Dx
        PUSH    Si
        PUSH    Di

        XOR     Si, Si
        MOV     Dx, Ax
        XOR     Ax, Ax

@@replacingRepeating:
        MOV     Al, [repeatSymbolsArray + Si]
        LEA     Di, sourceString
        XOR     Cx, Cx
        MOV     Cl, realLength          ;in Cx is length of sourceString
        INC     Cl
        MOV     Bx, 0                   ;counter of found repetings inside the @@handleSymbolCycle 
        CLD 

@@handleSymbolCycle:
        REPNE SCASB   
        JCXZ    @@nextSymbol            ; if we reached the end of string
        CMP     Bx, 0
        JZ      @@SaveFirstS
        MOV     [Di - 1], Ah            ;Now, to find out the place where the element in the line matched,
                                        ;We need to decrement the value in the register Di 
                                        ;Ah contains byte 0
@@SaveFirstS:        
        INC     Bx
        JMP     @@handleSymbolCycle

@@nextSymbol:
        DEC     Dx
        INC     Si
        CMP     Dx, 0
        JNZ     @@replacingRepeating

        LEA     Si, sourceString        ;copy of not replaced symbols
        LEA     Di, resultString
        MOV     Dl, realLength
        MOV     Cl, realLength
        MOV     Al, 0

@@copySymbolCycle:
        REPNE MOVSB 
        JCXZ    @@finish
        DEC     Di 
        DEC     Dx                      ;decrement of result string to avoid coping repeating symbols
        JMP     @@copySymbolCycle

@@finish:
        MOV     [Di], '$'               ;adding the end of line for MS DOS call 

        POP     Di
        POP     Si
        POP     Dx
        POP     Cx
        POP     Bx
        RET
ENDP


main:
        MOV     Ax, @data
        MOV     Ds, Ax
        MOV     Es, Ax
;------------------------------------
        LEA     Dx, maxLength
        MOV     Ah, 0Ah
        INT     21h


        LEA     Dx, newLine
        CALL    printHelpLine

        CALL    initialSearchRepeatings
        CMP     Ax, 0
        JNZ     @@goReplaceRepeatingSymbols
        LEA     Dx, FailHelpLine
        CALL    printHelpLine
        JMP     @@exit

@@goReplaceRepeatingSymbols:
        CALL    replaceRepeatingSymbols
        LEA     Dx, resultString
        CALL    printHelpLine
        LEA     Dx, newLine
        CALL    printHelpLine

;------------------------------------   
@@exit:  
        MOV     Ax, 4c00h
        INT     21h
end main
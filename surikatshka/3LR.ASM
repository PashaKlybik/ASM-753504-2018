    .model small
.stack 256
.data
 
    ;help lines 
    
    newLine             db 0Dh,0Ah,'$' ;'\n'
    helpLineDividend    db 'Enter Divident(or enter for zero):','$'
    helpLineDivider     db 'Enter Divider(exept zero(enter)):','$' 
    helpLineQuotient    db 'The qoutient = ','$'
    helpLineReminder    db 'The reminder = ','$'
    helpLineZDivision   db 'Cannot be divided by 0.','$'
    helpLineBadDivision db 'Low bound (-32768) cannot be divided by (-1). ','$'

    ten                 dw 10  ;constant value 
   
.code
PrintHelpLine PROC             ;print of help lines or \n
    PUSH    Ax
    MOV     Ah,09h
    INT     21h
    POP     Ax
    RET
ENDP

IntegerInput PROC              ;enter of integer 
    PUSH    Bx
    PUSH    Cx
    PUSH    Dx
    PUSH    Si
    PUSH    Di

    XOR     Bx, Bx
    XOR     Si, Si
    XOR     Cx, Cx
    XOR     Di, Di

inputCycle:
    MOV     Ah, 07h            ;function which reads character without echo
    INT     21h
    
    
    CMP     Al, '-'            ;code of minus 2dh
    JNZ     numberNotNeg
    CMP     Si, 0    
    JNZ     inputCycle
    MOV     Si, 1
    CMP     Di, 0              ; minus cannot be entered if digits were entered. Appropriate check of Di register
    JNZ     inputCycle
    MOV     Dl, '-'
    MOV     Ah, 02h
    INT     21h 
    JMP     inputCycle

numberNotNeg:     
    CMP     Al, 0Dh            ;code of  enter
    JZ      @@exit
    CMP     AL, 30h            ;chek of lower bound
    JC      inputCycle
    CMP     Al, 3ah            ;check of upper bound
    JNC     inputCycle
    CMP     Bx, 3277
    JGE     inputCycle         ;great or equal (signed)
    
    INC     Di                 ;flag of numbers entered amount if Di==0 minus can be entered 
    SUB     Al, 30h            ;susbsctraction of zero code
    MOV     Cl, Al
    MOV     Ax, Bx
    MUL     ten
    CMP     Dx, 0              ;check on overflow
    JNZ     inputCycle
    ADD     Ax, Cx
    CMP     Si, 1
    JZ      lBorder
    TEST    Ax, 8000h          ;high bit
    JNZ     inputCycle
    JMP     saveAndOutput

lBorder:                       ;check of negative overflow
    CMP     Ax, 8001h

    JAE     inputCycle         ;greater or equal (unsigned)

saveAndOutput:
    MOV     Bx, Ax             ;save of intermediate number
    MOV     Dl, Cl
    ADD     Dl, 30h
    MOV     Ah, 02h
    INT     21h
    JMP     inputCycle

@@exit:
    MOV     Ax, Bx   
    CMP     Si, 1
    JNZ     restoreRegisters
    NEG     Ax

restoreRegisters:    
    POP     Di
    POP     Si
    POP     Dx
    POP     Cx
    POP     Bx
    RET
IntegerInput ENDP

integerOutput PROC ;output of integer numbers
    PUSH    Dx
    PUSH    Cx
    XOR     Cx, Cx

    TEST    Ax, 8000h    ;check of negative number
    JZ      @@cycleDiv

    PUSH    Ax
    MOV     Dx, '-'    ;output of minus symbol
    MOV     Ah, 02h
    INT     21h
    POP     Ax
    NEG     Ax

@@cycleDiv:
    MOV     Dx, 0
    DIV     ten
    PUSH    Dx
    INC     Cx
    CMP     ax,0
    JZ      outputCycle
    JMP     @@cycleDiv

outputCycle:
    POP     Dx
    ADD     Dx, '0'
    MOV     Ah, 02h
    INT     21h
    LOOP    outputCycle

    POP     Cx
    POP     Dx
    RET
integerOutput ENDP

main:
    MOV     ax, @data
    MOV     ds, ax
;------------------------------------
    XOR     Ax, Ax 
    LEA     DX, helpLineDividend
    CALL    PrintHelpLine
    CALL    IntegerInput
    MOV     Bx, Ax

    LEA     Dx, newLine
    CALL    PrintHelpLine

enterDivAgain:
    LEA     Dx, helpLineDivider ;adress of string for printing it in helpLine procedure
    CALL    PrintHelpLine
    CALL    IntegerInput
    MOV     Cx, Ax
    TEST    Bx, Bx             ;check on negative divident
    JNS     ZCheck

    TEST    Cx, Cx             ;check on negative divident
    JNS     ZCheck


    CMP     Cx, -1
    JNE     ZCheck
    CMP     Bx, -32768
    JNE     ZCheck
    LEA     Dx, newLine
    CALL    PrintHelpLine      ;\n
    LEA     Dx, helpLineBadDivision
    CALL    PrintHelpLine
    XOR     Ax, Ax
    XOR     Cx, Cx
    JMP     enterDivAgain
ZCheck:                        ;check on dividing by zero any kind of number
    CMP     Cx, 0
    JNZ     division

    LEA     Dx, newLine
    CALL    PrintHelpLine      ;\n
    LEA     Dx, helpLineZDivision
    CALL    PrintHelpLine
    XOR     Ax, Ax
    XOR     Cx, Cx
    JMP     enterDivAgain

division:
    MOV     Ax, Bx
    CWD                        ;copy highest bit of Ax register in Dx register
    TEST    Dx, 8000h          ;if divident is positive
    JZ      dividePositive
    IDIV    Cx    
    TEST    Ax, 8000h
    JZ      positiveQuotient    
    DEC     Ax                 ;if quotient (ax) negative
    ADD     Dx, Cx
    PUSH    Dx
    JMP     outputResult
    
positiveQuotient:              ;if quotient (ax) positive
    INC     Ax
    SUB     Dx, Cx
    PUSH    Dx
    JMP     outputResult
    
dividePositive:
    IDIV    Cx                 ;if divident is positive
    PUSH    Dx

outputResult:
    LEA     Dx, newLine
    CALL    PrintHelpLine

    LEA     Dx, helpLineQuotient
    CALL    PrintHelpLine
    CALL    integerOutput

    LEA     Dx, newLine
    CALL    PrintHelpLine

    LEA     Dx, helpLineReminder
    CALL    PrintHelpLine
    POP     Ax
    CALL    integerOutput

    LEA     Dx, newLine
    CALL    PrintHelpLine
;------------------------------------   
   
    MOV     ax, 4c00h
    INT     21h
end main

    .model small
.stack 256
.data
    minInt              EQU -32768
    maxInt              EQU 32767
    ;help lines 
    ten                 dw 10           ;constant value 
    
    rowsHelpLine        db "Rows: ",'$'
    columnsHelpLine     db "Columns: ",'$'
    matrixHelpLine      db "Matrix: ",0dh,0Ah,'$'
    overflowHelpLine    db "matrix will be overflowed.",'$'
    newLine             db 0Dh,0Ah,'$' ;'\n'
    inputFile           db "input.txt",0
    inputFileHandle     dw ?
    ioBuffer            db ?
    outputFile          db "output.txt",0
    outputFileHandle    dw ?
    r                   dw ?            ; rows
    c                   dw ?            ;columns
    minimumOfRowsCols   dw ?            ;minimum value of rows and coloms for distinguishing by secondary diaonal
    matrix              dw 10001 dup(0)
    Max                 dw minInt
    Min                 dw maxInt
    Subtraction         dw 0

   
.code

;print of help lines or \n
PrintHelpLine PROC                      
    PUSH    Ax
    MOV     Ah,09h
    INT     21h
    POP     Ax
    RET
ENDP


;Opens a file with matrix
OpenInputFile PROC
    PUSH    Ax
    PUSH    Dx

    MOV     Ah, 3dh                     ;3dh - function to open file of 21h interrupt
    MOV     Al, 0                       ;0 - to open file for reads
    LEA     Dx, inputFile
    INT     21h
    JC      exitOpenProc
    MOV     inputFileHandle, AX
exitOpenProc:

    POP     Dx
    POP     Ax
    RET
ENDP

CloseInputFile PROC
    PUSH    Ax
    PUSH    Bx
    MOV     AH, 3eh
    MOV     Bx,inputFileHandle
    INT     21h     

    POP     Bx
    POP     Ax
    RET
ENDP

;function which reads one symbol from file 
ReadSymbolFromFile PROC 
    PUSH    Bx
    PUSH    Cx
    PUSH    Dx

    MOV     Ah, 3fh
    MOV     Bx, inputFileHandle
    MOV     Cx, 1                       ;read one symbol from file
    LEA     Dx, ioBuffer                ;symbol is read to buffer  
    INT     21h

    JC      exitReadProc                ;CF set on error, AX = error code (05h,06h)
    CMP     Ax, 0                       ;Ax = 0 when file ends

    JZ      setEoF
    MOV     Al, ioBuffer                ;symbol which is read from file
    JMP     exitReadProc
    
setEoF:
    MOV     Ah,1                        ;set Ah = 1 when EoF 
    
exitReadProc:
    POP     Dx
    POP     Cx
    POP     Bx
    RET
ENDP


CreateOutputFile PROC
    PUSH    Ax
    PUSH    Cx
    PUSH    Dx

    MOV     Ah, 3ch                     ;3ch - function to create file of 21h interrupt
    MOV     Cx, 40h                     ;2^5 = 40h - archive bit set - atribute of file 
    LEA     Dx, outputFile
    INT     21h
    JC      exitCreateProc
    MOV     outputFileHandle, Ax

exitCreateProc:
    POP     Dx
    POP     Cx 
    POP     Ax
    RET
ENDP

CloseOutputFile PROC
    PUSH    Ax
    PUSH    Bx
    MOV     AH, 3eh
    MOV     Bx,outputFileHandle
    INT     21h     

    POP     Bx
    POP     Ax

    RET
ENDP

;function which writs one symbol to file 
WriteSymbolToFile PROC

    PUSH    Bx 
    PUSH    Cx
    PUSH    Dx

    MOV     AH, 40h
    MOV     Bx, outputFileHandle        ; bx - file descriptor
    MOV     Cx, 1                       ; write one symbol to file
    MOV     ioBuffer, Dl                ; symbol for writing is saved to buffer 
    LEA     Dx, ioBuffer
    INT     21h

    JC      exitWriteProc
    CMP     Ax, 0
    JZ      exitWriteProc

exitWriteProc:
    POP     Dx
    POP     Cx
    POP     Bx
    RET
ENDP

WriteNewLine PROC
    MOV     Dx, 0Dh
    CALL    WriteSymbolToFile
    MOV    Dx, 0Ah
    CALL    WriteSymbolToFile
    RET
ENDP

;funtion reads integer from file and prints it
ReadAndPrintIntegerFromFile PROC        
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
    CALL    ReadSymbolFromFile
    CMP     Ah,1                        ;check for an EoF
    JE      restoreRegisters   
    
    CMP     Al, '-'                     ;code of minus 2dh
    JNZ     numberNotNeg
    CMP     Si, 0    
    JNZ     inputCycle
    MOV     Si, 1
    CMP     Di, 0                       ; minus cannot be entered if digits were entered. Appropriate check of Di register
    JNZ     inputCycle
    MOV     Dl, '-'
    MOV     Ah, 02h
    INT     21h 
    JMP     inputCycle

numberNotNeg:     
    CMP     Al, 0Dh                     ;code of  enter 
    JZ      @@Print0AAndExit
    CMP     Al, 09h                     ; code of tabulation
    JZ      @@printAndExit
   
    CMP     AL, 30h                     ;chek of lower bound
    JC      inputCycle
    CMP     Al, 3ah                     ;check of upper bound
    
    JNC     inputCycle

    CMP     Bx, 3277
    JGE     inputCycle                  ;great or equal (signed)
    
    INC     Di                          ;flag of numbers entered amount if Di==0 minus can be entered 
    SUB     Al, 30h                     ;susbsctraction of zero code
    MOV     Cl, Al
    MOV     Ax, Bx
    MUL     ten
    CMP     Dx, 0                       ;check on overflow
    JNZ     inputCycle
    ADD     Ax, Cx
    CMP     Si, 1
    JZ      lBorder
    TEST    Ax, 8000h                   ;high bit
    JNZ     inputCycle
    JMP     saveAndOutput

lBorder:                                ;check of negative overflow
    CMP     Ax, 8001h
    JAE     inputCycle                  ;greater or equal (unsigned)

saveAndOutput:
    MOV     Bx, Ax                      ;save of intermediate number
    MOV     Dl, Cl
    ADD     Dl, 30h
    MOV     Ah, 02h
    INT     21h
    JMP     inputCycle
@@Print0AAndExit:                       ;printing tabulation or ODh 0Ah
    MOV     Dl, Al
    MOV     Ah, 02h
    INT     21h
    MOV     Dl, 0Ah
    MOV     Ah, 02h
    INT     21h
    JMP     @@saveAndExit


@@printAndExit:                         
    MOV     Dl, Al
    MOV     Ah, 02h
    INT     21h
@@saveAndExit:
    MOV     Ax, Bx   
    AND     Si, 1
    JZ     restoreRegisters
    NEG     Ax
    CLC
restoreRegisters:    
    POP     Di
    POP     Si
    POP     Dx
    POP     Cx
    POP     Bx
    RET
ReadAndPrintIntegerFromFile ENDP

;function for writing integer to file
WriteIntegerToFile PROC                 ;output of integer numbers
    PUSH    Dx
    PUSH    Cx
    XOR     Cx, Cx

    TEST    Ax, 8000h                   ;check of negative number
    JZ      @@cycleDiv1

    PUSH    Ax
    MOV     Dx, '-'                     ;output of minus symbol
    CALL    WriteSymbolToFile
    POP     Ax
    NEG     Ax

@@cycleDiv1:
    MOV     Dx, 0
    DIV     ten
    PUSH    Dx
    INC     Cx
    CMP     ax,0
    JZ      outputCycle1
    JMP     @@cycleDiv1

outputCycle1:
    POP     Dx
    ADD     Dx, '0'
    CALL     WriteSymbolToFile
    LOOP    outputCycle1

    POP     Cx
    POP     Dx
    RET
WriteIntegerToFile ENDP

;procedure for reading and printing array from file 
ReadAndPrintArray PROC 
    PUSH    Si
    PUSH    Di
    PUSH    Cx
    XOR     Di, Di
    XOR     Cx,Cx

rowCycle:            ;rows cycles
    XOR     Si, Si
columnCycle:       ;columns cycles
    

    CALL    ReadAndPrintIntegerFromFile
    JC      avoidSave                   ;check on EoF or error while reading from file
    MOV     matrix[Di], Ax
avoidSave:                              
    
    JC      Break
    ADD     Di, 2
    INC     Si
    CMP     Si, c
    JL     columnCycle
    INC     Cx
    CMP     Cx, r 
    JL     rowCycle   
Break:
    POP     Cx
    POP     Di
    POP     Si
    RET
ReadAndPrintArray endp

;output of integer numbers
PrintInteger PROC             
    PUSH    Dx
    PUSH    Cx
    XOR     Cx, Cx

    TEST    Ax, 8000h                   ;check of negative number
    JZ      @@cycleDiv

    PUSH    Ax
    MOV     Dx, '-'                     ;output of minus symbol
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
PrintInteger ENDP

FindResult PROC
    
    PUSH    Ax
    PUSH    Bx
    PUSH    Si
    PUSH    Di
    PUSH    Cx
    PUSH    Dx
    XOR     Di, Di
    XOR     Cx,Cx
    
    MOV     Ax, r                                        
    MOV     Bx, c
    
    CMP     Ax, Bx
    JNG     MinRows                     ; if (r > c)                   
    MOV     minimumOfRowsCols,Bx        ;minimumOfRowsCols = c;
MinRows:
    MOV     minimumOfRowsCols, Ax       ; else minimumOfRowsCols = r;

@@rowCycle:                             ;rows cycles
    XOR     Si, Si

@@columnCycle:                          ;columns cycles
    MOV     Dx , matrix[Di]             ;value for compare
    
    MOV     Bx, minimumOfRowsCols                
    CMP     Cx, Bx                      ;if (i < minimumOfRowsCols  
    JGE     FindMinimum                   
    MOV     Bx, c
    SUB     Bx,Cx                                   
    CMP     Si, Bx                      ;&& j < (c - i))
    JGE     FindMinimum   
                       
    CMP     Dx ,Max                        ;if (matrix[i][j] > max)
    JNG     ContinueCycle                                        
    MOV     Max,Dx                          ;max = matrix[i][j]
    JMP     ContinueCycle

FindMinimum:                            ;else
    CMP     Dx, Min                        ;if (matrix[i][j] < min)
    JGE     ContinueCycle
    MOV     Min, Dx                         ;min = matrix[i][j]
                                     
ContinueCycle:                          
    ADD     Di,2
    INC     Si
    CMP     Si, c
    JL      @@columnCycle
    
    INC     Cx
    CMP     Cx, r 
    JL      @@rowCycle 

    MOV     Ax, Max
    MOV     Bx, Min
    SUB     Ax, Bx
    MOV     Subtraction, Ax  

    POP     Dx
    POP     Cx
    POP     Di
    POP     Si
    POP     Bx
    POP     Ax
    RET
FindResult ENDP

PrintAndWriteResult PROC
    LEA     Dx, newLine
    CALL    PrintHelpLine
    MOV     Ax,Max
    CALL    WriteIntegerToFile
    CALL    WriteNewLine
    MOV     Ax,Max
    CALL    PrintInteger

    LEA     Dx, newLine
    CALL    PrintHelpLine
    MOV     Ax,Min
    CALL    WriteIntegerToFile
    CALL    WriteNewLine
    MOV     Ax,Min
    CALL    PrintInteger

    LEA     Dx, newLine
    CALL    PrintHelpLine
    MOV     Ax, Subtraction
    CALL    WriteIntegerToFile
    CALL    WriteNewLine
    MOV     Ax,Subtraction
    CALL    PrintInteger

    LEA     Dx, newLine
    CALL    PrintHelpLine
    RET
ENDP

main:
    MOV     ax, @data
    MOV     ds, ax
;------------------------------------
    CALL    OpenInputFile
    JC      endProg
    CALL    CreateOutputFile
    JC      endProg
    
    LEA     Dx, rowsHelpLine
    CALL    PrintHelpLine
    CALL    ReadAndPrintIntegerFromFile
    CMP     Ax, 100
    JG      printOverFlow
    MOV     r, Ax

    LEA     Dx, columnsHelpLine
    CALL    PrintHelpLine
    CALL    ReadAndPrintIntegerFromFile 
    CMP     Ax, 100
    JG      printOverFlow
    MOV     c, Ax

    LEA     Dx, matrixHelpLine
    CALL    PrintHelpLine
    CALL    ReadAndPrintArray 

    CALL    FindResult

    CALL    PrintAndWriteResult

    CALL    CloseInputFile
    JC      endProg
    CALL    CloseOutputFile
    JMP     endProg   
;------------------------------------
    
printOverFlow:
    LEA     Dx, newLine
    CALL    PrintHelpLine
    LEA     Dx, overflowHelpLine
    CALL    PrintHelpLine
    JMP     endProg

    LEA     Dx, newLine
    CALL    PrintHelpLine


    LEA     Dx, newLine
    CALL    PrintHelpLine
;------------------------------------   
endProg:
    MOV     ax, 4c00h
    INT     21h
end main

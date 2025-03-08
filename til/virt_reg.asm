        ORG 100H

START   LXI     H, CODEENT
        SHLD    RSP
        LXI     B, BP 
        LHLD    RSP 
        MOV     C, M 
        INX     H 
        MOV     B, M 
; save HL to virtual register RSP
        SHLD    RSP

; test register save/restore.
        LXI H, 5050H
        LXI D, 0F800H
        LXI B, 0900AH
; save
        CALL    EXX1 
; mess up
        LXI	H, 0
        LXI	D, 0
        LXI	B, 0
;restore
        CALL    EXX2

        RST     07H

EXX1          
; save
	    SHLD 	TEMPHL
	    MOV     H, D 
        MOV   	L, E 
        SHLD    TEMPDE 
        MOV	H, B 
        MOV 	L, C 
        SHLD 	TEMPBC
        RET


; restore
EXX2
        LHLD	TEMPBC 
        MOV	B, H
        MOV	C, L
        LHLD	TEMPDE 
        MOV	D, H
        MOV	E, L
        LHLD	TEMPHL
        RET

; scaffold - exit to DDT ?
        RST     07H

RSTMSG  DB      'The Significant Owl Hoots in the Moonlight', 0AH, 0DH

CODEENT NOP     ; Some code entry point.
        NOP
        
othercode       NOP
        NOP
        
        


RSP     DW  0
BP      DW  0

; save registers
TEMPHL DW  0
TEMPDE DW  0
TEMPBC DW  0


        END

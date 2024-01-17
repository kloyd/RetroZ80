; Trying some I/O with the Z80 MC

PUT_CHAR        EQU     13E8h
SET_IO  EQU     1382h
        ORG     8000h   ; RAM Start
        CALL    SET_IO  ; Set I/O system
        CALL    CRLF    ; Issue CR and LF.

        LD      HL, MESG
OUTS    LD      A,(HL)
        JR      Z,DONE
        CALL    PUT_CHAR
        INC     HL
        JR      OUTS
DONE    CALL    CRLF

LOOP    JP     LOOP            ; forever

MESG    DB 'Hello, world!',0

CRLF    PUSH AF
        LD A,0Ah
        CALL PUT_CHAR
        LD A,0Dh
        CALL PUT_CHAR
        POP AF
        RET

        END

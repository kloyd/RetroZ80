;; Console I/O test for TIL design.

; Input Restrictions
BUFFER_SIZE EQU 255

;; Handy Constants
CR	EQU     0DH
LF	EQU     0AH
DOLLAR  EQU     24H
ESC     EQU     1BH
CTRLC   EQU     03H

; Screen print calls
CHAR_IN EQU     03H
C_STAT  EQU     0BH
C_RAWIO EQU     06H


WRITESTR        EQU     9H
PRTCHR  EQU     02H
BDOS    EQU     05H 

;       CP/M User program space starts at Page 1.
        ORG     100h 

MAIN:
        LD      DE, GREET
        CALL PUTS
        CALL _CRLF
        LD      DE, PROMPT
        CALL PUTS

READLINE:
        CALL INPUT
        JR READLINE

;; Test scaffold for _KEY and _ECHO
INPUT:
        CALL _KEY

        CP CTRLC
        JP Z, EXIT

        CP CR
        JP Z, EXIT

        LD D, A
        LD E, A
        CALL _ECHO
        RET

EXIT    CALL _CRLF
        LD      DE, EXITSTR
        CALL    PUTS
        CALL _CRLF
        ; CP/M Warm Boot
        JP 0h

; Print a string
PUTS:
;;; Question, should we PUSH C and POP C here?
        LD C, WRITESTR
        CALL BDOS
        RET

;****
;*   Internal Routines interfacing with Operating System.
;* _ECHO - Echo a character to terminal
;* _KEY - Read a key from terminal
;* _CRLF - Output CR/LF to terminal
;****
; Print a character
_ECHO:
        PUSH BC 
        LD C, PRTCHR
        CALL BDOS
        POP BC
        RET

; Get a key (Used by TIL)
_KEY:
; Preserve BC and DE.
        PUSH BC
        PUSH DE
WAITKEY LD C, C_RAWIO
        LD DE,FFFFh
        CALL    BDOS
        OR A 
        JR Z, WAITKEY
        POP DE
        POP BC
        RET      

_CRLF:
; Output CR LF to console.
        PUSH DE
        PUSH BC
        LD DE, CRLF
        LD C, WRITESTR
        CALL BDOS
        POP BC
        POP DE
        RET


CRLF: DB CR, LF, DOLLAR

GREET: DB "HELLO, I'M A TIL", DOLLAR
PROMPT: DB "> ", DOLLAR
EXITSTR: DB CR, LF, "BYE!", DOLLAR

;; Buffer at end of memory.
BUFFER: DS BUFFER_SIZE



        ; Need 0000 for asmx to generate correct Intel HEX.
        END 0000
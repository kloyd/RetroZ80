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
CHAR_IN EQU     01H
WRITESTR        EQU     9H
PRTCHR  EQU     02H
BDOS    EQU     05H 

;       CP/M User program space starts at Page 1.
        ORG     100h 

MAIN:
        LD      DE, GREET
        CALL PUTS
        LD      DE, PROMPT
        CALL PUTS

READING:
        CALL INPUT
        JP READING

INPUT:
        LD C, CHAR_IN
        ;LD DE,0
        CALL BDOS
        ;OR A
        ;JR Z,INPUT
	
        CP 03H
        JP Z, EXIT

        CP 0DH
        JP Z, EXIT

        LD D, A
        LD E, A
        CALL PUTC
        RET

EXIT    LD      DE, EXITSTR
        CALL    PUTS
        ; CP/M Warm Boot
        JP 0h

; Print a string
PUTS:
;;; Question, should we PUSH C and POP C here?
        LD C, WRITESTR
        CALL BDOS
        RET

; Print a character
PUTC:
  LD C, PRTCHR
  CALL BDOS
  RET


GREET: DB "HELLO, I'M A TIL", CR, LF, DOLLAR
PROMPT: DB "> ", DOLLAR
EXITSTR: DB CR, LF, "K, Thx, Bye!", CR, LF, DOLLAR

;; Buffer at end of memory.
BUFFER: DS BUFFER_SIZE



        ; Need 0000 for asmx to generate correct Intel HEX.
        END 0000
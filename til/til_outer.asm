; *****  TIL
; Outer Interpreter
; Author Kelly Loyd
; Target System
;   Z80 CP/M 64K RAM 
; ***

; Non Standard Z80 MC
STD_CPM	EQU 0

;---------- Put in CP/M Transient Memory space.
	ORG	100h

;---------- START/RESTART
START	LD	DE,RSTMSG
	LD	A,(BASE)
	AND	A
	JR	NZ, ABORT
	LD	A,10
	LD	(BASE),A
	LD	DE,SRTMSG
ABORT	LD	SP,STACK
	PUSH	DE
	LD	HL,0
	LD	(MODE),HL
	LD	IY,NEXT
	LD	IX,RETURN
	LD	HL,8080h
	LD	(LBEND),HL
	LD	BC,OUTER	; Effectively, Set OUTER as the next routine
	JP	NEXT		; Call NEXT in the Inner Interpreter, which will load address of OUTER and Jump to it.

; Entry point of OUTER interpreter.
OUTER	DW	TYPE 
	DW	INLINE
	DW	ASPACE
	DW	TOKEN
	DW	TILHALT 
	DW 	QSEARCH	; Leaves something on the stack if found or not found?
	DW	@IF

; --------- Inner Interpreter
SEMI	DW	$ + 2
	LD	C,(IX+0)
	INC	IX
	LD	B,(IX+0)
	INC	IX
NEXT	LD	A,(BC)	; BC = Instruction Register
	LD	L,A	; @I -> WA (HL = word address)
	INC	BC
	LD	A,(BC)
	LD	H,A
	INC	BC	; I = I + 2
RUN	LD	E,(HL)	; @WA -> CA (Code Address)
	INC	HL	; WA = WA + 2
	LD	D,(HL)
	INC	HL
	EX	DE,HL	; CA -> PC 
	JP	(HL)

COLON	DEC	IX
	LD	(IX+0),B
	DEC	IX
	LD	(IX+0),C
	LD	C,E
	LD	B,D
	JP	(IY)
;----------- End of Inner -----

; TYPE - String with length byte (0a1234567890) printed to console.
TYPE	DW	$ + 2
TYPEIT	POP	DE	; get address of string
	PUSH	HL 	; save WA
	PUSH	BC	; Save IR.
	EX	DE,HL
	LD	B,(HL)
	INC	HL
ONECHAR	LD	A,(HL)
	CALL	_ECHO
	INC	HL
	DJNZ	ONECHAR
	POP	BC	; Restore IR
	POP	HL	; Restore WA
	JP	NEXT




; INLINE
INLINE	DW	$ + 2	;header address
	PUSH	BC	; Save IR
ISTART	CALL	_CRLF	; Issue CR / LF on terminal for new input
	LD	HL, LBADD	; Buffer
	LD	(LBP), HL
	LD	B, LENGTH
CLEAR	LD	(HL), SPACE
	INC	HL
	DJNZ	CLEAR
ZERO	LD	L,0
INKEY	CALL	_KEY
	CP	LINEDEL		; CTRL-X is Line Delete
	JR	NZ,TSTBS
	CALL	_ECHO
	JR ISTART
TSTBS	CP	BKSP		; backspace CTRL-H
	JR	NZ, TSTCR
	DEC	HL
	JP	M,ZERO
	LD	(HL), SPACE
ISSUE	CALL	_ECHO
	JR	INKEY
TSTCR	CP	CR
	JR	Z,LAST1
	BIT	7,L
	JR	NZ,IEND
SAVEIT	LD	(HL),A 
	CP	61H	; Less than LC A ?
	JR	C,NOTLC
	CP	7BH	; MORE THAN LC Z?
	JR	NC,NOTLC
	RES	5,(HL)
NOTLC	INC	L 
	JR	ISSUE
IEND	DEC	L 
	LD	C,A 
	LD	A,BKSP 
	CALL	_ECHO 
	LD	A,C 
	JR 	SAVEIT 
LAST1	LD	A, SPACE 
	CALL	_ECHO
	POP	BC 
	JP	(IY)	; Return to NEXT inner interpreter.


ASPACE	DW	$ + 2
	LD	A, 20h
	PUSH	AF
	JP	(IY)	


	DB 5,'TOK'	; TOKEN ID 
	DW	EXECUTE
TOKEN	DW	$ + 2
	EXX 	; Save IR (EXX exchanges BC, DE, and HL with shadow registers with BC', DE', and HL'.)
	LD	HL,(LBP) ; pointer to token 
	LD	DE,(DP) ; pointer to Dictionary 
	POP 	BC	; space left by ASPACE 
	LD	A,20H 	; space code
	CP	C 	; space?
	JR 	NZ, TOK
IGNLB	CP	(HL)
	JR	NZ,TOK
	INC	L 
	JR 	IGNLB
TOK	PUSH	HL
COUNT	INC	B 
	INC 	L
	LD 	A,(HL)
	CP 	C
	JR 	Z,ENDTOK 
	RLA
	JR 	NC,COUNT 
	DEC	L 
ENDTOK	INC	L 
	LD 	(LBP), HL 
	LD	A,B 
	LD	(DE), A 
	INC	DE 
	POP	HL 
	LD 	C,B 
	LD 	B,0 
	LDIR  		; Move token to dictionary 
	EXX 
	JP 	(IY)




QSEARCH

; ABSENT?
; - NO -> ?EXECUTE -> ASPACE
; - YES -> NUMBER

QEXECUTE	DW $ + 2
	NOP
	JP (IY)

QNUMBER		DW $ + 2
	NOP
	JP (IY)

@IF	DW $ + 2
	NOP
	JP (IY)

; For Z80 MC - DDT was changed to use RST 6 since the hardware uses RST 7.
; For Standard CP/M
TILHALT	DW	$ + 2
	IF STD_CPM = 1
	RST	7
	ELSE
	RST 	6
	ENDIF


; INVALID NUMBER?
; NO -> ASPACE
; YES -> QUESTION

; QUESTION
QUESTION	DW	$ + 2
	LD 	HL,(DP)
	INC 	HL
	BIT	7,(HL)	; IF BIT SET, A TERMINATOR
	JR	Z,ERROR	;NOT SET ERROR
	LD	DE,OK
	PUSH	DE
	JP	(IY)
ERROR	CALL	_CRLF
	LD	IY,RETURN
	JP	TYPE
RETURN	LD	DE, QMSG
	JP	_PATCH

; GOTO TYPE


; Internals

QMSG	DB	'?', 0
OK	DB	'OK',0

; PATCH internal routine.
_PATCH	DB	0



; EXECUTE primitive needs a dictionary entry for defining words.
; This is a model for all other Primitive words that will be added to the dictionary
;
	DB	7,'E','X','E'	; Header for dictionary search
	DW	0		; Link address 0000 == End of Linked List.
EXECUTE DW	$ + 2		; Address of EXECUTE.
	POP	HL		; primitive code.
	JP	RUN

;----------------------------------------
; CP/M Machine Specific routines
; 
; *   Internal Routines interfacing with Operating System.
; * _ECHO - Echo a character to terminal
; * _KEY - Read a key from terminal
; * _CRLF - Output CR/LF to terminal
;----------------------------------------
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

; til has own write str using _ECHO
;WRITESTR        EQU     9H
PRTCHR  EQU     02H
BDOS    EQU     05H 

; Output one character.
; A = Input Char.
; preserve BC register.
; preserve HL register.
_ECHO
	PUSH HL
        PUSH BC 
	PUSH DE
	LD D,A 
	LD E,A
        LD C, PRTCHR
        CALL BDOS
        POP DE 
	POP BC
	POP HL
        RET

; Get a key 
_KEY
; Preserve BC, DE, and HL.
	PUSH	BC
	PUSH	DE
	PUSH	HL
WAITKEY LD	C, C_RAWIO
        LD	DE,FFFFh
        CALL    BDOS
        OR 	A 
        JR 	Z,WAITKEY
	POP	HL
        POP	DE
        POP	BC
; Character returned in A register.
        RET      

; Output CR LF to console.
_CRLF
	PUSH AF
	LD A, CR
	CALL _ECHO
	LD A, LF
	CALL _ECHO
	POP AF
        RET

; Constants
;
LINEDEL	EQU	18H	; ctrl-x line delete
SPACE	EQU	20h	; space
BKSP	EQU	08h	; ctrl-H backspace

; Variables
BASE	DB	0	; BASE for restart/warm start
MODE	DB	0	; MODE
LBP	DW	0 	; line buffer pointer
LENGTH	EQU	128	; buffer length
	ORG	400h	; put on page boundary
LBADD	DS	128	; text input buffer
LBEND	DW	0

; Dictonary pointer
DP	DW	0
STACK	EQU	8000h

; Strings
RSTMSG	DB	12, ' TIL RESTART'
SRTMSG	DB	21, ' WELCOME TO RETRO TIL'

; Stack grows down... set this at 8000 for cpm
;	ORG	4000h
;STK	DS	255
;STACK	DB	0





	END	0000

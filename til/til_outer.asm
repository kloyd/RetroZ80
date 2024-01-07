; TIL
; Outer Interpreter

; TIL

; START/RESTART
	ORG	0x8000

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
	LD	HL,8080
	LD	(LBEND),HL
	LD	BC,OUTER	; Effectively, Set OUTER as the next routine
	JP	NEXT		; Call NEXT in the Inner Interpreter, which will load address of OUTER and Jump to it.


; TYPE
OUTER

; INLINE
INLINE	DW	$ + 2	;header address
ISTART	PUSH	BC
	CALL	_CRLF	; Issue CR / LF on terminal for new input
	LD	HL, LBADD	; Buffer
	LD	(LBP), HL
	LD	B, LENGTH
CLEAR	LD	(HL), ASPACE
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
	LD	(HL), ASPACE
ISSUE	CALL	_ECHO
	JR	INKEY
TSTCR	CP	CR


; ASPACE

; TOKEN

; ?SEARCH

; ABSENT?
; - NO -> ?EXECUTE -> ASPACE
; - YES -> NUMBER

; ?EXECUTE

; ?NUMBER

; INVALID NUMBER?
; NO -> ASPACE
; YES -> QUESTION

; QUESTION
QUESTION
	DW	$+2
	LD 	HL,(DP)
	INC 	HL
	BIT	7,(HL)	; IF BIT SET, A TERMINATOR
	JR	Z,ERROR	;NOT SET ERROR
	LD	DE,OK
	PUSH	DE
	JP	(IY)
ERROR	CALL	_CRLF
	LD	IY,RETURN
	JP	_TYPE
RETURN	LD	DE, QMSG
	JP	_PATCH

; GOTO TYPE


; Internals
_TYPE	DB	0
_CRLF	DB	0
QMSG	DB	'?', 0
OK	DB	'OK',0

; PATCH internal routine.
_PATCH	DB	0

; Inner Interpreter

SEMI	DW	$ + 2
	LD	C,(IX+0)
	INC	IX
	LD	B,(IX+0)
	INC	IX
NEXT	LD	A,(BC)
	LD	L,A
	INC	BC
	LD	A,(BC)
	LD	H,A
	INC	BC
RUN	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	EX	DE,HL
	JP	(HL)

COLON	DEC	IX
	LD	(IX+0),B
	DEC	IX
	LD	(IX+0),C
	LD	C,E
	LD	B,D
	JP	(IY)

; EXECUTE primitive needs a dictionary entry for defining words.
; This is a model for all other Primitive words that will be added to the dictionary
;
	DB	7,'E','X','E'	; Header for dictionary search
	DW	0		; Link address 0000 == End of Linked List.
EXECUTE DW	$ + 2		; Address of EXECUTE.
	POP	HL		; primitive code.
	JR	RUN

; ***
; Machine Specific routines
; KEY
;; Very simplistic using Z80 simulator terminal I/o
_KEY	IN	A,(FFH)
	RET

; ECHO
_ECHO	OUT	(FFh), A
	RET



; Constants
;
LINEDEL	EQU	18H	; ctrl-x line delete
ASPACE	EQU	20h	; space
BKSP	EQU	08h	; ctrl-H backspace
CR	EQU	0Dh	; carriage return

; Variables
BASE	DB	0	; BASE for restart/warm start
MODE	DB	0	; MODE
LBP	DW	0 	; line buffer pointer
LENGTH	EQU	128	; buffer length
LBEND	DS	128	; text input buffer
LBADD	DW	0

; Dictonary pointer
DP	DW	0

; Strings
RSTMSG	DB	' TIL RESTART', 0
SRTMSG	DB	' WELCOME TO RETRO TIL',0

; Stack grows down... set this at F000
	ORG	0xF000
;STK	DS	255
STACK	DB	0





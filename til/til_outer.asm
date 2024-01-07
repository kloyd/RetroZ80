; TIL
; Outer Interpreter

; TIL

; START/RESTART
	ORG	$8000

START:	LD	DE,RSTMSG
	LD	A,(BASE)
	AND	A
	JR	NZ, ABORT
	LD	A,10
	LD	(BASE),A
	LD	DE,SRTMSG
ABORT:	LD	SP,STACK
	PUSH	DE
	LD	HL,0
	LD	(MODE),HL
	LD	IY,NEXT
	LD	IX,RETURN
	LD	HL,8080
	LD	(LBEND),HL
	LD	BC,OUTER
	JP	NEXT


; TYPE
OUTER:

; INLINE

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
QUESTION:
	DW	$+2
	LD 	HL,(DP)
	INC 	HL
	BIT	7,(HL)	; IF BIT SET, A TERMINATOR
	JR	Z,ERROR	;NOT SET ERROR
	LD	DE,OK
	PUSH	DE
	JP	(IY)
ERROR:	CALL	_CRLF
	LD	IY,RETURN
	JP	_TYPE
RETURN:	LD	DE,MSG?
	JP	_PATCH

; GOTO TYPE


; Internals
_TYPE:	DB	0
_CRLF	DB	0
MSG?	DB	'?'
	DB	0
OK	DB	'OK',0

_PATCH	DB	0

; Inner Interpreter

SEMI:	DW	$ + 2
	LD	C,(IX+0)
	INC	IX
	LD	B,(IX+0)
	INC	IX
NEXT:	LD	A,(BC)
	LD	L,A
	INC	BC
	LD	A,(BC)
	LD	H,A
	INC	BC
RUN:	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	EX	DE,HL
	JP	(HL)

COLON:	DEC	IX
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
EXECUTE: DW	$ + 2		; Address of EXECUTE.
	POP	HL		; primitive code.
	JR	RUN

; ***

; Variables
BASE	DB	0
MODE	DB	0
LBEND	DS	128

STK	DS	255
STACK	DB	0

DP	DW	0

; Strings
RSTMSG	DB	' TIL Restart'
SRTMSG	DB	' Hello, I'm a Til'



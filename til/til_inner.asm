; Inner interpreter

; Z80 Register usage
; AF - Accumulator
; BC - IR (Instruction Register)
; DE - WA (Word Address Register and Scratch Register)
; HL - Scratch
; IX - Return Stack Pointer
; IY - Address of NEXT
; SP - Data Stack Pointer
; AF' BC' DE' HL' - scratch

; Start of Inner Interpreter (needs Outer as well plus other bits)
; Assuming a ROM at address 0 and RAM at &8000 (32768)
;
	ORG	$8000
SEMI:	DW	*+2
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

; Execute primitive and needs a dictionary entry for defining words.
	DB	7,'E','X','E'	; Header for dictionary search
	DW	0		; Link address 0000 == End of Linked List.
EXECUTE: Dw	*+2		; Address of EXECUTE.
	POP	HL		; primitive code.
	JR	RUN

; End of Inner.






	END

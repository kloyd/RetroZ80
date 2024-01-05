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







	END

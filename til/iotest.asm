        ORG     100h

        LD      DE, 
TYPE	DW	$ + 2
TYPEIT	POP	DE	; get address of string
	PUSH	HL 	; save HL
	EX	DE,HL
	LD	B,(HL)
	INC	HL
ONECHAR	LD	A,(HL)
	CALL	_ECHO
	INC	HL
	DJNZ	ONECHAR
	POP	HL
	JP	NEXT
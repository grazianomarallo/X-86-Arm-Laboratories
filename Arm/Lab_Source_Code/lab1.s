;DEVELOPED BY Graziano Marallo S238159
	AREA RESET, CODE, READONLY
 	ARM

	B Start

Start

	MOV r0,#3				;store into r0-r7 integer values
	MOV r1,#3
	MOV r2,#4
	MOV r3,#6
	MOV r4,#7
	MOV r5,#7
	MOV r6,#2
	MOV r7,#4
	MOV r8,#0				;store into r8-r11 0
	MOV r9,#0
	MOV r10,#0
	MOV r11,#0
	MOV r12,#0		 		;use r12 as temporary variable in order to store in it the sum of the couple of register
					  		;under analysis

	;perform first comparision and decision
	ADD r12,r0,r1	  		 ;store in r12 temporary value for the sum of r1,r0
	CMP r0,r1						 ;if true simply multiply the two operand, otherwhise compute the mean
	MOVNE r8,r12,LSR#1	 ;compute the mean and mov the result into r8
	MULEQ r8,r0,r1			 ;multiply the two value and store result into r8
	MOV r12,#0						;clean temporary r12 before next comparision
	;perform second comparision
	ADD r12,r2,r3			;algorithm is repetead for the next 3 couple till the end of program
	CMP r2,r3
	MOVNE r9,r12,LSR#1
	MULEQ r8,r2,r3
	MOV r12,#0
	;perform third comparision
	ADD r12,r4,r5
	CMP r4,r5
	MOVNE r10,r12,LSR#1
	MULEQ r10,r4,r5
	MOV r12,#0
	;perform last comparison
	ADD r12,r6,r7
	CMP r6,r7
	MOVNE r11,r12,LSR#1
	MULEQ r11,r6,r7
	MOV r12,#0
	B exit
exit

	END

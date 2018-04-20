;DEVELOPED BY Graziano Marallo S238159
	AREA	RESET, CODE, READONLY
	ARM
start
	MOV r0,#9		;initialize r0-r2 with immediate values
	MOV r1,#3
	MOV r2,#6
	MOV r3,#0		;counter for multiplicity
	mov r6,#0		;temporary variable for check multiplicity

skip2					;Sort register by incresing value
	CMP r0,r1
	BLE skip
	EOR r0,r0,r1		  ;swap using xor
	EOR r1,r1,r0
	EOR r0,r0,r1
skip
	CMP r1,r2
	BLE last
	EOR r1,r1,r2
	EOR r2,r2,r1
	EOR r1,r1,r2
	B skip2				 ; last check in order to verify if r2 is the smallest value
last
	CMP r0,r1
	BGT skip2

check_r1
	ADD r6,r6,r0	   	;add each iteration to temp var the value of the smallest value
	ADD r3,r3,#1		;increase counter  for each iteration in order to know how many time r0 is contained in r1
	CMP r6,r1			;iterate till r6 is smaller than r1
	BLT check_r1
	MOV r4,r3			 ;store in r4 the value contained in r3 that is the number of time which r0 is contained in r1
	MOV r3,#0			;clear counter
	MOV r6,#0		   	;clear temporary variable
check_r2
	ADD r6,r6,r0		;same algorithm as check_r1 but performed on r2 and result stored into r5
	ADD r3,r3,#1
	CMP r6,r2
	BLT check_r2
	MOV r5,r3
	B exit

exit
	END                     ; Mark end of file

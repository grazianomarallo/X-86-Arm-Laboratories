;DEVELOPED BY Graziano Marallo S238159
	AREA RESET, CODE, READONLY
 	ARM

	B Start


array DCD 1,2,3,4,5,6,7,8	  ;define literal pool of 8 elements  increasing monotonic
;array DCD 9,7,6,5,4,3,2,1	  ;define literal pool of 8 elements  decresing monotonic
;array DCD 1,2,3,4,5,6,7,8	  ;define literal pool of 8 elements  non monotonic

Start
	LDR r2,=array				;load into r0 the address of array and the first element
	MOV r5,#0				   ;store the maximum absolute difference
	MOV r3,#0				   ;loop counter
	MOV r4,#0
	MOV r11,#0				   	;counter for decresing sequence
	MOV r10,#0					;counter for increasing sequence
	MOV r12,#0					;store the sum of the all values in order to compute the mean at the end
	MOV r8,#0		   			;store the minum value
	MOV r7,#255		  			;store the maximum value

	LDR r0,[r2]		   ;load into r0 the first value store into the array at address of r2
loop

	LDR r1,[r2,#4]	   ;load into r1 the next value
	ADD r2,r2,#4	   ;add 4 to r2 in order to have always the next value stored into the array
	CMP r0,r1		   ;compare the current two value
	BLE increase	   ;if the first one is less or equal to second one means that is an increasing
					   ;sequence so jump to increase label otherwise means go on

absdiff
	CMP r10,#0			 ;check for monotony
	BNE non_monotonic
 	ADD r11,r11,#1		;increment decresing counter
	SUB r4,r0,r1	   ;store into r4 the absolute difference
	CMP r5,r4		   ;if the value stored in r5 is greater jump to goon label
	BGT goon
	MOV r5,r4		   ;otherwise the difference done previously is the maximum one
	B goon

increase
	CMP r11,#0		  	;check for monotony
	BNE non_monotonic
	ADD r10,r10,#1		;increment incresing counter
	ADD r12,r12,r0		;add at each iteration the value to the previous
	B goon

non_monotonic
	ADD r11,r11,#1
	ADD r10,r10,#1
	CMP r0,r7		   ;compare the current value with the smallest one and in case it's true jump
	BLT minimum
	CMP r0,r8		   ;compare the current value with the greatest one and in case it's true jump
	BGT maximum
maximum
	MOV r8,r0		   ;store into r8 the greatest value
	B goon
minimum
	MOV r7,r0		   ;store into r7 the smallest value

goon
	MOV r0,r1		  ;move into current position the n+1 element in order to exploit the loop
	ADD r3,r3,#1	  ;counter for the loop
	CMP r3,#7		  ;loop 7 times
	BLT loop

end
	CMP r12,#0		   ;if r12 is different from zero compute the mean
	BNE	mean
	CMP r8,#0		   ;if r8 is not different from 0 compute the max e min
	BEQ max_min

mean
	ADD r12,r12,r0		;add last number (the loop iterates 7 times so the last value has to be added)
	LSR r12,#3			;compute mean by shifting r10 by 2 ( value of r12 / 8 )

max_min
	CMP r0,r7			 ;same comparision done previously
	BLT min
	CMP r0,r8
	BGT max
max
	MOV r8,r0			;r8 store the maximum  value
	B exit
min
	MOV r7,r0			;r7 store the minimum value

exit

	END                     ; Mark end of file

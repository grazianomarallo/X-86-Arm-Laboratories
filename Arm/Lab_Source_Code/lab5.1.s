;DEVELOPED BY Graziano Marallo S238159

;/*****************************************************************************/
;/* STARTUP.S: Startup file for Philips LPC2000                               */
;/*****************************************************************************/
;/* <<< Use Configuration Wizard in Context Menu >>>                          */
;/*****************************************************************************/
;/* This file is part of the uVision/ARM development tools.                   */
;/* Copyright (c) 2005-2007 Keil Software. All rights reserved.               */
;/* This software may only be used under the terms of a valid, current,       */
;/* end user licence from KEIL for a compatible version of KEIL software      */
;/* development tools. Nothing else gives you the right to use this software. */
;/*****************************************************************************/


; Standard definitions of Mode bits and Interrupt (I & F) flags in PSRs

Mode_USR        EQU     0x10
Mode_FIQ        EQU     0x11
Mode_IRQ        EQU     0x12
Mode_SVC        EQU     0x13
Mode_ABT        EQU     0x17
Mode_UND        EQU     0x1B
Mode_SYS        EQU     0x1F

I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled



;// <h> Stack Configuration (Stack Sizes in Bytes)
;//   <o0> Undefined Mode      <0x0-0xFFFFFFFF:8>
;//   <o1> Supervisor Mode     <0x0-0xFFFFFFFF:8>
;//   <o2> Abort Mode          <0x0-0xFFFFFFFF:8>
;//   <o3> Fast Interrupt Mode <0x0-0xFFFFFFFF:8>
;//   <o4> Interrupt Mode      <0x0-0xFFFFFFFF:8>
;//   <o5> User/System Mode    <0x0-0xFFFFFFFF:8>
;// </h>

UND_Stack_Size  EQU     0x00000080
SVC_Stack_Size  EQU     0x00000080
ABT_Stack_Size  EQU     0x00000000
FIQ_Stack_Size  EQU     0x00000000
IRQ_Stack_Size  EQU     0x00000080
USR_Stack_Size  EQU     0x00000400

ISR_Stack_Size  EQU     (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + \
                         FIQ_Stack_Size + IRQ_Stack_Size)

                AREA    STACK, NOINIT, READWRITE, ALIGN=3

Stack_Mem       SPACE   USR_Stack_Size
__initial_sp    SPACE   ISR_Stack_Size

Stack_Top


;// <h> Heap Configuration
;//   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF>
;// </h>

Heap_Size       EQU     0x00000100

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3

Heap_Mem        SPACE   Heap_Size




                PRESERVE8


; Area Definition and Entry Point
;  Startup Code must be linked first at Address at which it expects to run.

                AREA    RESET, CODE, READONLY
                ARM


; Exception Vectors
;  Mapped to Address 0.
;  Absolute addressing mode must be used.
;  Dummy Handlers are implemented as infinite loops which can be modified.

Vectors         LDR     PC, Reset_Addr			; reset
                LDR     PC, Undef_Addr			; undefined instruction
                LDR     PC, SWI_Addr			; software interrupt
                LDR     PC, PAbt_Addr			; prefetch abort
                LDR     PC, DAbt_Addr			; data abort
                NOP                             ; reserved vector
                LDR     PC, IRQ_Addr			; IRQ
                LDR     PC, FIQ_Addr			; FIQ

Reset_Addr      DCD     Reset_Handler
Undef_Addr      DCD     Undef_Handler
SWI_Addr        DCD     SWI_Handler
PAbt_Addr       DCD     PAbt_Handler
DAbt_Addr       DCD     DAbt_Handler
                DCD     0                      ; Reserved Address
IRQ_Addr        DCD     IRQ_Handler
FIQ_Addr        DCD     FIQ_Handler

Undef_Handler   B       Undef_Handler
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
IRQ_Handler     B       IRQ_Handler
FIQ_Handler     B       FIQ_Handler

;SWI management
SWI_Handler
				STMFD 	sp!, {r0-r11, lr}
				LDR r0, [lr, #-4]
				BIC 	r1, r0, #0xff000000
				; test the identification code of the interrupt
				CMP 	r1, #0x10
				BEQ		positive_ov
				BLT		end_swi
				CMP		r1, #0x20
				BNE 	end_swi
				; your action here
negative_ov
				MOV r12, #0x80000000
				B end_swi
positive_ov
				MOV r12, #0x7FFFFFFF

end_swi
				LDMFD 	sp!, {r0-r11, pc}^


; Reset Handler
Reset_Handler

; Initialise Interrupt System
;  ...


; Setup Stack for each mode

                LDR     R0, =Stack_Top

;  Enter Undefined Instruction Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #UND_Stack_Size

;  Enter Abort Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size

;  Enter FIQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size

;  Enter IRQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size

;  Enter Supervisor Mode and set its Stack Pointer                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size

;  Enter User Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_USR
                MOV     SP, R0
                SUB     SL, SP, #USR_Stack_Size



; main program starts here.
	AREA SORT,DATA,READWRITE
result_pool SPACE 255			;define a space section for the result pool

	AREA RESET, CODE, READONLY
 	ARM
	B Start

;Define two literal pool of N element where N is 4
pool_one 	DCD  0x800000F0, 0x70000000, 0xFFFFFFE0, 0x100EC023
pool_two	DCD  0xF0004538, 0x12345678, 0xE00A1238, 0xE9800348
N DCD 4

Start
	LDR r0, =N				; r0 = number of elements
	LDR r0, [r0]
	LDR r10, =pool_one		; r1 = current element in pool_one
	LDR r2, =pool_two		; r2 = currente element in pool_two
	LDR r3,	=result_pool
	MOV r7,#0		  		;counter

sum_loop
	LDR r4, [r10]	   			;load into r4 current pool_one element
	AND r8, r4, #0x80000000		;load into r8 SIGN of pool_one current element
	LDR r5, [r2]	   			;load into r5 current pool_two element
	AND r9, r5, #0x80000000		;load into r9 SIGN of pool_two current element
	ADD r6,r4,r5		   		;current element in pool_one + current element in pool_two
	CMP r8, r9				   	;if sign or r8 and r9 is different no overflow can happen
	BNE dontcare				;no need to check ov
	AND r8, r6, #0x80000000		;load into r6 SIGN of result
	CMP r8, r9				   	;if sign of result and sign of the operands is different -> OV !!
	BEQ dontcare

; The interrupt service routine with identification code 10h is called
	CMP r8, #0x80000000
	BNE	positiveswi
	SWI #0x10  					; negative SWI
	MOV r6, r12
	B dontcare

positiveswi
	SWI 0x20					; positive overflow
	MOV r6, r12

dontcare
	STR r6, [r3]		   	;save result in result_pool
	ADD r10,r10,#4		 	;move pointer to next element in pool_one
	ADD r2,r2,#4			;move pointer to next element in pool_two
	ADD r3,r3,#4			;move pointer to next element in result_pool
	ADD r7,r7,#1			;increment loop counter
	CMP r7,r0
	BLT sum_loop

	B Reset_Handler

                END

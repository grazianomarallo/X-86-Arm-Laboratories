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

;Undef_Handler   B       Undef_Handler
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
IRQ_Handler     B       IRQ_Handler
FIQ_Handler     B       FIQ_Handler
SWI_Handler		B		SWI_Handler



;Undefined Instruction management
Undef_Handler
				; your action here
				STMFD sp!, {r0-r11, lr}		; registers are saved into the stack, r12 will contain the result of the division
				LDR r0, [lr, #-4]			; check undefined instruction code (ex. DIV code "0x77F005F6")
				AND r1, r0, #0x0ff00000		; r0 holds UI number
				CMP r1, #0x07F00000			; is this a DIV instruction?!
				BNE 	end_undef
				AND r2, r0, #0x0000000f		; r3 holds the number of the register that contains the DIVIDEND
				LDR r3, [sp, r2, LSL #2] 	; the content of the register indicated as DIVIDEND is our DIV is now loaded in R3
											; r2 contains the index of the register (as extracted from the LSB of our DIV) and it is used to access the stack
				AND r4, r0, #0x0000ff00		; r4 holds the DIVISOR (r4=0x00000500)
				LSR r4, r4, #8				; shift to get the right number (r4=0x00000005)
				MOV r12, #0					; r5 will contain the result of the division

subtraction		SUB r3, r3, r4				; dividend -= divisor
				ADD r12, r12, #1
				CMP r3, r4					; dividend >= divisor ? >>> Y loop again || N stop
				BGT subtraction

				;division done, result is into r12

end_undef		LDMFD 	sp!, {r0-r11, pc}^


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

;  Enter Supervisor Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size

;  Enter User Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_USR
                MOV     SP, R0
                SUB     SL, SP, #USR_Stack_Size




; main program starts here.
; The interrupt service routine with identification code 10h is called
				STMFD sp!, {r0-r12, lr}
				MOV r6, #26
DIVr6BY5 DCD 0x77F005F6
				LDMFD sp!, {r0-r12, pc}^
; 0x7   CONDITION FIELD in order to execute DIV always
; 0x7F  OPERATION CODE that identifies DIV
; 0x005 IMMEDIATE DIVISOR, it is an unsigned interger (in this case "5")
; 0xF6  DIVIDEND expressed as F? where ? is the index off a register
				B Reset_Handler
end
                END

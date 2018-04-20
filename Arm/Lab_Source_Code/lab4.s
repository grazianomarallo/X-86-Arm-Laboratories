	AREA SORT,DATA,READWRITE
sort_arr SPACE 255	  	;define a space section for the array to sort

	AREA RESET, CODE, READONLY              
 	ARM
	B Start
;Price List is not sorted
Price_list 	DCD 0x043, 45, 0x035, 9, 0x036, 11, 0x039, 12, 0x03C, 19 
			DCD 0x004, 20, 0x006, 15, 0x007, 10, 0x00A, 5, 0x010, 8 
	   		DCD 0x027, 12, 0x028, 11, 0x02C, 45, 0x02D, 10, 0x031, 40
		    DCD 0x012, 7, 0x016, 22, 0x017, 17, 0x018, 38, 0x01A, 22 
		  	DCD 0x03E, 1, 0x041, 20, 0x042, 30, 0x045, 12, 0x047, 7 
		    DCD 0x01B, 34, 0x01E, 11, 0x022, 3, 0x023, 9, 0x025, 40 
Item_list DCD 0x022, 4, 0x006, 1, 0x03E, 10, 0x017, 2 
num_items DCD 4		  	 ;contains the number of items to check. Change this number if the item_list grows
num_elements DCD 30		 ;number of elements in Price_list

Start
	LDR r0, =num_elements	; r0 = number of elements in Price_list
	LDR r0, [r0]
	LDR r1, =Price_list		; r1 = current element in Price_list
	LDR r3, =sort_arr		; r2 = currente element in sort_arr
	MOV r2, #0				; counter
	MOV r5,#0		  		;temp var
; copy elements into sort_arr to be sorted
	LSL r0,#1
copy_loop
	LDR r4, [r1]	   		;load into r4 the current value in Price_list
	ADD r5,r4
	STR r5, [r3]			;store the current value into current position of sorted_array
	ADD r1,r1,#4			;move the pointer to next cell in memory
	ADD r3,r3,#4			; /////
	MOV r5,#0				;reset temp var
	ADD r2, r2, #1			; increment counter
	CMP r2,	r0			; check counter for the loop
	BLT copy_loop

 ;The following code is just to test if the array has been filled correctly
	;LDR r1,=sort_arr
	;MOV r3,#0
	;mov r4,#60
;show 
;	LDR r2,[r1]
;	ADD r1,r1,#4
;	ADD r3, r3, #1			; increment counter
;	CMP r3,r4				; counter == num_elements?
;	BLT show
	
	MOV r4,#0
	MOV r1,#0
	LDR r9, =sort_arr		; r2 = currente element in sort_arr
	LDR r3,[r9]


	BL bubble_sort
	B  find_item
; !! BUBBLE SORT !!
bubble_sort
;TODO CHECK THIS BUBBLE SORT	
; inputs
;   r3 - start of vector
;   r1 - number of elements to sort
; locals
;   r4 - current pointer	r5 - inner counter
;   r6 - keep_going flag	r7 - first element
;   r8 - second element

	PUSH {r10,lr}   			; save the return address
	LDR r1, =num_elements	; r1 = number of elements in Price_list
	LDR r1, [r1]	
	CMP	r1, #1				; number of elements must be > 1
	BLE	EndFunc				; stop if nothing to do

    SUB	r5, r1, #1			; need n-1 comparisons
    MOV	r4, r9				; initialize current pointer
	MOV	r6, #0				; this register set when we swap

LoopStart
	LDR	r7, [r4],#8			;load one element
	LDR	r8, [r4]			;and next one
	CMP	r7, r8				;compare them
	BLE	NoSwap				;branch if second greater

	MOV	r6, #1				;set keep_going flag
	SUB	r4, r4, #8			;reset pointer to first element
	SWP	r8, r8, [r4]		;exchange value in r8 and address in r4
	STR r8, [r4,#8]!		;store new r8 to incremented address
NoSwap
	SUBS	r5, r5, #1		;decrement counter
	BNE	LoopStart			;and restart loop if more needed

EndInner
	CMP	r6, #0				;check keep_going flag
	BEQ	EndFunc				;and leave if not set

	MOV	r6, #0				;clear keep_going flag 
	MOV	r4, r9				;reset pointer
    SUB r5, r1, #1			;reset counter
	B	LoopStart			;start another iteration

EndFunc
	pop {pc, r10}


	 
find_item		  
	LDR	r0,=Item_list
	LDR r1,[r0]			;current element in item list (here is element 0 so first one)
	LDR r2,=sort_arr 
	LDR r3,[r2] 		;current element in Price_list (index=0)


	MOV r2,#0		   	;r2 store the current price in the pricelist
	MOV r10,#0			;total expenses
	MOV r11,#0			;first = 0 (lower bound)
	MOV r9,#29			;last = num_entries -1 (upper bound)
	MOV r8,#0	   		;middle=0
	MOV r12,#4			;index for price in itemlist

next_loop
	CMP r11, r9         ;compare first to last
	BGT not_found       ;if last<first error
	ADD r8, r9, r11     ;middle =  first + la
	MOV r8, r8, LSR#1   ;middle = (first + last)/2
	LSL r8,#3			;middle*8 = position in Price_list
	LDR r5,[r3,r8]    	;load the element at middle 
	CMP r1, r5        	;compare the current item code with the current element code
	BNE next_element  	;skip to the next element in Price_list
   
   ;!!! item found in Price_list !!!
	ADD r8,r8,#4		;increment to next byte so get the value
	LDR r6,[r3,r8]		;load into r6 the value associated to element (AKA price)		
	LDR r4,[r0,r12]		;get into r4 the number of items associated to the item code
	MUL r7,r4,r6	    ;price*number_of_items
	ADD r10,r10,r7		;tot+=price
	B next_search		;current item found > skip to next item in Item_list
   
next_element 
	LSR r8,#3	 		;shift by right by 3 in order to get back the correct value of middle
	SUBLT r9,r8,#1 		;if price_list[middle] > item, last = middle-1 
	ADDGT r11,r8,#1	 	;if price_list[middle] < item, first= middle+1
	B next_loop		 	;go trough

next_search
	ADD r2,r2,#8		;increment 
	LDR r1,[r0,r2]		;move to the next item in Item_list
	ADD r12,r12,#8		;increment to the next value of price in Item_list
	MOV r11,#0			;first =0;
	MOV r9,#29			;last = num_entries -1
	MOV r8,#0	   		;middle=0 
	MOV r6,#0		    ;reset r6
	MOV r4,#0		    ;reset r4
	LDR r6,=num_items  	;load number of entries
	LDR r4,[r6]
	LSL R4,#3		    ;num_entries * 8bits 
	CMP r4,r2	
	MOVGT r4,#0			;reset r6
	MOVGT r6,#0		
	BGT next_loop		;loop if tere is another entry
	B stop

not_found
	MOV r10, #0	   		;set to 0 the total expenses if one item is missed	
stop	
	END

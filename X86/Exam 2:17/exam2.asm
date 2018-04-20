;exam of 17/02/2017

.model small
.586
.stack
.data

NUM_PUR db 1 dup(?)
PUR_OBJ dw 8 dup(?)
CAT_TAX db 4 dup(?)

RESULTS db 40 dup(?)
TOTAL_DISC dw 1 dup(?)
TOTAL_PRICE dw 1 dup(?)
TOTAL_TAX dw 1 dup(?)
TOTAL_NET dw 1 dup(?)

TOTAL_FOR_CATEGORY dw 16 dup(?)

buffer db 11 dup(?)

string1 byte "Object ", 0
string2 byte "Applied discount: ", 0
string3 byte "Net price: ", 0
string4 byte "Tax due: ", 0
string5 byte "Final price to be paid: ", 0

string6 byte "Total applied discount: ", 0
string7 byte "Total net price: ", 0
string8 byte "Total tax due: ", 0
string9 byte "Total final price to be paid: ", 0

string10 byte "Category ", 0

string11 byte "Do you want to insert another object? (y/n): ", 0
string12 byte "Insert list price (ii.ff): ", 0
string13 byte "Insert category (0-3): ", 0
string14 byte "Insert discount factor (0.ffffff): ", 0


.code
.startup

main    	proc
			call fill_cat_tax
			call fill_pur_obj
			mov ah, 2
			mov dl, 0ah			;print '\n'
			int 21h
			call compute_results
			call print_results
			mov TOTAL_DISC, 0
			mov TOTAL_NET, 0
			mov TOTAL_TAX, 0
			mov TOTAL_PRICE, 0
			mov ah, 2
			mov dl, 0ah			;print '\n'
			int 21h
			call compute_totals
			call print_totals
			call reset_tot_cat
			call compute_totals_for_category
			call print_total_categ
			
			mov ah, 4ch
			int 21h
main		endp


fill_pur_obj		proc
					pusha
					mov di, offset buffer
					mov byte ptr[di], sizeof buffer		;put buffer size in the first byte
					xor cl, cl
					xor si, si
			loop7:	cmp cl, 8
					jz exit_loop7
					push cx
					mov ah,40h
					mov bx,1
					mov cx, sizeof string11
					mov dx, offset string11
					int 21h				;print string11
					mov ah, 1
					int 21h			;read option
					mov cl, al
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					cmp cl, 'n'
					jnz ask_param
					pop cx
					jmp exit_loop7
					
		ask_param:	mov ah,40h
					mov bx,1
					mov cx, sizeof string12
					mov dx, offset string12
					int 21h				;print string12
					mov dx, offset buffer
					mov ah, 0ah
					int 21h				;read string from user input
					call convert_toBin_listPrice
					;in <Al> there is the converted number 
					mov bl, al
					shr bl, 2
					cmp bl, 56
					jbe check2
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					jmp ask_param
			check2: cmp bl, 1
					jnb store1
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					jmp ask_param
			store1:	mov byte ptr PUR_OBJ[si], al
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					
		ask_again2: mov ah,40h
					mov bx,1
					mov cx, sizeof string13
					mov dx, offset string13
					int 21h				;print string13
					mov ah, 1
					int 21h			;read category
					sub al, '0'
					cmp al, 3
					jbe store2
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					jmp ask_again2
			store2: shl al, 6
					mov byte ptr PUR_OBJ[si+1], al
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					
		ask_again3:	mov ah,40h
					mov bx,1
					mov cx, sizeof string14
					mov dx, offset string14
					int 21h				;print string14
					mov dx, offset buffer
					mov ah, 0ah
					int 21h				;read string from user input
					mov bl, buffer[2]
					sub bl, '0'
					cmp bl, 0
					jz store3
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					jmp ask_again3
			store3:	call convert_toBin_discFactor
					;in <Al> there is the converted number 
					mov ah, byte ptr PUR_OBJ[si+1]
					and ah, 11000000b
					or ah, al
					mov byte ptr PUR_OBJ[si+1], ah
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					pop cx
					inc cl
					add si, 2
					jmp loop7

		exit_loop7:	mov NUM_PUR, cl			
					popa
					ret
fill_pur_obj		endp


convert_toBin_discFactor	proc
							push di
							push bp
							push bx
							push cx
							push dx
							push si
							push ax
							
							xor cl, cl
							cmp buffer[1], 8
							jb continue3
							mov ecx, 100000
							mov bx, cx
							shr ecx, 16
							mov si, 15625
							mov ch, 0			;number of shift left
							jmp start_conversion2
				continue3:	cmp buffer[1], 7
							jb continue4
							mov bx, 10000
							mov si, 3125
							mov ch, 1			;number of shift left
							jmp start_conversion2
				continue4:	cmp buffer[1], 6
							jb continue5
							mov bx, 1000
							mov si, 625
							mov ch, 2			;number of shift left
							jmp start_conversion2
				continue5:	cmp buffer[1], 5
							jb continue6
							mov bx, 100
							mov si, 125
							mov ch, 3			;number of shift left
							jmp start_conversion2
				continue6:	cmp buffer[1], 4
							jb continue7
							mov bx, 10
							mov si, 25
							mov ch, 4			;number of shift left
							jmp start_conversion2
				continue7:	mov bx, 1
							mov si, 5
							mov ch, 5			;number of shift left
				
		start_conversion2:	push si
							push cx
							mov ch, 2		;counter for chars (start from digit after .)
							xor di, di		;binary value for input string (Most significant word)
							xor bp, bp		;binary value for input string (Least significant word)
					loop9:	cmp ch, buffer[1]
							jz exit_loop9
							push cx
							shr cx, 8
							mov si, cx
							pop cx
							add si, 2
							mov al, buffer[si]
							sub al, '0'
							xor ah, ah
							mul bx
							add bp, ax
							adc di, dx
							mul cl
							add di, ax
							push cx
							xor ch, ch
							mov ax, bx
							mov dx, cx
							mov cx, 10
							div cx
							pop cx
							mov bx, ax		;the quotient is the new multiplier
							xor cl, cl
							inc ch
							jmp loop9
							
				exit_loop9:	pop cx
							pop si
							mov dx, di
							mov ax, bp
							mov bx, si
							div bx
							mov cl, ch
							shl ax, cl
							mov dl, al
							pop ax
							mov al, dl
							pop si
							pop dx
							pop cx
							pop bx
							pop bp
							pop di
							ret
convert_toBin_discFactor	endp	


;convert number in buffer in binary and put the result in <Al>
convert_toBin_listPrice		proc
							push bx
							push cx
							push dx
							push si
							push ax
							
							cmp buffer[1], 4
							jnz continue2
							mov bl, 1		;number has 1 integer digit and 2 fractional
							jmp start_conversion
				continue2:	mov bl, 10		;number has 2 integer digit and 2 fractional
							jmp start_conversion
			
		start_conversion:	xor ch, ch		;counter for chars
							xor bh, bh		;binary value for input string (integer part)
					loop8:	mov cl, buffer[1]
							sub cl, 3
							cmp ch, cl
							jz exit_loop8
							push cx
							shr cx, 8
							mov si, cx
							pop cx
							add si, 2
							mov al, buffer[si]
							sub al, '0'
							mul bl
							add bh, al
							mov al, bl
							xor ah, ah
							mov dl, 10
							div dl
							mov bl, al		;the quotient is the new multiplier
							inc ch
							jmp loop8
									
							
				exit_loop8:	xor dh, dh		;binary value for input string (fractional part)
							mov bl, 10
							shr cx, 8
							mov si, cx
							add si, 3		;go after the dot to take the fractional part
							mov al, buffer[si]
							sub al, '0'
							mul bl
							add dh, al
							mov al, buffer[si+1]
							sub al, '0'
							add dh, al
							
							mov al, dh
							xor ah, ah
							mov dl, 25
							div dl
							
							shl bh, 2
							or bh, al		;<Bh> = iiiiii.ff
							
							pop ax
							mov al, bh
							pop si
							pop dx
							pop cx
							pop bx
							ret
convert_toBin_listPrice		endp


fill_cat_tax		proc
					pusha
					xor si, si
					mov CAT_TAX[si], 0	;store 0.0% tax for category 1
					inc si
					mov CAT_TAX[si], 11 ;store 5.5% tax for category 2
					inc si
					mov CAT_TAX[si], 25 ;store 12.5% tax for category 3
					inc si
					mov CAT_TAX[si], 5  ;sore 2.5% tax for category 4
					popa
					ret
fill_cat_tax		endp


print_total_categ	proc
					pusha
					xor cl, cl
					xor si, si
			loop6:	cmp cl, 4
					jz exit_loop6
					push cx
					mov ah,40h
					mov bx,1
					mov cx, sizeof string10
					mov dx, offset string10
					int 21h				;print string10
					mov ah, 2
					pop cx
					mov dl, cl
					add dl, '0'
					int 21h		;print category number
					mov dl, ':'
					int 21h
					mov dl, 0ah			;print '\n'
					int 21h
					
					push cx
					mov ah,40h
					mov bx,1
					mov cx, sizeof string6
					mov dx, offset string6
					int 21h				;print string6
					mov ax, TOTAL_FOR_CATEGORY[si]
					call print_fractional_num2
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					
					mov ah,40h
					mov bx,1
					mov cx, sizeof string7
					mov dx, offset string7
					int 21h				;print string7
					mov ax, TOTAL_FOR_CATEGORY[si+2]
					call print_fractional_num2
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					
					mov ah,40h
					mov bx,1
					mov cx, sizeof string8
					mov dx, offset string8
					int 21h				;print string8
					mov ax, TOTAL_FOR_CATEGORY[si+4]
					call print_fractional_num2
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					
					mov ah,40h
					mov bx,1
					mov cx, sizeof string9
					mov dx, offset string9
					int 21h				;print string9
					mov ax, TOTAL_FOR_CATEGORY[si+6]
					call print_fractional_num2
					mov ah, 2
					mov dl, 0ah			;print '\n'
					int 21h
					pop cx
					inc cl
					add si, 8
					jmp loop6
					
		exit_loop6:	popa
					ret
print_total_categ	endp


print_totals		proc
					pusha
					mov ah,40h
					mov bx,1
					mov cx, sizeof string6
					mov dx, offset string6
					int 21h				;print string6
					mov ax, TOTAL_DISC
					call print_fractional_num2
					mov ah,2
					mov dl, 0ah			;print '\n'
					int 21h
					
					mov ah,40h
					mov bx,1
					mov cx, sizeof string7
					mov dx, offset string7
					int 21h				;print string7
					mov ax, TOTAL_NET
					call print_fractional_num2
					mov ah,2
					mov dl, 0ah			;print '\n'
					int 21h
					
					mov ah,40h
					mov bx,1
					mov cx, sizeof string8
					mov dx, offset string8
					int 21h				;print string8
					mov ax, TOTAL_TAX
					call print_fractional_num2
					mov ah,2
					mov dl, 0ah			;print '\n'
					int 21h
					
					mov ah,40h
					mov bx,1
					mov cx, sizeof string9
					mov dx, offset string9
					int 21h				;print string9
					mov ax, TOTAL_PRICE
					call print_fractional_num2
					mov ah,2
					mov dl, 0ah			;print '\n'
					int 21h
					int 21h

					popa
					ret
print_totals		endp


;print number in <Ax>  (iii.ff)
print_fractional_num2		proc
							pusha
							push ax
							mov ch, 1		;used to store num integer digits
							xor cl, cl		;store the first digit to print
							xor dx, dx		;store the second and third digit to print
							shr ax, 2
							mov bl, 10
							div bl
							mov dl, ah
							cmp al, 0
							jz print_integer
							inc ch
							xor ah, ah
							div bl
							mov dh, ah
							cmp al, 0
							jz print_integer
							inc ch
							xor ah, ah
							div bl
							mov cl, ah							
			print_integer:	mov ah, 2
							cmp ch, 3
							jb print2
							push dx
							mov dl, cl
							add dl, '0'
							int 21h			;print first digit
							pop dx
					print2:	cmp ch, 2
							jb print1
							push dx
							mov dl, dh
							add dl, '0'
							int 21h
							pop dx
					print1:	add dl, '0'
							int 21h
							mov dl, '.'
							int 21h
							
							pop ax
							mov bl, al
							and bl, 00000011b		;take only the fractional part
							mov dh, 10
							mov al, bl
							mul dh
							push ax
							mov dl, al
							shr dl, 2
							add dl, '0'
							mov ah, 2
							int 21h			;print first fractional digit
							pop ax
						
							xor ah, ah
							and al, 00000011b	;reset integer part
							mul dh
							mov dl, al
							shr dl, 2
							add dl, '0'
							mov ah, 2
							int 21h		;print second fractional digit
						
							mov dl, '$'
							int 21h
							popa
							ret
print_fractional_num2		endp


print_results		proc
					pusha
					xor cl, cl
					xor si, si
			loop5:	cmp cl, NUM_PUR
					jz exit_loop5
					push cx
					mov ah,40h
					mov bx,1
					mov cx, sizeof string1
					mov dx, offset string1
					int 21h				;print string1
					pop cx
					mov ah,2
					mov dl, cl
					inc dl
					add dl, '0'
					int 21h		;print object number
					mov dl, ':'
					int 21h
					mov dl, 0ah			;print '\n'
					int 21h
					
					push cx
					mov ah,40h
					mov bx,1
					mov cx, sizeof string2
					mov dx, offset string2
					int 21h				;print string2
					mov al, RESULTS[si]	;take applied discount
					call print_fractional_num
					mov ah,2
					mov dl, 0ah			;print '\n'
					int 21h	
					
					mov ah,40h
					mov bx,1
					mov cx, sizeof string3
					mov dx, offset string3
					int 21h				;print string3
					mov al, RESULTS[si+1]	;take net price
					call print_fractional_num
					mov ah,2
					mov dl, 0ah			;print '\n'
					int 21h	
					
					mov ah,40h
					mov bx,1
					mov cx, sizeof string4
					mov dx, offset string4
					int 21h				;print string4
					mov al, RESULTS[si+2]	;take tax due
					call print_fractional_num
					mov ah,2
					mov dl, 0ah			;print '\n'
					int 21h	
					
					mov ah,40h
					mov bx,1
					mov cx, sizeof string5
					mov dx, offset string5
					int 21h				;print string5
					mov al, RESULTS[si+3]	;take final price to be paid
					call print_fractional_num
					mov ah,2
					mov dl, 0ah			;print '\n'
					int 21h	
					pop cx
					inc cl
					add si, 5
					jmp loop5

		exit_loop5:	popa
					ret
print_results		endp


;print number in <Al>  (ii.ff)
print_fractional_num	proc
						pusha
						mov bl, al
						shr al, 2		;take only integer part
						xor cx, cx
						xor ah, ah
						mov dl, 10
						div dl
						mov cl, ah		;store residual
						xor ah, ah
						div dl
						mov ch, ah
						cmp ch, 0
						jz continue1
						add ch, '0'
						mov dl, ch
						mov ah, 2
						int 21h
			continue1:	add cl, '0'
						mov dl, cl
						mov ah, 2
						int 21h
						mov dl, '.'
						int 21h
						
						and bl, 00000011b		;take only the fractional part
						mov dh, 10
						mov al, bl
						mul dh
						push ax
						mov dl, al
						shr dl, 2
						add dl, '0'
						mov ah, 2
						int 21h			;print first fractional digit
						pop ax
						
						xor ah, ah
						and al, 00000011b	;reset integer part
						mul dh
						mov dl, al
						shr dl, 2
						add dl, '0'
						mov ah, 2
						int 21h		;print second fractional digit
						
						mov dl, '$'
						int 21h
						popa
						ret
print_fractional_num	endp


reset_tot_cat		proc
					pusha
					xor cl, cl
					xor si, si
					xor ax, ax
			loop4:	cmp cl, 4
					jz exit_loop4
					mov TOTAL_FOR_CATEGORY[si], ax
					mov TOTAL_FOR_CATEGORY[si+2], ax
					mov TOTAL_FOR_CATEGORY[si+4], ax
					mov TOTAL_FOR_CATEGORY[si+6], ax
					inc cl
					add si, 8
					jmp loop4
					
		exit_loop4:	popa
					ret
reset_tot_cat		endp


compute_results		proc
					pusha
					xor si, si
					xor di, di
					xor cl, cl
			loop1:	cmp cl, NUM_PUR
					jz exit_loop1
					mov al, byte ptr PUR_OBJ[si]
					mov bl, byte ptr PUR_OBJ[si+1]
					and bl, 00111111b
					mul bl
					shl ax, 2
					mov RESULTS[di], ah
					mov al, byte ptr PUR_OBJ[si]
					sub al, ah
					mov RESULTS[di+1], al
					mov bl, byte ptr PUR_OBJ[si+1]
					shr bl, 6
					push si
					xor bh, bh
					mov si, bx
					mov bl, CAT_TAX[si]
					and bl, 00011111b
					pop si
					mul bl
					mov bh, 200
					div bh
					mov RESULTS[di+2], al
					mov ah, RESULTS[di+1]
					add al, ah
					mov RESULTS[di+3], al
					mov al, byte ptr PUR_OBJ[si+1]
					shr al, 6
					mov RESULTS[di+4], al
					inc cl
					add si, 2
					add di, 5
					jmp loop1

		exit_loop1:	popa
					ret
compute_results		endp


compute_totals		proc
					pusha
					xor cl, cl
					xor ah, ah
					xor di, di
			loop2:	cmp cl, NUM_PUR
					jz exit_loop2
					mov al, RESULTS[di]
					add TOTAL_DISC, ax
					mov al, RESULTS[di+1]
					add TOTAL_NET, ax
					mov al, RESULTS[di+2]
					add TOTAL_TAX, ax
					mov al, RESULTS[di+3]
					add TOTAL_PRICE, ax
					inc cl
					add di, 5
					jmp loop2
		exit_loop2: popa
					ret
compute_totals		endp


compute_totals_for_category		proc
								pusha
								xor di, di
								xor si, si
								xor cl, cl
						loop3:	cmp cl, NUM_PUR
								jz exit_loop3
								mov al, RESULTS[di+4]
								xor ah, ah
								mov si, ax
								shl si, 3
								mov bl, RESULTS[di]
								xor bh, bh
								add TOTAL_FOR_CATEGORY[si], bx
								mov bl, RESULTS[di+1]
								add TOTAL_FOR_CATEGORY[si+2], bx
								mov bl, RESULTS[di+2]
								add TOTAL_FOR_CATEGORY[si+4], bx
								mov bl, RESULTS[di+3]
								add TOTAL_FOR_CATEGORY[si+6], bx
								add di, 5
								inc cl
								jmp loop3
				exit_loop3:		popa
								ret
compute_totals_for_category		endp


end
;Exercise 15/9/14
;ITEM A


.model small
.386  ; enable pusha popa,shr shl
.stack
.data
N EQU 20
EXPENSES DB 3*N DUP (?)   ;[v ddddd cc] [eeeeeeee] [ffffffff]
CONVERTED DB 3*N DUP (?)
EXCHANGE DB 32*3 DUP (?)  ;[uuuuuuuu] [aaaaaaaa] [hhhhhhhh]
GRAND_TOTAL DB 3 DUP (?)
DAY_GRAND_TOTAL DB 3 DUP (?)
TEMP DB 5 DUP(0)                 ;TEMP is made of 5 bytes because with a 16-bits word stored in AX we can have 5 iterations of "cycle"



space_string DB "       $"
end_program DB "Bye Bye!", 13, 10, "$"
day_msg DB "Day:   ", "$"
total_msg DB "Grand Total:   ", "$"
day_total_msg DB "Day Grand Total:   ", "$"
expense_msg DB "Expense:   ", "$"
end_item1 DB "Item1 is completed!", 13, 10, "$"
item3_msg DB "Please type the day (a number from 1 to 31):", 13, 10, "$"
end_item2 DB "Item2 is completed!", 13, 10, "$"
end_item3 DB "Item3 is completed!", 13, 10, "$"
err_int_msg DB "The number typed is greater than 31 or the characters typed are not numbers. Please type another number:", 13, 10, "$"
menu_msg DB "Welcome! Type 1 for ITEM 1, 2 for ITEM 2, 3 for ITEM 3, 0 to exit", 13, 10, "$"
error_msg DB "Wrong character!", 13, 10, "$"


.code


.startup
;PROGRAM STARTS


;Fill the database with 20 records
mov exchange[0][2], 10000000b   ;usd->euro=0.5
mov exchange[0][1], 01000000b		;cad->euro=0.25
mov exchange[0][0], 00100000b		;chf->euro=0.125

mov expenses[0][0], 11000000b		;fractional=75
mov expenses[0][1], 00001111b		;integer=15
mov expenses[0][2], 10000111b		;day=1 euro

mov expenses[3][0], 10000000b		;fractional=5
mov expenses[3][1], 00000001b		;integer=1
mov expenses[3][2], 10001011b		;day=2 euro

mov expenses[6][0], 10000000b		;fractional=5
mov expenses[6][1], 00001010b		;integer=10
mov expenses[6][2], 10001100b		;day=3 usd

mov expenses[9][0], 00100000b		;fractional=125
mov expenses[9][1], 00001100b		;integer=12
mov expenses[9][2], 10001100b		;day=3 usd

mov expenses[12][0], 11000000b		;fractional=75
mov expenses[12][1], 00001011b		;integer=11
mov expenses[12][2], 10010001b		;day=4 cad

mov expenses[15][0], 10000000b		;fractional=5
mov expenses[15][1], 00001010b		;integer=10
mov expenses[15][2], 10010110b		;day=5 chf

mov expenses[18][0], 00100000b		;fractional=125
mov expenses[18][1], 00001100b		;integer=12
mov expenses[18][2], 10011110b		;day=7 chf

mov expenses[21][0], 10000000b		;fractional=5
mov expenses[21][1], 00101100b		;integer=44
mov expenses[21][2], 10111110b		;day=15 chf

mov expenses[24][0], 00100000b		;fractional=125
mov expenses[24][1], 01000000b		;integer=64
mov expenses[24][2], 10111110b		;day=15 chf

mov expenses[27][0], 00100000b		;fractional=125
mov expenses[27][1], 01100100b		;integer=100
mov expenses[27][2], 11101101b		;day=27 cad

mov expenses[30][0], 10000000b		;fractional=5
mov expenses[30][1], 01100110b		;integer=102
mov expenses[30][2], 11101101b		;day=27 cad

mov expenses[33][0], 11000000b		;fractional=75
mov expenses[33][1], 00100000b		;integer=32
mov expenses[33][2], 11101101b		;day=27 cad

mov expenses[36][0], 10000000b		;fractional=5
mov expenses[36][1], 01100110b		;integer=102
mov expenses[36][2], 11110000b		;day=28 usd

mov expenses[39][0], 00000000b		;fractional=0
mov expenses[39][1], 00010100b		;integer=20
mov expenses[39][2], 11110000b		;day=28 usd

mov expenses[42][0], 00110000b		;fractional=1875
mov expenses[42][1], 00001111b		;integer=15
mov expenses[42][2], 11110000b		;day=28 usd

mov expenses[45][0], 00000000b		;fractional=0
mov expenses[45][1], 00010100b		;integer=20
mov expenses[45][2], 11110111b		;day=29 euro

mov expenses[48][0], 00000000b		;fractional=0
mov expenses[48][1], 160		;integer=160
mov expenses[48][2], 11111011b		;day=30 euro

mov expenses[51][0], 00000000b		;fractional=0
mov expenses[51][1], 100		;integer=100
mov expenses[51][2], 11111011b		;day=30 euro

mov expenses[51][0], 00000000b		;fractional=0
mov expenses[51][1], 101		;integer=100
mov expenses[51][2], 11111111b		;day=31 euro


mov expenses[57][0], 00000000b		;fractional=0
mov expenses[57][1], 00010100b		;integer=20
mov expenses[57][2], 01110001b		;day=28 usd   not valid

mov ax,3    ;clear the screen befor start
int 10h
xor ax,ax

menu:
lea dx, menu_msg   ;print the string
mov ah, 9
int 21h
mov ah,01H      ;read the character inserted by the user and
int 21h         ;it is stored into al
cmp al,'0'
je exit
cmp al,'1'
je item_1
cmp al,'2'
je item_2
cmp al,'3'
je item_3

error:
lea dx, error_msg   ;print the error msg
mov ah, 9
int 21h
call printNL
jmp menu        ;jump back to menu to allow the user choice


item_1:
push cx
push bx
push ax
push dx     ;save the current value of registers
mov cx,N    ;set the counter N that is the number of record, and so the number of iterations to do
xor bx,bx
xor di,di
xor si,si
xor bp,bp

loop1:
  mov al, EXPENSES[bx][di+2]  ;get in al the vdddddcc of each expense
  and al,10000000b   ;get the first bit to verify the validity
  cmp al,128
  je conversion     ;if the validity bit is equal to 0 warn the user and back to main menu
  jmp end_item      ;otherwise jump to conversion algorithm

  next_record:
  add bx,03H
  add bp,3
  loop loop1
  jmp menu

conversion:
call printNL
mov ah, EXPENSES[bx][di+2]   ;get in al the vdddddcc of expense
mov dl, ah
and dl,00000011b ;get into dl the currency code
and ah,11111100b  ;set to 00 the currency code
add ah,3        ;3 is added to ah to have cc=11
mov CONVERTED[bp][si+2],ah    ;ah is stored into CONVERTED array
and ah,01111100b ;get in ah the day of august multiplied by 4

push ax
push dx
lea dx, day_msg   ;print the string
mov ah, 9
int 21h
pop dx
pop ax

push cx
push dx
mov cl,2
shr ah,cl      ;divide ah by four in order to obtain right day
xor dx,dx
mov dl,ah
call print    ;print the number in ASCII
call space    ;print the space
pop dx
pop cx

mov ah,EXPENSES[bx][di+1] ;get in ah the integer part
mov al,EXPENSES[bx][di] ;get in al the fractional part

cmp dl,2      ;dl is storing the current currency for the record
je chf        ;it is compared with all the possibilities in order
cmp dl,1      ;to make the right operation
je cad
cmp dl,0
je usd
cmp dl,3
je euro


chf:
mov dl, EXCHANGE[di]  ;get from EXCHANGE the conversion rate for chf
xor dh,dh     ;dh is all 0s
mul dx      ; ax * dx-> result goes on dx and ax
jmp continue

cad:
mov dl, EXCHANGE[di+1]  ;get from EXCHANGE the conversion rate for chd
xor dh,dh     ;dh is all 0s
mul dx      ; ax * dx-> result goes on dx and ax
jmp continue
usd:
mov dl, EXCHANGE[di+2]  ;get from EXCHANGE the conversion rate for usd
xor dh,dh     ;dh is all 0s
mul dx      ; ax * dx-> result goes on dx and ax
jmp continue

euro:
mov dl,ah   ; the integer part of EXPENSES is stored now into dl
mov ah,al   ; the fractional part of EXPENSES is stored into ah

continue:
push ax
push dx
lea dx, expense_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax

mov CONVERTED[bp][si],ah      ;storing into CONVERTED the fractional part that is into al
mov CONVERTED[bp][si+1],dl    ;storing into CONVERTED the integer part that is into dl
push dx
xor dh,dh
call print
pop dx

push dx
push ax
mov dl, '.'   ;print the ascii char "."
mov ah, 02H
int 21h
pop ax
pop dx

mov dl,ah
xor dh,dh
call print_fract    ;print the fractionl part
call printNL

jmp next_record

end_item:
push ax
push dx
lea dx, end_item1   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
pop dx
pop ax
pop cx
jmp menu


item_2:
push ax
push dx
push bx
xor di,di
xor bx,bx
mov cx,N
xor ax,ax
xor bp,bp
xor dx,dx

loop2:
mov bl, CONVERTED[bp][di]   ;get into bl the fractional part
mov bh, CONVERTED[bp][di+1] ;get into ah the integer part
add ax,bx     ;add to bx the value stored into bx and ax is used as accumulator
adc dl,0      ;the carry flag from previous operation is stored into dl
add bp,3  ;move to next record
loop loop2 ;loop until counter is 0

call printNL

push ax
push dx
lea dx, total_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax

mov GRAND_TOTAL[di+2], dl   ;dl is storing the MS integer part
mov dh,dl
mov GRAND_TOTAL[di+1],ah    ;ah is storing the LB integer part
mov dl,ah
call print

push dx
push ax
mov dl, '.'   ;print the ascii char "."
mov ah, 02H
int 21h
pop ax
pop dx

mov GRAND_TOTAL[di],al    ;al is storing the fractional part
mov dl, GRAND_TOTAL[di]   ;save the value of GRAND_TOTAL in order to print the value
xor dh,dh
call print_fract
call printNL

push ax
push dx
lea dx, end_item2   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
jmp menu

item_3:
push ax
push dx
push bx
xor di,di
xor bx,bx
xor ax,ax
xor bp,bp
xor dx,dx

call printNL

push ax
push dx
lea dx, item3_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax

call input      ;this procedure return the number inserted by the user and store it into dl

loop4:
mov cl, CONVERTED[bp][di+2]   ;get into cl the byte storing the day
and cl, 01111100b ;get into cl the day
shr cl,2  ; get 000ddddd
cmp cl,dl ;if the day inserted by the user is equal to the one stored into array
jb skip   ;if day into array is smaller than inputted one skip to nex record
je sum  ;if days corresponds need to sum up all expenses
ja exit_item3



skip:
add bp,3
jmp loop4


sum:
mov bl, CONVERTED[bp][di] ;get fractional part
mov bh, CONVERTED[bp][di+1] ;get integer part
add ax,bx ; add expense to ax that is accumulator
adc dh,0  ; carry flag of previous operation is added to dh
jmp skip


exit_item3:
call printNL
push ax
push dx
lea dx, day_total_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax

mov DAY_GRAND_TOTAL[di+2],dh ;store MS of integer into array
mov DAY_GRAND_TOTAL[di+1],ah ;store LS of integer part into array
mov dl,ah
call print

push dx
push ax
mov dl, '.'   ;print the ascii char "."
mov ah, 02H
int 21h
pop ax
pop dx

mov DAY_GRAND_TOTAL[di],al ; store into array fractional part
mov dl, DAY_GRAND_TOTAL[di]
xor dh,dh
call print_fract
call printNL

push ax
push dx
lea dx, end_item3   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax

jmp menu


input PROC
push ax
push bx
push cx

start:
xor dx,dx
num_int:
mov bx,10
mov ah,1
int 21h   ;get the input char
cmp al,13 ;if the input number is equal to carriage return proc ends
je end_int
cmp al, '0'     ;check if the input is between 0 and 9 if not error is arised
jb err_int
cmp al,'9'
ja err_int
sub al,'0'  ;get the binary rapresentation of the number inserted
xchg ax,bx  ;swapping ax and bx   ax=10 now
xor bh,bh   ;bh=0
mul dx    ; dx is multiplied by ax that is 10 and result is stored into ax
cmp dx,0  ;if dx!=0 result of mul cannot be represented on 16 bits
jne err_int
mov dx,ax ;get into dx the result of mul
add dx,bx ;dx is added with the binary representation of the last char
cmp dx,31
ja err_int  ;if dx is greater than 31 error arised
jmp num_int

err_int:
lea dx, err_int_msg   ;print the  msg
mov ah, 9
int 21h
jmp start

end_int:
pop cx
pop bx
pop ax
ret
input ENDP

  ;this procedure print the new line
  printNL PROC
  pusha
  mov dl,0Ah
  mov ah,2
  int 21h
  popa
  ret
  printNL ENDP

  print   proc                ;this is the procedure for the binary-ascii conversion

    push di             ;i'm saving the current values of the registers
  	push ax
  	push bx
  	push dx
  	xor di, di          ;<di> is now 0
  	mov ax, dx          ;<dx> is the binary number to print and here i'm storing it into ax

  conv: 	xor dx, dx          ;<dx> is now 0
  	mov bx, 10          ;<bx> is 10

  cycle:  div bx              ;<ax> is divided by <bx>, the remainder is stored into dl, the quotient into ax
  	add dl, '0'         ;the ascii code of '0' is added to the remainder of the previous division
  	mov temp[di], dl    ;<dl> is stored into a temporary vector
  	inc di              ;index <di> is incremented by 1
  	xor dx, dx          ;<dx> is now 0
  	cmp ax, 0           ;if <ax> is 0 the my cycle is completed
  	jne cycle           ;else i come back to cycle

  lab3:   dec di              ;index <di> is decremented by 1
  	mov dl, temp[di]    ;the value in the temporary vector is stored into dl
  	mov ah, 2           ;i'm printing the character whose ascii code is saved into dl
  	int 21h
  	cmp di, 0           ;if index <di> is 0 then my print is completed
  	jne lab3            ;else i come back to lab3

  	pop dx              ;i'm restoring the previous values of registers
  	pop bx
  	pop ax
  	pop di
  	ret                 ;this is the end of the procedure
  	print endp


  print_fract proc                 ;this is the procedure to print the fractional bits

  	pusha
  	xor ax,ax                ;<ax> is now 0
  	mov al, dl               ;<dl> is the fractional bits of expenses and it is stored into al


  loop3:
  	mov dl, 00001010b         ;<dl> is now 10
  	mul dl                    ;<ax> is multiplied by <dx>, where <ah>=0 and <al> represents fractional bits
  	mov dl, ah                ;<ah> is the integer part of the result of mul and it is stored into dl
  	call print                ;here i'm calling the procedure to print what i saved into dl in the previous instruction
  	xor ah,ah                 ;<ah> is now 0

  	cmp al, 0                 ;if <al> (which is the fractional part of the result of mul) is 0 then the print is completed
  	jnz loop3                 ;else i come back to loop3

  	popa                      ;i'm restoring the previous values of registers

  	ret                       ;this is the end of the procedure

  print_fract endp


  space proc
  	pusha
  	mov ah, 09h                 ;09h is the function of interrupt 21h which prints a string on stdvideo
    mov dx, offset space_string  ;dx is the pointer to the string
    int 21h                     ;here i'm printing the  space_string
    popa
    ret
  space endp


exit:
call printNL		;this procedure prints a new line
mov ah, 09h		        ;09h is the function of interrupt 21h which prints a string on
mov dx, offset end_program  ;dx is the pointer to the
int 21h                     ;here i'm printing the end_item1 message

.exit

end

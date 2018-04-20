
;--------------------------------
;|DEVELOPED BY GRAZIANO MARALLO |
;|S238159                       |
;|EXAM 29/01/2018
;--------------------------------
.model small
.386
.stack
.data
OBJ_PRICES DW 50 DUP(?) ;array of item in sale
N DW 9                 ;number of valid cell of OBJ_p
N_BUY DW ?        ; store the number of item that the user want to buy
BUYED DW 4 DUP(?)
OPT DB 1
CODE DW 1
DISCOUNT DW 1
FINAL_PRICE DW 1





error_msg DB "Wrong character!", 13, 10, "$"
menu_msg Db "Welcome! Type 1 to start, 0 for exit the program",13,10,"$"
welcome_msg Db "Welcome at Poly-Multiple Discount system manager! ",13,10,"$"
nitem_msg Db "Insert the number of items to buy (1 to 4) -> ","$"
itemcode_msg1 Db "Insert the item code (Range 0-","$"
itemcode_msg2 Db ") -> ","$"
discount_opt1 Db "Choose A or B discount option (R to reset, 0 to end) -> ","$"
discount_opt2 Db "Choose A,B or D discount option (R to reset, 0 to end) -> ","$"
discount_opt3 Db "Choose A,B,D or E discount option (R to reset, 0 to end) -> ","$"
chosen_item Db "Price of chosen item -> ","$"
msg_a Db "Discount option A -> ","$"
msg_b Db "Discount option B -> ","$"
msg_d Db "Discount option D -> ","$"
msg_e Db "Discount option E -> ","$"
final_price_msg db "Final price: ","$"
discount_msg db "Discount amount: ","$"
no_discount_msg db "No discount option allowed with one item!",13,10,"$"
end_program Db "Program terminated ",13,10,"$"
err_int_msg DB "Invalid number! Type again please.", 13, 10, "$"
max_item_msg DB "Non valid valid cell! Type again", 13, 10, "$"
type_again_msg DB "Type again please -> ","$"
err_char_msg DB "Invalid option! Only A,B,D and E (lower case included) are allowed", 13, 10, "$"

debug db "XXXX DEBUG PRINT array XXXX",13,10,"$"

.code
;Initialize the db for testing the program
initialize_array PROC
mov OBJ_PRICES[0],15000
mov OBJ_PRICES[2],13000
mov OBJ_PRICES[4],13000
mov OBJ_PRICES[6],10000
mov OBJ_PRICES[8],9999
mov OBJ_PRICES[10],7001
mov OBJ_PRICES[12],5000
mov OBJ_PRICES[14],4999
mov OBJ_PRICES[16],2099
mov OBJ_PRICES[18],1999
ret
initialize_array ENDP
.startup
;PROGRAM STARTS


mov ax,3    ;clear the screen befor start
int 10h
xor ax,ax

call initialize_array ;initialize the OBJ_PRICES with 10 item


menu:
lea dx, menu_msg   ;print the string
mov ah, 9
int 21h
mov ah,01H      ;read the character inserted by the user and
int 21h         ;it is stored into al
cmp al,27       ;compare with esc char
je err
cmp al,13       ;compare with carriage return char
je err
call printNL
cmp al,'0'
je end_p
cmp al,'1'
je item

err:
  call printNL
  lea dx, err_int_msg   ;print the  msg
  mov ah, 9
  int 21h
  jmp menu

;This procedure clean all register, print the start message and get in input the N_BUY
initialize PROC
mov ax,3    ;clear the screen befor start
int 10h
xor ax,ax

xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx
xor si,si

push ax
push dx
lea dx, welcome_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

call input_NBUY  ;store into N_BUY variable the number inserted by the user
call printNL
ret
initialize ENDP


item PROC
call initialize
mov cx,N_BUY
cmp cx,1        ;check the N_BUY value with 1 if is equal no discount must be applied
je no_discount

;N_BUY is greater than one so it's possible to fill a second array of N_BUY dimension
;and after sort it from the cheaper to the most expensive
call fill_array
call printNL
call bubble_sort

;compare N_BUY with 2,3,4 and take different decision depending on the number of item
cmp cx,2
je ab_discount
cmp cx,3
je abd_discount
cmp cx,4
je adbe_discount

;here just one item has been bought so it's necessary just to select the item requested
;from the array and print it on the screen
no_discount:

call input_code
xor si,si
mov si,CODE
shl si,1
mov ax, OBJ_PRICES[si]

call printArr
call printNL

push ax
push dx
lea dx, no_discount_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

push ax
push dx
lea dx, final_price_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call print
call printNL
call printNL
jmp menu
item ENDP

;This procedure handle two items bought and the relative discount option allowed
ab_discount PROC
push ax
push bx
push cx
push dx

call printArr
call printNL

;retrieve the two item sorted from cheapest to most expensive
again:

xor si,si
mov ax,BUYED[si]
add si,2
mov bx,BUYED[si]


push ax
push dx
lea dx, discount_opt1    ;print the string
mov ah, 9
int 21h
pop dx
pop ax


call get_option   ;this procedure store into OPT the option inserted by the user
cmp OPT,'A'       ;check if it was inserted A/a or B/b from the user and take different
je a_option       ;action. R stands for reset
cmp OPT,'a'
je a_option
cmp OPT,'B'
je b_option
cmp OPT,'b'
je b_option
cmp OPT,'R'
je exit
cmp OPT,'0'
je end_p


a_option:
push ax
push dx
lea dx, msg_a    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

push ax
push dx
lea dx, final_price_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

;ALGORITHM
;get in ax the 50 % of the original price and store it into DISCOUNT variable
;then add the value of ax to bx that store the most expensive price that has to
;be leaved to its full price. Then print final price and discount applied
shr ax,1
mov DISCOUNT,ax
add bx,ax
xor ax,ax
mov ax,bx
call print    ;final price with already computed discount
call printNL

push ax
push dx
lea dx, discount_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

xor ax,ax
mov ax,DISCOUNT
call print
call printNL
call printNL
jmp again

b_option:

push ax
push dx
lea dx, msg_b    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

push ax
push dx
lea dx, final_price_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

;ALGORITHM
;the cheapest is free so it's a 100% discount and it is stored inside the variable
;while save into ax bx, get 25% of it then sub bx to ax that was the initial value
;print final price and discount obtained
mov DISCOUNT,ax
mov ax,bx
shr bx,2 ;get 25%
add ax,bx
call print  ;print final price
call printNL

push ax
push dx
lea dx, discount_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
xor ax,ax
mov ax,DISCOUNT
sub ax,bx
call print
call printNL
call printNL
jmp again

exit:
pop dx
pop cx
pop bx
pop ax
call item
ab_discount ENDP


;This procedure handle the case of three item inserted and the 3 option of discount
abd_discount PROC
push ax
push bx
push cx
push dx

call printArr
call printNL

again:
xor si,si
mov ax,BUYED[si]  ;least expensive
add si,2
mov bx,BUYED[si]
add si,2
mov cx,BUYED[si]  ;most expensive


push ax
push dx
lea dx, discount_opt2    ;print the string
mov ah, 9
int 21h
pop dx
pop ax


call get_option
cmp OPT,'A'
je a_option
cmp OPT,'a'
je a_option
cmp OPT,'B'
je b_option
cmp OPT,'b'
je b_option
cmp OPT,'D'
je b_option
cmp OPT,'d'
je d_option
cmp OPT,'R'
je exit
cmp OPT,'0'
je end_p


a_option:

push ax
push dx
lea dx, msg_a    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

push ax
push dx
lea dx, final_price_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

;ALGORITHM
;Is the same applied before but the most expensive is stored into cx
shr ax,1
mov DISCOUNT,ax
add cx,ax
add cx,bx
xor ax,ax
mov ax,cx
call print    ;final price with already computed discount
call printNL

push ax
push dx
lea dx, discount_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

xor ax,ax
mov ax,DISCOUNT
call print
call printNL
call printNL
jmp again

b_option:

push ax
push dx
lea dx, msg_b    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

push ax
push dx
lea dx, final_price_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

;ALGORITHM
;Is the same applied before but the most expensive is stored into cx
mov DISCOUNT,ax
mov ax,cx
shr cx,2    ;get 25%
add ax,cx
add ax,bx
call print  ;print final price
call printNL

push ax
push dx
lea dx, discount_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
xor ax,ax

mov ax,DISCOUNT
sub ax,cx
call print
call printNL
call printNL
jmp again

d_option:

push ax
push dx
lea dx, msg_d    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

push ax
push dx
lea dx, final_price_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

;ALGORITHM
;here dx is used as temp variable for storing meta result
;first is computed the 6.25% of the most expensive and stored into discount
;then the percentage is subtracted to the total add to final price
;iterating is done the same job for the other.Then print
push dx
xor dx,dx
mov dx,cx
shr cx,4  ;6.25 %
mov DISCOUNT,cx
sub dx,cx
mov FINAL_PRICE,dx
xor dx,dx
mov dx,bx
shr bx,3  ;12.50%
add DISCOUNT,bx
sub dx,bx
add FINAL_PRICE,dx
xor dx,dx
mov dx,ax
shr ax,2  ;25%
add DISCOUNT,ax
sub dx,ax
add FINAL_PRICE,dx
pop dx

xor ax,ax
mov ax,FINAL_PRICE
call print
call printNL

push ax
push dx
lea dx, discount_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
xor ax,ax
mov ax,DISCOUNT
call print
call printNL
call printNL
jmp again

exit:
pop dx
pop cx
pop bx
pop ax
call item
abd_discount ENDP

;this procedure handle the 4 item inserted and all the 4 option of discount
adbe_discount PROC
push ax
push bx
push cx
push dx

call printArr
call printNL

again:


xor si,si
mov ax,BUYED[si]   ;cheapest
add si,2
mov bx,BUYED[si]
add si,2
mov cx,BUYED[si]
add si,2
mov dx,BUYED[si]    ;most expensive


push ax
push dx
lea dx, discount_opt3    ;print the string
mov ah, 9
int 21h
pop dx
pop ax


call get_option
cmp OPT,'A'
je a_option
cmp OPT,'a'
je a_option
cmp OPT,'B'
je b_option
cmp OPT,'b'
je b_option
cmp OPT,'D'
je d_option
cmp OPT,'d'
je d_option
cmp OPT,'E'
je e_option
cmp OPT,'e'
je e_option
cmp OPT,'R'
je exit
cmp OPT,'0'
je end_p

a_option:
push ax
push dx
lea dx, msg_a    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

push ax
push dx
lea dx, final_price_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

;ALGORITHM
;same as before but dx store the interested price
shr ax,1
mov DISCOUNT,ax
add dx,ax
add dx,bx
add dx,cx
xor ax,ax
mov ax,dx
call print    ;final price with already computed discount
call printNL

push ax
push dx
lea dx, discount_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

xor ax,ax
mov ax,DISCOUNT
call print
call printNL
call printNL
jmp again

b_option:

push ax
push dx
lea dx, msg_b    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

push ax
push dx
lea dx, final_price_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

;ALGORITHM
;same as before but dx store the interested price
mov DISCOUNT,ax
mov ax,dx
shr dx,2 ;get 25%
add ax,dx
add ax,cx
add ax,bx
call print  ;print final price
call printNL

push ax
push dx
lea dx, discount_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
xor ax,ax
mov ax,DISCOUNT
sub ax,dx
call print
call printNL
call printNL
jmp again

d_option:

push ax
push dx
lea dx, msg_d    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

push ax
push dx
lea dx, final_price_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax

;ALGORITHM
;same as before but bx is used as temp variable because it useless in this compution
push bx
xor bx,bx
mov bx,dx
shr bx,4  ;6.25 %
mov DISCOUNT,bx
sub dx,bx
mov FINAL_PRICE,dx
xor bx,bx
mov bx,cx
shr bx,3  ;12.5%
add DISCOUNT,bx
sub cx,bx
add FINAL_PRICE,cx
xor bx,bx
mov bx,ax
shr bx,2  ;25%
add DISCOUNT,bx
sub ax,bx
add FINAL_PRICE,ax
pop bx
add FINAL_PRICE,bx

xor ax,ax
mov ax,FINAL_PRICE
call print
call printNL

push ax
push dx
lea dx, discount_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
xor ax,ax
mov ax,DISCOUNT
call print
call printNL
call printNL
jmp again

e_option:

push ax
push dx
lea dx, msg_e    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL


push ax
push dx
lea dx, final_price_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax


;ALGORITHM
;Sum all the price and store the total into final price variable
;the compute the 12.5% of the total, store into the discount variable
;subtract it to the initial total and print it
add ax,bx
add ax,cx
add ax,dx
mov FINAL_PRICE,ax
shr ax,3  ;12.5%
mov DISCOUNT,ax
sub FINAL_PRICE,ax
xor ax,ax
mov ax,FINAL_PRICE
call print
call printNL


push ax
push dx
lea dx, discount_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
xor ax,ax
mov ax,DISCOUNT
call print
call printNL
call printNL
jmp again


exit:
pop dx
pop cx
pop bx
pop ax
call item
adbe_discount ENDP



;this procedure sort the item from the smallest to greates
bubble_sort PROC
push ax
push bx
push cx
push dx

mov cx,N_BUY
dec cx
nextscan:
  mov bx,cx
  xor si,si
nextcomp:
  mov ax, BUYED[si]
  mov dx, BUYED[si+2]
  cmp ax,dx
  jbe no_swap
  mov BUYED[si],dx
  mov BUYED[si+2],ax
no_swap:
  add si,2
  dec bx
  jnz nextcomp
  loop nextscan
exit:
pop dx
pop cx
pop bx
pop ax
ret
bubble_sort ENDP

;this procedure is used to get input Char from user
;by checking is one the allowed option, if not is refused and
;the user is asked to insert a valid one. Result is stored into a variale OPT
get_option PROC
pusha
start:
mov ah,1
int 21h   ;get the input char
cmp al,'A'
je save_opt
cmp al,'B'
je save_opt
cmp al,'D'
je save_opt
cmp al,'E'
je save_opt
cmp al,'a'
je save_opt
cmp al,'b'
je save_opt
cmp al,'d'
je save_opt
cmp al,'e'
je save_opt
cmp al,'R'
je save_opt
cmp al,'0'
je save_opt
jmp err_int
save_opt:
  mov OPT,al
  call printNL
  popa
  ret
err_int:
call printNL
lea dx, err_char_msg   ;print the  msg
mov ah, 9
int 21h

xor dx,dx
lea dx, type_again_msg   ;print the  msg
mov ah, 9
int 21h

jmp start
get_option ENDP


;this procedure fill the array by taking as counter the number of
;item inserted by the user, and iterating get the input code of the
;item selected extract from the array and put it into the BUYED array
fill_array PROC
push ax
push bx
push cx
push dx

xor cx,cx
xor di,di
mov cx,N_BUY
loopf:
    call input_code
    xor si,si
    mov si,CODE
    shl si,1
    xor ax,ax
    mov ax, OBJ_PRICES[si]
    mov BUYED[di], ax
    add di,2
    dec cx
    jne loopf
exit:
pop dx
pop cx
pop bx
pop ax
ret
fill_array ENDP

;this procedure convert the binary into ascii number and print it
;on the screen
print proc
	push ax
	push bx
	push cx
	push dx

	xor dx, dx
	mov bx, 10
	xor cx, cx

	divisione:
	div bx
	add dl, '0'
	push dx
	cmp ax, 0
	je stampa1
	inc cx
	xor dx, dx
	jmp divisione

	stampa1:
	mov ah, 2
	inc cx
	stampa2:
	pop dx
	int 21h
	dec cx
	jnz stampa2

	pop dx
	pop cx
	pop bx
	pop ax

	ret
	print endp



input_NBUY PROC  ;this procedure return the number inserted by the user and store it into dl
  push ax
  push bx
  push cx
start:
    push ax
    push dx
    lea dx, nitem_msg    ;print the string
    mov ah, 9
    int 21h
    pop dx
    pop ax
    xor dx,dx
num_int:
    mov ah,1
    int 21h         ;get the input char
    cmp al,13       ;if the input number is equal to carriage return proc ends
    je err_int
    cmp al,27
    je err_int
    cmp al, '1'     ;check if the input is between 1 and 4 if not error is arised
    jb err_int
    cmp al,'4'
    ja err_int
    sub al,'0'      ;get the binary rapresentation of the number inserted
    xor ah,ah
    mov N_BUY,ax
    jmp end_int
err_int:
    call printNL
    lea dx, err_int_msg   ;print the  msg
    mov ah, 9
    int 21h
    jmp start
end_int:
  pop cx
  pop bx
  pop ax
  ret
input_NBUY ENDP

input_code PROC  ;this procedure return the number inserted by the user and store it into dl
push ax
push bx
push cx
start:
  push ax
  push dx
  lea dx, itemcode_msg1    ;print the first part of the string
  mov ah, 9
  int 21h
  pop dx
  pop ax

  push ax
  xor ax,ax
  mov ax,N    ;print N on the screen
  call print
  pop ax

  push ax
  push dx
  lea dx, itemcode_msg2    ;print the second part of the screen
  mov ah, 9
  int 21h
  pop dx
  pop ax

  xor dx,dx
num_int:
  mov bx,10
  mov ah,1
  int 21h   ;get the input char
  cmp al,13 ;if the input number is equal to carriage return proc ends
  je end_int
  cmp al,27
  je err_int
  cmp al, '0'     ;check if the input is between 0 and 9 if not error is arised
  jb err_int
  cmp al,'9'
  ja err_int
  sub al,'0'      ;get the binary rapresentation of the number inserted
  xchg ax,bx     ;swapping ax and bx   ax=10 now
  xor bh,bh      ;bh=0
  mul dx        ; dx is multiplied by ax that is 10 and result is stored into ax
  cmp dx,0      ;if dx!=0 result of mul cannot be represented on 16 bits
  jne err_int
  mov dx,ax ;get into dx the result of mul
  add dx,bx ;dx is added with the binary representation of the last char
  cmp dx,N
  ja err_int  ;if dx is greater than 15 error arised
  jmp num_int
err_int:
  call printNL
  lea dx, err_int_msg   ;print the  msg
  mov ah, 9
  int 21h
  jmp start

end_int:
  mov CODE,dx
  pop cx
  pop bx
  pop ax
  ret
input_code ENDP

;this procedure print the new line
printNL PROC
  pusha
  mov dl,0Ah
  mov ah,2
  int 21h
  popa
  ret
printNL ENDP

space PROC
  pusha
  mov dl,' '
  mov ah,2
  int 21h
  popa
  ret
space ENDP


;---------------------------------------------------------------------
;THOSE FOLLOWING PROCEDURE  WERE USED FOR TESTING PURPOSES
printArr PROC


  push ax
  push dx
  lea dx, chosen_item    ;print the second part of the screen
  mov ah, 9
  int 21h
  pop dx
  pop ax

pusha
  mov cx,N_BUY
  xor si,si
loopf:
  xor ax,ax
  mov ax,BUYED[si]
  call print
  call space
  add si,2
  dec cx
  jne loopf
popa
ret
printArr ENDP

printArr1 PROC
pusha
  xor ax,ax
  mov ax,OBJ_PRICES[0]
  call print
  call space
  xor ax,ax
  mov ax,OBJ_PRICES[2]
  call print
  call space
  xor ax,ax
  mov ax,OBJ_PRICES[4]
  call print
  call space
  xor ax,ax
  mov ax,OBJ_PRICES[6]
  call print
  call space

popa
ret
printArr1 ENDP
;---------------------------------------------------------------------


end_p PROC
  call printNL		            ;this procedure prints a new line
  mov ah, 09h		              ;09h is the function of interrupt 21h which prints a string on
  mov dx, offset end_program  ;dx is the pointer to the
  int 21h                     ;here i'm printing the end_item1 message
end_p ENDP



.exit
end

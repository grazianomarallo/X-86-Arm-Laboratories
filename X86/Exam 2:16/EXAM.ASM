;Exercise 15/9/14


.model small
.386  ; enable pusha popa,shr shl
.stack
.data
N EQU 52
DECKS DB 4 * N DUP(?)
tokens DB ?   ;variable to keep track the number of tokens
points DB ?   ;variable to store points
seniority DB ?
OMP db ?
counter DW ?
pick_one db 1
pick_two db 1
pick_three db 1


YES EQU 'y'
NO EQU 'n'
A EQU 'c'
B EQU 'b'
space_string DB "       $"
test_c DB "  ****test****     $"
end_program DB "Bye Bye!", 13, 10, "$"
number_of_tokens DB "Insert the number of tokens: ", "$"
seniority_msg DB "Insert seniority level:   ", "$"
OMP_msg DB "OMP student?:   ", "$"
score_msg DB "Total score for the exam is:   ", "$"
current_score_msg DB "Current score for the exam is:   ", "$"
current_pick DB "You have picked:   ", "$"
remained_token DB "Tokens left:   ", "$"
passed_msg DB "Exam passed", "$"
not_passed_msg DB "Exam not passed", "$"
pick_again DB "Do you want pick again?", "$"
addendum_rule DB "Do you want apply addendum rule?", "$"
extra_rule DB "Do you want apply extra rule?", "$"
super_rule_msg DB "Do you want base points (b) or ceil points (c)?", "$"
super_bonus_msg DB "You have picked three 7, superbonus rules applied. Exam passed with 30 cum laude", "$"
end_item1 DB "Item1 is completed!", 13, 10, "$"
item3_msg DB "Please type the day (a number from 1 to 31):", 13, 10, "$"
end_item2 DB "Item2 is completed!", 13, 10, "$"
end_item3 DB "Item3 is completed!", 13, 10, "$"
err_int_msg DB "  Error.Please type another number:", 13, 10, "$"
menu_msg DB "Welcome student! Type 1 for start your exam 1, type 0 to exit", 13, 10, "$"
error_msg DB "Wrong character!", 13, 10, "$"



.code


.startup
;PROGRAM STARTS
;db initialization
mov DECKS[0], 00000111b   ;7
mov DECKS[1], 00000111b   ;7
mov DECKS[2], 00000111b   ;7
mov DECKS[3], 00000101b   ;5
mov DECKS[4], 00000100b   ;4
mov DECKS[5], 00000001b   ;1
mov DECKS[6], 00001001b   ;9
mov DECKS[7], 00001011b   ;13
mov DECKS[8], 00000011b   ;3


mov ax,3    ;clear the screen befor start
int 10h
xor ax,ax

menu:
lea dx, menu_msg   ;print the string
mov ah, 9
int 21h
mov ah,01H      ;read the character inserted by the user and
int 21h         ;it is stored into al
call printNL
cmp al,'0'
je exit
cmp al,'1'
je item1


error:
lea dx, error_msg   ;print the error msg
mov ah, 9
int 21h
call printNL
jmp menu        ;jump back to menu to allow the user choice

mov counter,0  ;pointer to decks, initialization
item1:
mov di,counter    ;initialization of variable to 0
mov tokens,0
mov points,0
mov seniority,0
mov pick_one,0
mov pick_two,0
mov pick_three,0
push ax
push dx
lea dx,number_of_tokens   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax

call input_token    ;receive the token into al
call printNL

push ax
push dx
lea dx,seniority_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax

call input_seniority    ;receive seniority into al
call printNL



push ax
push dx
lea dx,OMP_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax

call input_OMP    ;OMP variable store the YES or NO
call printNL
call printNL



;algorithm STARTS
xor ax,ax
xor bx,bx
xor cx,cx


mov cl, tokens     ;get the tokens inserted by user into cl in order to use it  (#number of tokens left)
first_card:
add points,6      ;add to the total point the base score
mov al, DECKS[di]   ;get into al the current record
and al, 00001111b   ;get into al the value of the card
mov pick_one,al     ;save the first pick
add points,al       ;add the value of the card into student's point

push ax
push dx
lea dx,current_pick   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call print
call printNL
call printNL
inc di        ;increment the counter
mov counter,di

dec cx              ;decrement the number of tokens left
mov ax,cx
push ax
push dx
lea dx,remained_token   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call print
call printNL
call printNL

cmp cx,0
jne pick_another
jmp terminate



pick_another:
push ax
push dx
lea dx,pick_again   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call printNL


mov ah,1
int 21h   ;get the input char
call printNL
cmp al,YES
je go_on
cmp al,NO
je terminate

go_on:
xor ax,ax
mov al, DECKS[di]
and al,00001111b
cmp cx,2
jb save2                ;save the second and third pick
mov pick_two,al
save2:
mov pick_three,al
add points,al


push ax
push dx
lea dx,current_pick   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call print
call printNL
call printNL
inc di
mov counter,di

push ax
push dx
lea dx,current_score_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
mov al,points
call print
call printNL
call printNL

dec cx              ;decrement the number of tokens left
mov ax,cx
push ax
push dx
lea dx,remained_token   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call print
call printNL
call printNL

cmp cx,0
jne pick_another
jmp terminate

;here the student has terminated with drawing
;as first thing is check if he/she belongs to omp classes
;if so, each pick is compared with 7 if three sequantial 7 are present
;program terminate

terminate:
cmp OMP,YES
je omp_rule
jmp not_omp
omp_rule:
xor ah,ah
mov al, pick_one
cmp al,7
je ok
jmp not_omp
ok:
mov al, pick_two
cmp al,7
je ok1
jmp not_omp
ok1:
mov al, pick_three
cmp al,7
je apply_superbonus
jmp not_omp


apply_superbonus:
push ax
push dx
lea dx,super_bonus_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call printNL
jmp menu


not_omp:      ;if not omp is verified check the seniority level and act as requested
cmp seniority,1
ja addendum_
jmp result

addendum_:
push ax
push dx
lea dx,addendum_rule   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call printNL


mov ah,1
int 21h   ;get the input char
call printNL
cmp al,YES
je apply_addendum
cmp al,NO
je result

error_add:
lea dx, error_msg   ;print the error msg
mov ah, 9
int 21h
call printNL
jmp addendum_        ;jump back to menu to allow the user choice

apply_addendum:
xor ah,ah
mov al, pick_one
call addendum     ;transform the jack, the queen o king into a 10
mov al, pick_two
call addendum
mov al, pick_three
call addendum

push ax
push dx
lea dx,current_score_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
mov al,points
call print
call printNL
call printNL

cmp seniority,2
ja extrarule
jmp result


extrarule:
push ax
push dx
lea dx,extra_rule   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call printNL


mov ah,1
int 21h   ;get the input char
call printNL
cmp al,YES
je apply_extrarule
cmp al,NO
je result

error_extra:
lea dx, error_msg   ;print the error msg
mov ah, 9
int 21h
call printNL
jmp extrarule        ;jump back to menu to allow the user choice


apply_extrarule:
xor ah,ah
mov al, pick_one
call extra    ;transform the ace into a 14
mov al, pick_two
call extra
mov al, pick_three
call extra

push ax
push dx
lea dx,current_score_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
mov al,points
call print
call printNL
call printNL

cmp seniority,3
ja super_rule
jmp result


super_rule:
push ax
push dx
lea dx,super_rule_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call printNL


mov ah,1
int 21h   ;get the input char
call printNL
cmp al,A
je apply_super
cmp al,B
je result

error_super:
lea dx, error_msg   ;print the error msg
mov ah, 9
int 21h
call printNL
jmp super_rule        ;jump back to menu to allow the user choice

apply_super:
mov al,points
sub al,6
mov points,al   ;here we have the actual points
mov al,52
mov ah,points
sub al,ah
mov points,al




result:
push ax
push dx
lea dx,score_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax

mov al, points
xor ah,ah
call print
call printNL

xor ax,ax
mov al,points
cmp al, 18
jb not_passed
cmp al,30
ja not_passed
jmp passed

not_passed:
push ax
push dx
lea dx,not_passed_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call printNL
jmp menu

passed:
push ax
push dx
lea dx,passed_msg   ;print the  msg
mov ah, 9
int 21h
pop dx
pop ax
call printNL
jmp menu



item3:

extra PROC

cmp al,1
je ace
ret
ace:
add points,13
ret
extra ENDP



addendum PROC

cmp al,11
je queen
cmp al,12
je king
ret

queen:
sub points,1
ret
king:
sub points,2
ret
addendum ENDP


input_token PROC
push ax
push bx
push cx
start:
xor dx,dx
num_int:
mov ah,1
int 21h   ;get the input char
cmp al,13 ;if the input number is equal to carriage return proc ends
je end_int
cmp al, '0'     ;check if the input is between 0 and 9 if not error is arised
jb err_int
cmp al,'3'
ja err_int
sub al,'0'  ;get the binary rapresentation of the number inserted
mov tokens,al
jmp end_int

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
input_token ENDP

input_seniority PROC
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
cmp al, '1'     ;check if the input is between 0 and 9 if not error is arised
jb err_int
cmp al,'5'
ja err_int
sub al,'0'  ;get the binary rapresentation of the number inserted
mov seniority,al
jmp end_int

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
input_seniority ENDP

input_OMP PROC
omp_:
mov ah,1
int 21h   ;get the input char
call printNL
cmp al,YES
je yes_lab
cmp al,NO
je no_lab

error_omp:
lea dx, error_msg   ;print the error msg
mov ah, 9
int 21h
call printNL
jmp omp_        ;jump back to menu to allow the user choice

yes_lab:
mov OMP,YES
ret
no_lab:
mov OMP,NO
ret

input_OMP ENDP

  ;this procedure print the new line
  printNL PROC
  pusha
  mov dl,0Ah
  mov ah,2
  int 21h
  popa
  ret
  printNL ENDP

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

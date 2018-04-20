;Exercise 15/9/14


.model small
.386  ; enable pusha popa,shr shl
.stack
.data
N equ 4     ;exact number of professor
SCORES dw N dup(?)
RESULTS db 5*(N+1) dup(?)
Accum_c db ?
Accum_a db ?
Accum_s db ?
Accum_e db ?
Votes_c db ?
Votes_a db ?
Votes_s db ?
Votes_e db ?
ps db ?


end_program DB "Bye Bye!", 13, 10, "$"
statistics DB "Statistics: ", "$"
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
menu_msg DB "Welcome! Type 1 for item1 , type 0 to exit", 13, 10, "$"
error_msg DB "Wrong character!", 13, 10, "$"
invalid_code DB "Invalid code.!", 13, 10, "$"



.code


.startup
;PROGRAM STARTS
;db initialization
;[pppp ccc a][aa sss eee]
mov SCORES[0], 0001101000101100b   ;5 0 5 4    only professor one initialize
mov SCORES[4], 0001110110101110b   ;6 6 5 6
mov SCORES[8], 0001101101100101b   ;5 5 4 5
mov SCORES[12], 0001101000100000b   ;5 0 4 0



;initialize all variables to 0
mov Accum_c,0
mov Accum_a,0
mov Accum_s,0
mov Accum_e,0
mov Votes_c,0
mov Votes_a,0
mov Votes_s,0
mov Votes_e,0

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


item1:
mov cx,N ;counter
xor si,si ;pointer to the array

loop1:
mov ax,SCORES[si]
and ax,1111000000000000b
shr ax,12
cmp ax,0
je invalid
xor ax,ax
mov ax,SCORES[si]
and ax,0000111000000000b
shr ax,9
cmp ax,0
je no_score_c
add Accum_c,al        ;save the value into Accum_c
inc Votes_c
no_score_c:
mov ax,SCORES[si]
and ax,0000000111000000b
shr ax,6
cmp ax,0
je no_score_a
add Accum_a,al
inc Votes_a
no_score_a:
mov ax,SCORES[si]
and ax,0000000000111000b
shr ax,3
cmp ax,0
je no_score_s
add Accum_s,al
inc Votes_s
no_score_s:
mov ax,SCORES[si]
and ax,0000000000000111b
cmp al,0
je no_score_e
add Accum_e,al
inc Votes_e
no_score_e:
add si,4
loop loop1

mov ah,Accum_c
xor al,al
shl ax,3
div Votes_c
call print
call printNL


jmp menu

statistic:
lea dx, statistics   ;print the error msg
mov ah, 9
int 21h
call printNL

mov cx,N
xor di,di ; pointer to iterate array

loop2:
mov ah,Accum_c    ;implent division 16 divided by 8 bit
xor al,al
mov dl,Votes_c
div dl    ;result goes into al
mov RESULTS[di],al
add ps,al
call print

inc di

mov ah,Accum_a    ;implent division 16 divided by 8 bit
xor al,al
mov dl,Votes_a
div dl    ;result goes into al
mov RESULTS[di],al
add ps,al
call print
call printNL
inc di

mov ah,Accum_s    ;implent division 16 divided by 8 bit
xor al,al
mov dl,Votes_s
div dl    ;result goes into al
mov RESULTS[di],al
add ps,al
call print
call printNL
inc di

mov ah,Accum_e    ;implent division 16 divided by 8 bit
xor al,al
mov dl,Votes_e
div dl    ;result goes into al
mov RESULTS[di],al
add ps,al
call print
call printNL
inc di

mov al,ps
shr al,2
mov RESULTS[di],al
call print
call printNL

inc di
loop loop2
jmp menu


invalid:
lea dx, invalid_code   ;print the error msg
mov ah, 9
int 21h
call printNL
jmp menu        ;jump back to menu to allow the user choice




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







exit:
call printNL		;this procedure prints a new line
mov ah, 09h		        ;09h is the function of interrupt 21h which prints a string on
mov dx, offset end_program  ;dx is the pointer to the
int 21h                     ;here i'm printing the end_item1 message

.exit

end

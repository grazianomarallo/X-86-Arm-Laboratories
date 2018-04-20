;Exercise 2/9/13


;ITEM 5 DA IMPLEMENTARE
.model small
.586  ; enable pusha popa,shr shl
.stack
.data

MENU DW total_grand
     DW employee
     DW month_total
	   DW month_and_employer
N_EMPLOYEES EQU 30
N_MAX_WORKING_DAYS_PER_MONTH EQU 23
N_MAX_RECORDS_PER_MONTH EQU N_EMPLOYEES * N_MAX_WORKING_DAYS_PER_MONTH
N_MONTHS EQU 12
N_RECORDS EQU N_MAX_RECORDS_PER_MONTH * N_MONTHS
N_BYTES_PER_RECORD EQU 3
N_BYTES_OF_RECORD EQU N_BYTES_PER_RECORD * N_RECORDS
N EQU 2
CANTEEN_CHARGES_DATABASE DB 11111111b
;CANTEEN_CHARGES_DATABASE DB 11101000b, 10000111b,00010000b, 11101000b,10001011b,00010000b, 11101000b,10000111b,00100000b
GRAND_TOTAL DD ?
TOTAL_SINGLE_EMPLOYER DD ?
BUFFER DB N+1,N+2 DUP (?)
code_employer DB ?
month DB ?
TOTAL_MONTH_AND_EMPLOYER DW ?
TOTAL_MONTH DD ?
CHARGE DW ?		;TEMP DATA
DAY DB ?		;TEMP DATA
EMPL DB ?		;TEMP DATA
MON DB ?		;TEMP DATA
question db "Choose one option: $"
opt1 db "1.Compute the grand total of all charges of the entire year$"
opt2 db "2.Get the total number of charges of one employers in the entire year$"
opt3 db "3.Get the total number of charges in a given month$"
opt4 db "4.Get the total number of charges of one employer in a given month$"
total db "The grand total has been computed, it is: $"
dollars db " Dollars$"
request1 db "Please, give the code of the employer (from 1 to 30): $"
request2 db "Please, give the number of the month: $"
.code


;this procedure is used to print number (also the conversion is done)
print PROC
push ax   ;push all register onto the stack
push bx
push cx
push dx
xor dx,dx   ;set to zero register and set bx=10 in order to compute division by ten
xor cx,cx
mov bx,10
division:
  div bx
  add dl,'0'
  push dx
  cmp ax,0
  je print_1
  inc cx
  xor dx,dx
  jmp division

print_1:
  mov ah,2
  inc cx
print_2:
  pop dx
  int 21h
  dec cx
  jnz print_2

  pop dx
  pop cx
  pop bx
  pop ax

ret
print ENDP

  ;this procedure print the new line
  printNL PROC
  pusha
  mov dl,0Ah
  mov ah,2
  int 21h
  popa
  ret
  printNL ENDP


.startup


mov ax,3    ;clear the screen befor start
int 10h
xor ax,ax

startmenu:

call printNL
push dx
push ax
push di
lea dx, QUESTION   ;print the string
mov ah, 9
int 21h
call printNL
lea dx,opt1
mov ah, 9
int 21h
call printNL
lea dx,opt2
mov ah, 9
int 21h
call printNL
lea dx,opt3
mov ah, 9
int 21h
call printNL
lea dx,opt4
mov ah, 9
int 21h
call printNL
mov ah,1    ;read input from user
int 21h
sub al, '0'   ;store into al the inputted number subtratting zero in order to get the real one
xor ah,ah     ;set to zero ah
mov di, ax
dec di
shl di,1
jmp MENU[di]
pop di
pop ax
pop dx

total_grand:
mov cx, N_RECORDS  ;copy into cx the maximum number of records
xor di,di     ;pointer to db
cycle:
  mov ax, word ptr CANTEEN_CHARGES_DATABASE[di]  ;copy into ax the current record
  and ax,0000001111111111b    ;get into ax the current amount charged
  add word ptr GRAND_TOTAL, ax  ;store the current value into variable GT.
  add di,3 ;mov to the next record
  loop cycle
  call printNL
  push ax
  push dx
  lea dx,total
  mov ah,9
  int 21
;  mov ax, word ptr GRAND_TOTAL+2
;  call print
  mov ax, word ptr GRAND_TOTAL
  call print
  lea dx,dollars
  mov ah,9
  int 21h
  call printNL
  pop ax
  pop dx
  jmp startmenu

employee:
call printNL
lea dx,request1
mov ah,9
int 21h
lea dx,BUFFER
mov ah, 0AH  ;read the buffer where is stored the employee number
int 21h
cmp BUFFER[1],2 ;the second element in the buffer return the number of elements in it
je decimal   ; if true deal with two digits number
mov al, BUFFER[2] ;store into al the only digit inserted by the user
sub al, '0'
mov code_employer,al  ;store the value into a variable
jmp continue
decimal:
  mov al, BUFFER[2] ;here we have two digits
  sub al,'0'
  mov bl,10
  mul bl; ax= 10*al
  mov bl, BUFFER[3]
  sub bl,'0'
  add al,bl ;get the complete code
  mov code_employer,al

continue:
  mov cx,N_RECORDS
  xor di,di
  cycle2:
    mov ax, word ptr CANTEEN_CHARGES_DATABASE[di]
    shr ax,10
    and ax,0000000000011111b; get in ax the employee code
    cmp code_employer,al ;compare the code inserted by the user whit the current one
    jne not_found   ;if is not equal skip this record
    mov ax, word ptr CANTEEN_CHARGES_DATABASE[di]
    and ax, 0000001111111111b; get the account charged
    add word ptr TOTAL_SINGLE_EMPLOYER, ax    ;save into variable
    not_found:
    add di,3 ;increment the pointer to next record
    loop cycle2
    call printNL
    push dx
    push ax
  ;  mov ax, word ptr TOTAL_SINGLE_EMPLOYER+2
  ;  call print
    mov ax, word ptr TOTAL_SINGLE_EMPLOYER
    call print
    lea dx, DOLLARS
    mov ah,9
    int 21h
    pop ax
    pop dx
    jmp startmenu

month_total:
call printNL
lea dx, request2
mov ah,9
int 21h

lea dx, BUFFER
mov ah, 0Ah
int 21h
cmp BUFFER[1],2 ;the second element in the buffer return the number of elements in it
je decimal1   ; if true deal with two digits number
mov al, BUFFER[2] ;store into al the only digit inserted by the user
sub al, '0'
mov month,al  ;store the value into a variable
jmp continue1
decimal1:
  mov al, BUFFER[2] ;here we have two digits
  sub al,'0'
  mov bl,10
  mul bl; ax= 10*al
  mov bl, BUFFER[3]
  sub bl,'0'
  add al,bl ;get the complete code
  mov month,al

continue1:
  mov cx,N_RECORDS
  xor di,di
  cycle3:
    mov ax, word ptr CANTEEN_CHARGES_DATABASE[di]
    shl ax,4 ;get the month
    cmp month, al
    jne not_found1   ;if is not equal skip this record
    mov ax, word ptr CANTEEN_CHARGES_DATABASE[di]
    and ax, 0000001111111111b; get the account charged
    add word ptr TOTAL_MONTH, ax    ;save into variable
    not_found1:
    add di,3 ;increment the pointer to next record
    loop cycle3
    call printNL
    push dx
    push ax
    mov ax, word ptr TOTAL_MONTH+2
    call print
    mov ax, word ptr TOTAL_MONTH
    call print
    lea dx, DOLLARS
    mov ah,9
    int 21h
    pop ax
    pop dx
    jmp startmenu

month_and_employer:
call printNL
lea dx, request1
mov ah,9
int 21h
lea dx,BUFFER
mov ah,0Ah
int 21h
cmp BUFFER[1],2 ;the second element in the buffer return the number of elements in it
je decimal_c   ; if true deal with two digits number
mov al, BUFFER[2] ;store into al the only digit inserted by the user
sub al, '0'
mov code_employer,al  ;store the value into a variable
jmp continue_m
decimal_c:
  mov al, BUFFER[2] ;here we have two digits
  sub al,'0'
  mov bl,10
  mul bl; ax= 10*al
  mov bl, BUFFER[3]
  sub bl,'0'
  add al,bl ;get the complete code
  mov code_employer,al

continue_m:
call printNL
lea dx, request2
mov ah,9
int 21h
lea dx, BUFFER
mov ah, 0Ah
int 21h

cmp BUFFER[1],2 ;the second element in the buffer return the number of elements in it
je decimal_m   ; if true deal with two digits number
mov al, BUFFER[2] ;store into al the only digit inserted by the user
sub al, '0'
mov month,al  ;store the value into a variable
jmp continue3
decimal_m:
  mov al, BUFFER[2] ;here we have two digits
  sub al,'0'
  mov bl,10
  mul bl; ax= 10*al
  mov bl, BUFFER[3]
  sub bl,'0'
  add al,bl ;get the complete code
  mov month,al

  continue3:
  mov cx, N_RECORDS
  xor di,di
  cycle4:
  mov al, CANTEEN_CHARGES_DATABASE[di+2]
  shr al,4 ;get the month
  cmp month,al
  jne not_found2

  mov ax, word ptr CANTEEN_CHARGES_DATABASE[di]
  shr ax,10
  and ax, 0000000000011111b ; extract the employee code
  cmp code_employer, al
  jne not_found
  mov ax, word ptr CANTEEN_CHARGES_DATABASE[di]
  and ax,0000001111111111b
  add word ptr TOTAL_MONTH_AND_EMPLOYER,ax
  not_found2:
  add di,3
  loop cycle4
  call printNL
  push dx
  push ax
  lea dx, TOTAL
  mov ah,9
  int 21H
  mov ax, word ptr TOTAL_MONTH_AND_EMPLOYER
  call print
  lea dx,DOLLARS
  mov ah,9
  int 21h
  pop ax
  pop dx
  jmp startmenu
exit:
  .exit

end

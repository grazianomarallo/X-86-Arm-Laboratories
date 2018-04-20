

.model small
.386
.stack
.data
A_SCHED dw 12 dup(?)
B_SCHED dw 12 dup(?)
A_SCHED_B dw 12 dup(?)
B_SCHED_TP dw 12 dup(?)
H_LEAVE dw ?
A_TO_B  db ?
B_TO_TP db ?
wait_time db ?
first_bus dw ?



error_msg DB "Wrong character!", 13, 10, "$"
menu_msg Db "Welcome. Type 1,type 0 for exit!",13,10,"$"
welcome_msg Db "Welcome. Prior starting insert the following data in order to perform computation! ",13,10,"$"
hour_msg Db "Insert hour of the day (0-23): ",13,10,"$"
minute_msg Db "Insert minute of the day (0-59): ",13,10,"$"
no_solution db "No valid solution found!",13,10,"$"
end_program Db "Program terminated ",13,10,"$"
err_int_msg DB "The number typed is greater than the maximum allowed or is a forbidden char. Please type another number:", 13, 10, "$"
err_sign_msg DB "Wrong char, plese insert + or -:", 13, 10, "$"
date_msg DB "Date: $", 0
h_msg DB "Hour: $", 0



.code


.startup
;PROGRAM STARTS






mov A_TO_B, 16
mov B_TO_TP,29


call initialize_array



mov ax,3    ;clear the screen befor start
int 10h
xor ax,ax

push ax
push dx
lea dx, welcome_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

push ax
push dx
lea dx, hour_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL


call input_hour   ;dl store the input number
xor bx,bx
mov bh,dl

push ax
push dx
lea dx, minute_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL

call input_minute
mov bl,dl


mov H_LEAVE,bx    ;store into H_LEAVE the time inserted by the user
call printNL
call compute_travel_a
call printNL
call compute_travel_b
call printNL


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

item1 PROC
call swap_point
jmp menu
ret
item1 ENDP

swap_point PROC
xor si,si
mov cx,12
xor ax,ax
mov bx,H_LEAVE


loop2:
mov ax,A_SCHED[si]
cmp bx, ax
jle smaller
jg greater
jmp no_valid_solution


smaller:
mov dx, A_SCHED_B[si]
call print
;print dx arrival time at swap point
jmp exit

greater:
inc si
dec cx
cmp cx,0
jne loop2
jmp no_valid_solution


no_valid_solution:
push ax
push dx
lea dx, no_solution    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
ret

exit:

ret
swap_point ENDP


office PROC
xor si,si
mov cx,12
xor ax,ax
mov bx,dx


loop2:
mov ax,A_SCHED[si]
cmp bx, ax
jle smaller
jg greater
jmp no_valid_solution


smaller:
mov dx, A_SCHED_B[si]
call print
;print dx arrival time at swap point
jmp exit

greater:
inc si
dec cx
cmp cx,0
jne loop2
jmp no_valid_solution


no_valid_solution:
push ax
push dx
lea dx, no_solution    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
ret

exit:

ret

office ENDP

















compute_travel_a PROC
xor si,si
xor cx,cx
mov cx,12
xor ax,ax
xor bx,bx
loop1:
mov ax,A_SCHED[si]
and al,00111111b      ;get minute
and ah,00011111b      ;get hour
mov bl,A_TO_B

add al,bl
cmp al,60
jb no_hour
sub al,60
add ah,1

no_hour:
mov A_SCHED_B[si],ax
call print_hour
dec cx
inc si
;inc si
cmp cx,0
jne loop1
ret
compute_travel_a  ENDP

compute_travel_b PROC
xor si,si
xor cx,cx
mov cx,12
xor ax,ax
xor bx,bx
loop1:
mov ax,B_SCHED[si]
and al,00111111b      ;get minute
and ah,00011111b      ;get hour
mov bl,B_TO_TP

add al,bl
cmp al,60
jb no_hour
sub al,60
add ah,1

no_hour:
mov B_SCHED_TP[si],ax
call print_hour
dec cx
inc si
;inc si
cmp cx,0
jne loop1
ret
compute_travel_b  ENDP

print_hour PROC
push ax
xor al,al
mov al,ah
xor ah,ah
call print
pop ax

pusha
mov dl,':'
mov ah,2
int 21h
popa

xor ah,ah
call print
call space
ret
print_hour ENDP








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





    ;Take the row as parameter and iterating print each Character on the screen
    printString PROC
    pusha
    mov si,ax
    xor cx,cx
    cycle:
      mov al,[si]       ;store into al the current char stored into si
      mov dl,al         ;print the char
      mov ah,2
      int 21h
      inc si
      mov cl,[si]
      cmp cl,0h
      jne cycle
      popa
    ret
    printString ENDP








    input_hour PROC  ;this procedure return the number inserted by the user and store it into dl
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
    cmp dx,23
    ja err_int  ;if dx is greater than 15 error arised
    jmp num_int

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
    input_hour ENDP

    input_minute PROC  ;this procedure return the number inserted by the user and store it into dl
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
    cmp dx,59
    ja err_int  ;if dx is greater than 15 error arised
    jmp num_int

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
    input_minute ENDP






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

    initialize_array PROC
    xor ax,ax
    mov al,10  ;set minute
    mov ah,8    ;set hour
    mov A_SCHED[0],ax    ;store the complete data into array

    mov al,0  ;set minute
    mov ah,9    ;set hour
    mov A_SCHED[2],ax    ;store the complete data into array

    mov al,45  ;set minute
    mov ah,9   ;set hour
    mov A_SCHED[4],ax    ;store the complete data into array

    mov al,30  ;set minute
    mov ah,10    ;set hour
    mov A_SCHED[6],ax    ;store the complete data into array

    mov al,30  ;set minute
    mov ah,11   ;set hour
    mov A_SCHED[8],ax    ;store the complete data into array

    mov al,30  ;set minute
    mov ah,12    ;set hour
    mov A_SCHED[10],ax    ;store the complete data into array

    mov al,15  ;set minute
    mov ah,13    ;set hour
    mov A_SCHED[12],ax    ;store the complete data into array

    mov al,0  ;set minute
    mov ah,14    ;set hour
    mov A_SCHED[14],ax    ;store the complete data into array

    mov al,0  ;set minute
    mov ah,15    ;set hour
    mov A_SCHED[16],ax    ;store the complete data into array

    mov al,0  ;set minute
    mov ah,16    ;set hour
    mov A_SCHED[18],ax    ;store the complete data into array

    mov al,0  ;set minute
    mov ah,17    ;set hour
    mov A_SCHED[20],ax    ;store the complete data into array

    mov al,0  ;set minute
    mov ah,18    ;set hour
    mov A_SCHED[22],ax    ;store the complete data into array


    xor ax,ax
    mov al,10  ;set minute
    mov ah,7    ;set hour
    mov B_SCHED[0],ax    ;store the complete data into array

    mov al,15  ;set minute
    mov ah,8    ;set hour
    mov B_SCHED[2],ax    ;store the complete data into array

    mov al,5  ;set minute
    mov ah,9   ;set hour
    mov B_SCHED[4],ax    ;store the complete data into array

    mov al,40  ;set minute
    mov ah,10    ;set hour
    mov B_SCHED[6],ax    ;store the complete data into array

    mov al,0  ;set minute
    mov ah,11   ;set hour
    mov B_SCHED[8],ax    ;store the complete data into array

    mov al,0  ;set minute
    mov ah,14    ;set hour
    mov B_SCHED[10],ax    ;store the complete data into array

    mov al,30  ;set minute
    mov ah,14    ;set hour
    mov B_SCHED[12],ax    ;store the complete data into array

    mov al,0  ;set minute
    mov ah,15    ;set hour
    mov B_SCHED[14],ax    ;store the complete data into array

    mov al,30  ;set minute
    mov ah,15    ;set hour
    mov B_SCHED[16],ax    ;store the complete data into array

    mov al,15  ;set minute
    mov ah,16    ;set hour
    mov B_SCHED[18],ax    ;store the complete data into array

    mov al,45  ;set minute
    mov ah,16    ;set hour
    mov B_SCHED[20],ax    ;store the complete data into array

    mov al,15  ;set minute
    mov ah,17    ;set hour
    mov B_SCHED[22],ax    ;store the complete data into array
    ret
    initialize_array ENDP


exit PROC
call printNL		;this procedure prints a new line
mov ah, 09h		        ;09h is the function of interrupt 21h which prints a string on
mov dx, offset end_program  ;dx is the pointer to the
int 21h                     ;here i'm printing the end_item1 message
exit ENDP
.exit

end

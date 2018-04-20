

.model medium
.386  ; enable pusha popa,shr shl
.stack
.data
daylight DW 4 dup(?)
day db ?
hour db ?
month db ?
city db 32 dup(?)
remote_city db 32 dup(?)
bufferSize equ 31   ; 50 char + return      ;this two variable are used to read input string
buffer db 32,?,32 dup(?)
timerange db ?
remote_timerange db ?
timezone db ?
remote_timezone db ?
sign db ?
dst db 0
neg1 db ?
neg2 db ?



error_msg DB "Wrong character!", 13, 10, "$"
menu_msg Db "Welcome. Type 1,type 0 for exit!",13,10,"$"
welcome_msg Db "Welcome. Prior starting insert the following data in order to perform computation! ",13,10,"$"
day_msg Db "Insert day of month(1-31): ",13,10,"$"
month_msg Db "Insert month (1-12): ",13,10,"$"
hour_msg Db "Insert hour of the day (1-24): ",13,10,"$"
city_msg Db "Insert the name of the city (at least 5 char): ",13,10,"$"
remote_city_msg Db "Insert the name of the remote city (at least 5 char): ",13,10,"$"
stringerr Db "Name to small, type again!",13,10,"$"
timezone_msg Db "Insert time zone S for south ,N for North: ",13,10,"$"
dst_msg Db "Insert DST : B for begin ,E for end: ",13,10,"$"
timerange_msg Db "Insert time range  (-11/+11): ",13,10,"$"
end_program Db "Program terminated ",13,10,"$"
err_int_msg DB "The number typed is greater than the maximum allowed or is a forbidden char. Please type another number:", 13, 10, "$"
err_sign_msg DB "Wrong char, plese insert + or -:", 13, 10, "$"
date_msg DB "Date: $", 0
h_msg DB "Hour: $", 0



.code


.startup
;PROGRAM STARTS
;db initialization

;[HCmmmmdd][dddhhhhh]

;need to fill the next six cells
mov ax,2  ;set hour         ;26 march 2 hour N beginning dst
mov bx,26 ;set day
shl bx,5        ;get [xxxxxx11][11100000]
or ax,bx        ; perform the or in order to get xxxxxxdddddhhhhh
mov bx,3    ; set the month
shl bx,10   ;shift of 10 to get the month in the right position  xxmmmmdddddhhhhh
or ax,bx
mov bx,0    ;set DST begin
shl bx,14
or ax,bx
mov bx,0    ;set North Hemisphere
shl bx,15
or ax,bx
mov daylight[0],ax    ;store the complete data into array


mov ax,2  ;set hour         ;29 october 2 hour N end dst
mov bx,29 ;set day
shl bx,5        ;get [xxxxxx11][11100000]
or ax,bx        ; perform the or in order to get xxxxxxdddddhhhhh
mov bx,10    ; set the month
shl bx,10   ;shift of 10 to get the month in the right position  xxmmmmdddddhhhhh
or ax,bx
mov bx,1    ;set DST begin
shl bx,14
or ax,bx
mov bx,0    ;set North Hemisphere
shl bx,15
or ax,bx
mov daylight[2],ax    ;store the complete data into array


mov ax,2  ;set hour         ;2 april 2 hour S beginning dst
mov bx,2 ;set day
shl bx,5        ;get [xxxxxx11][11100000]
or ax,bx        ; perform the or in order to get xxxxxxdddddhhhhh
mov bx,5    ; set the month
shl bx,10   ;shift of 10 to get the month in the right position  xxmmmmdddddhhhhh
or ax,bx
mov bx,0    ;set DST begin
shl bx,14
or ax,bx
mov bx,1    ;set South Hemisphere
shl bx,15
or ax,bx
mov daylight[4],ax    ;store the complete data into array


mov ax,2  ;set hour         ;26 march 2 hour S end dst
mov bx,1 ;set day
shl bx,5        ;get [xxxxxx11][11100000]
or ax,bx        ; perform the or in order to get xxxxxxdddddhhhhh
mov bx,10    ; set the month
shl bx,10   ;shift of 10 to get the month in the right position  xxmmmmdddddhhhhh
or ax,bx
mov bx,1    ;set DST end
shl bx,14
or ax,bx
mov bx,1    ;set South Hemisphere
shl bx,15
or ax,bx
mov daylight[6],ax    ;store the complete data into array








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





item1 PROC
;in this item is requested just to compute the date and hour at location inserted
pusha

mov ax,3    ;clear the screen befor start
int 10h
xor ax,ax

mov al,2
mov ah,4
sub al,ah
neg al
xor ah,ah
call print


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
lea dx, day_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call input_day
mov day,dl    ;save the input day into a variable
call printNL

push ax
push dx
lea dx, month_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call input_month
mov month,dl    ;save input month into variable
call printNL


push ax
push dx
lea dx, hour_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call input_hour
mov hour, dl    ;save input hour into variable
call printNL


push ax
push dx
lea dx, city_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
lea ax,city     ;load into ax the address of variable city in order to pass it as parameter to the procedure
call readString
call printNL



push ax
push dx
lea dx, timezone_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call input_timezone
call printNL


push ax
push dx
lea dx, timerange_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call input_timerange
mov timerange, dl    ;save input timezone into variable
cmp sign,'-'
je negate
jmp continue1
negate:
mov neg1,'-'
continue1:
call printNL


push ax
push dx
lea dx, dst_msg  ;print the  msg
mov ah, 9
int 21h
push dx
push ax
call input_dst

call printNL

push ax
push dx
lea dx, remote_city_msg  ;print the  msg
mov ah, 9
int 21h
push dx
push ax
lea ax,remote_city
call readString
lea ax,remote_city
call printString
call printNL

push ax
push dx
lea dx, timezone_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call input_timezone
call printNL


push ax
push dx
lea dx, timerange_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call input_timerange
mov remote_timerange, dl    ;save input timezone into variable
cmp sign,'-'
je negate1
jmp continue2
negate1:
mov neg2,'-'
continue2:
call printNL


push ax
lea ax, remote_city
call printString
call printNL
pop ax



xor ax,ax
xor bx,bx
xor cx,cx
mov al, timerange           ;get the two timerange
mov bl,remote_timerange
cmp neg1,'-'
je neg_pos
cmp neg2,'-'
je pos_neg
jmp both_positive
both_positive:
sub hour,al
add hour,bl   ;in case the two time range are both positive sum
cmp hour,24
ja add_day
jmp go_on
add_day:
inc day
sub hour,24
jmp go_on
pos_neg:
sub hour,al
sub hour,bl
mov cl,hour
and cl,10000000b
cmp cl,10000000b
je neg_
jmp go_on
neg_:
neg hour
xor ch,ch
mov cl,24
sub cl,hour
mov hour,cl
dec day
jmp go_on
neg_pos:
cmp neg2,'-'
je neg_neg
add hour,al
add hour,bl
cmp hour,24
je add_day
jmp go_on
neg_neg:
add hour,al
sub hour,bl
cmp hour,24
ja sub_day
jmp go_on
sub_day:
sub hour,24
dec day
jmp go_on

go_on:


push ax
push dx
lea dx, date_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
xor ah,ah
mov al,day
call print

pusha
mov dl,'/'
mov ah,2
int 21h
popa
xor ah,ah
mov al,month
call print
call space

push ax
push dx
lea dx, h_msg    ;print the string
mov ah, 9
int 21h
pop dx
pop ax
xor ah,ah
mov al,hour
call print
call printNL



popa
jmp menu
ret
item1 ENDP




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




    ;This procedure allow to read the input string from user
    ;and store into the address of the row passed as parameter
    readString PROC
    push ax                       ;store into the stack the value of ax passed as parameter in order to do no waste it
    startRead:
    mov dx, offset buffer	        ;store the buffer into dx
    mov byte ptr [buffer],51
    mov ah,0Ah                    ;GetLine function
    int 21h


    mov dl,buffer[1]
    cmp dl,5                  ;verify if the input string is greater or equal to 20 if not
    jge endRead                 ;print error message and give the chance to do it again until is a valid one

    push ax
    push dx
    lea dx, stringerr    ;print the string
    mov ah, 9
    int 21h
    pop dx
    pop ax
    call printNL
    jmp startRead


    endRead:
    lea dx, buffer               ;load into dx the address of buffer in order to access it later
    xor bx,bx
    mov bl, buffer[1]            ;bl store the number of char inserted by the user
    inc bl
    mov buffer[bx+2], 13         ;store in the last position of the array the 'new carriage'

    pop ax
    mov si,ax                    ;move the address of array into si
    xor di,di
    xor ch,ch
    cycle:                      ;store char by char into the array
        mov cl,buffer[di+2]
        mov [si],cl
        inc si
        inc di
        dec bl
        cmp bl,0
        jne cycle
    ret
    readString ENDP

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






    input_day PROC  ;this procedure return the number inserted by the user and store it into dl
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
    input_day ENDP

    input_month PROC  ;this procedure return the number inserted by the user and store it into dl
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
    cmp dx,12
    ja err_int  ;if dx is greater than 12 error arised
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
    input_month ENDP

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
    cmp dx,24
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


    input_timerange PROC  ;this procedure return the number inserted by the user and store it into dl
    push ax
    push bx
    push cx

    check_sign:
    mov ah,1
    int 21h   ;read + or minus
    cmp al,'+'
    je start
    cmp al,'-'
    je negative
    jmp err_sign

    negative:
    mov sign,'-'


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
    cmp dx,11
    ja err_int  ;if dx is greater than 15 error arised
    jmp num_int

    err_int:
    call printNL
    lea dx, err_int_msg   ;print the  msg
    mov ah, 9
    int 21h
    jmp start

    err_sign:
    call printNL
    lea dx, err_sign_msg   ;print the  msg
    mov ah, 9
    int 21h
    jmp check_sign

    end_int:

    xor dh,dh
    pop cx
    pop bx
    pop ax
    ret
    input_timerange ENDP

    input_timezone PROC
    pusha
    read_timezone:
    mov ah,1
    int 21h   ;read time range
    cmp al,'S'
    je south
    cmp al,'N'
    je north
    jmp err_type



    err_type:
    call printNL
    lea dx, error_msg   ;print the  msg
    mov ah, 9
    int 21h
    jmp read_timezone


    south:
    mov timezone,1
    jmp ok
    north:
    mov timezone,0

    ok:
    popa
    ret
    input_timezone ENDP

    input_remote_timezone PROC
    pusha
    read_timezone:
    mov ah,1
    int 21h   ;read time range
    cmp al,'S'
    je south
    cmp al,'N'
    je north
    jmp err_type



    err_type:
    call printNL
    lea dx, error_msg   ;print the  msg
    mov ah, 9
    int 21h
    jmp read_timezone


    south:
    mov remote_timezone,1
    jmp ok
    north:
    mov remote_timezone,0

    ok:
    popa
    ret
    input_remote_timezone ENDP


    input_dst PROC
    pusha

    read_dst:
    mov ah,1
    int 21h   ;read time range
    cmp al,'B'
    je ok
    cmp al,'E'
    je dst_end
    jmp err_type


    err_type:
    call printNL
    lea dx, error_msg  ;print the  msg
    mov ah, 9
    int 21h
    jmp read_dst

    dst_end:
    mov dst,1

    ok:
    popa
    ret
    input_dst ENDP

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



exit PROC
call printNL		;this procedure prints a new line
mov ah, 09h		        ;09h is the function of interrupt 21h which prints a string on
mov dx, offset end_program  ;dx is the pointer to the
int 21h                     ;here i'm printing the end_item1 message
exit ENDP
.exit

end

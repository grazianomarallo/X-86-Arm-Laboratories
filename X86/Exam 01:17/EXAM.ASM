

.model small
.386  ; enable pusha popa,shr shl
.stack
.data
citations dw 51 dup(?)
max_citations dw 51 dup(?)
current_hindex db 1 dup(?)
index db 1 dup(?)
num_papers db 1 dup(?)
n db ?
m equ 2
counter_papers db 1 dup(?)
sco dw ?
wos dw ?
tot dw ?
year db ?
BUFFER DB m+1,m+2 DUP (?)
input_year db ?
y_sco dw ?

error_msg DB "Wrong character!", 13, 10, "$"
invalid_code DB "Invalid code.!", 13, 10, "$"
menu_msg Db "Welcome. Type 1,2,3,5 for corresponding item, b for bonus item (call first item5 to fill array), 0 for exit!",13,10,"$"
totals Db "Total Sco is: ",13,10,"$"
totalw Db "Total WoS is: ",13,10,"$"
avgs Db "Avg number for Sco is: ",13,10,"$"
avgw Db "Avg number for WoS is: ",13,10,"$"
hindexs Db "H-index for Sco is: ",13,10,"$"
hindexw Db "H-index for Wos is: ",13,10,"$"
hindexws Db "H-index for max(Wos,Sco) is: ",13,10,"$"
bonus_msg Db "Value obtained by adding up max(Wos,Sco) is: ",13,10,"$"
year_avg   Db "Average number of Sco for input year is: ",13,10,"$"
string1 byte "H-index: ", 0
string2 byte "Paper ", 0
string3 byte "(WoS),  ", 0
string4 byte "(Sco)", 0
string5 byte " max(Wos,Sco)", 0
end_program Db "Program terminated ",13,10,"$"
err_int_msg DB "The number typed is greater than 15 or the characters typed are not numbers. Please type another number:", 13, 10, "$"


.code


.startup
;PROGRAM STARTS
;db initialization
mov citations[0],6    ;6 papers are stored into citations

;need to fill the next six cells
mov ax,3  ;set Sco
mov bx,4 ;set WoS
shl bx,6        ;get xxxx111111000000
or ax,bx        ; perform the or in order to get xxxxwwwwwwssssss
mov bx,2    ; set the year    200
shl bx,12   ;shift of 12 to get the year in the right position
or ax,bx    ; now ax store the complete data  in this case is 0001000100000011
mov citations[2],ax


mov ax,4  ;set Sco
mov bx,2 ;set WoS
shl bx,6        ;get xxxx111111000000
or ax,bx        ; perform the or in order to get xxxxwwwwwwssssss
mov bx,2    ; set the year  200
shl bx,12   ;shift of 12 to get the year in the right position
or ax,bx    ; now ax store the complete data
mov citations[4],ax

mov ax,0  ;set Sco
mov bx,5 ;set WoS
shl bx,6        ;get xxxx111111000000
or ax,bx        ; perform the or in order to get xxxxwwwwwwssssss
mov bx,2    ; set the year
shl bx,12   ;shift of 12 to get the year in the right position
or ax,bx    ; now ax store the complete data
mov citations[6],ax

mov ax,6  ;set Sco
mov bx,0 ;set WoS
shl bx,6        ;get xxxx111111000000
or ax,bx        ; perform the or in order to get xxxxwwwwwwssssss
mov bx,4    ; set the year
shl bx,12   ;shift of 12 to get the year in the right position
or ax,bx    ; now ax store the complete data
mov citations[8],ax

mov ax,1  ;set Sco
mov bx,1 ;set WoS
shl bx,6        ;get xxxx111111000000
or ax,bx        ; perform the or in order to get xxxxwwwwwwssssss
mov bx,6    ; set the year
shl bx,12   ;shift of 12 to get the year in the right position
or ax,bx    ; now ax store the complete data
mov citations[10],ax

mov ax,0  ;set Sco
mov bx,0 ;set WoS
shl bx,6        ;get xxxx111111000000
or ax,bx        ; perform the or in order to get xxxxwwwwwwssssss
mov bx,7    ; set the year
shl bx,12   ;shift of 12 to get the year in the right position
or ax,bx    ; now ax store the complete data
mov citations[12],ax


mov ax,3    ;clear the screen befor start
int 10h
xor ax,ax


mov dx, offset citations
call print_citations


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
cmp al,'2'
je item2
cmp al,'3'
je item3
cmp al,'5'
je item5
cmp al,'b'
je bonus
cmp al,'6'
je additional1


error:
lea dx, error_msg   ;print the error msg
mov ah, 9
int 21h
call printNL
jmp menu        ;jump back to menu to allow the user choice

item_1:
call item_1



item1 PROC
mov sco,0
mov wos,0
mov cx,citations[0]
xor si,si  ;counter set to 1

loop1:
xor ax,ax
mov ax,citations[si+2]
and al, 00111111b   ;get Sco
xor ah,ah
add sco,ax
xor ax,ax
mov ax,citations[si+2]
and ax, 0000111111000000b ;get Wos
shr ax,6
xor ah,ah
add wos,ax
add si,2
loop loop1

push ax
push dx
lea dx, totals   ;print the string
mov ah, 9
int 21h
pop dx
pop ax


mov ax,sco
call print
call printNL

push ax
push dx
lea dx, avgs   ;print the string
mov ah, 9
int 21h
pop dx
pop ax

xor ax,ax
xor bx,bx
mov ax,sco
mov bh,6
div bh
xor ah,ah
call print
call printNL

push ax
push dx
lea dx, totalw   ;print the string
mov ah, 9
int 21h
pop dx
pop ax

xor ax,ax
mov ax,wos
call print
call printNL

push ax
push dx
lea dx, avgw   ;print the string
mov ah, 9
int 21h
pop dx
pop ax

xor ax,ax
xor bx,bx
mov ax,wos
mov bh,6
div bh
xor ah,ah
call print
call printNL
jmp menu
ret
item1 ENDP


item2 PROC

push ax
push dx
lea dx, hindexs   ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL
call compute_index_item2
xor ax,ax
mov al, index
call print
call printNL

jmp menu
ret
item2 ENDP

item3 PROC
push ax
push dx
lea dx, hindexw   ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL
call compute_index_item3
xor ax,ax
mov al, index
call print
call printNL

jmp menu
ret
item3 ENDP

item5 PROC
push ax
push dx
lea dx, hindexws   ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL
call compute_index_item5
xor ax,ax
mov al, index
call print
call printNL

jmp menu
ret
item5 ENDP


bonus PROC

pusha
mov dx, offset max_citations
call print_max_citations


mov cx,max_citations[0]
xor si,si  ;counter set to 1
mov tot, 0
loop2:
xor ax,ax
mov ax,max_citations[si+2]
add tot,ax
add si,2
loop loop2

push ax
push dx
lea dx, bonus_msg   ;print the string
mov ah, 9
int 21h
pop dx
pop ax


mov ax,tot
xor ah,ah
call print
call printNL
popa
jmp menu
ret
bonus ENDP


additional1 PROC
mov year,15     ;set year to 15->2015


call input      ;this procedure return the number inserted by the user and store it into dl

mov input_year,dl
mov al,input_year
sub year,al
xor ah,ah
mov al,year
call print
call printNL
call printNL
xor cx,cx
  mov ax,citations[0]
  mov n,al
  mov di,2
loop_a:
  mov ax, citations[di]
  and ah, 11110000b
  shr ah,4
  mov al,ah
  xor ah,ah
  cmp year , al
  je get_Sco
  jmp next_r

  get_Sco:
  mov ax,citations[di]
  and al,00111111b
  xor ah,ah
  add y_sco, ax

  add di,2
  inc cx
  dec n
  cmp n,0
  je finish
  jmp loop_a

  next_r:
  add di,2
  dec n
  cmp n,0
  je finish
  jmp loop_a

finish:

push ax
push dx
lea dx, year_avg   ;print the string
mov ah, 9
int 21h
pop dx
pop ax
call printNL



xor ax,ax
xor bx,bx
mov ax,y_sco
mov bh,cl
div bh
xor ah,ah
call print
call printNL
jmp menu
ret

additional1 ENDP


compute_index_item2 PROC
mov current_hindex,0  ;set the initial current_hindex to 0
mov ax,citations[0]     ;get the number of papers
mov n,al            ;counter for external loop
loop_esterno:
mov counter_papers,0    ;set counter for paper to 0 each time the extern loop is called
inc current_hindex
mov ax,citations[0]     ;get the number of papers
mov num_papers,al       ;save the numner of papers into two variable
mov di,2                ;set the pointer to first element
dec n
cmp n,0
je return

loop_interno:
mov ax,citations[di]    ;get the current valuo of sco
and al,00111111b
cmp current_hindex,al   ;compare the current value of hindex with the current sco
ja update               ;if the value of index is greater the value is updated
jbe check             ;if the valu is smaller or equal is checked


check:
inc di
inc di
inc counter_papers
xor bx,bx
mov bl,counter_papers
cmp bl,current_hindex
je save_index
dec num_papers
cmp num_papers,0
jne loop_interno
jmp loop_esterno

update:   ;se il valore di h index è minore del primo valore delle citazioni h index è quel valore e riparto
mov current_hindex,al
mov index,al
mov di,2
jmp loop_interno

save_index:
mov bh,current_hindex
mov index, bh
jmp loop_esterno


return:
ret
compute_index_item2 ENDP


compute_index_item3 PROC
mov current_hindex,0  ;set the initial current_hindex to 0
mov ax,citations[0]     ;get the number of papers
mov n,al            ;counter for external loop
loop_esterno:
mov counter_papers,0    ;set counter for paper to 0 each time the extern loop is called
inc current_hindex
mov ax,citations[0]     ;get the number of papers
mov num_papers,al       ;save the numner of papers into two variable
mov di,2                ;set the pointer to first element
dec n
cmp n,0
je return

loop_interno:
mov ax,citations[di]    ;get the current valuo of sco
and ax, 0000111111000000b
shr ax,6
xor ah,ah
cmp current_hindex,al   ;compare the current value of hindex with the current sco
ja update               ;if the value of index is greater the value is updated
jbe check             ;if the valu is smaller or equal is checked


check:
inc di
inc di
inc counter_papers
xor bx,bx
mov bl,counter_papers
cmp bl,current_hindex
je save_index
dec num_papers
cmp num_papers,0
jne loop_interno
jmp loop_esterno

update:   ;se il valore di h index è minore del primo valore delle citazioni h index è quel valore e riparto
mov current_hindex,al
mov index,al
mov di,2
jmp loop_interno

save_index:
mov bh,current_hindex
mov index, bh
jmp loop_esterno


return:
ret
compute_index_item3 ENDP


;ITEM 4 is the 2 and 3 so not implemented to avoid repetion


compute_index_item5 PROC
call findMax
mov current_hindex,0  ;set the initial current_hindex to 0
mov ax,max_citations[0]     ;get the number of papers
mov n,al            ;counter for external loop
loop_esterno:
mov counter_papers,0    ;set counter for paper to 0 each time the extern loop is called
inc current_hindex
mov ax,max_citations[0]     ;get the number of papers
mov num_papers,al       ;save the numner of papers into two variable
mov di,2                ;set the pointer to first element
dec n
cmp n,0
je return

loop_interno:
mov ax,max_citations[di]    ;get the current valuo of sco
xor ah,ah
cmp current_hindex,al   ;compare the current value of hindex with the current sco
ja update               ;if the value of index is greater the value is updated
jbe check             ;if the valu is smaller or equal is checked


check:
inc di
inc di
inc counter_papers
xor bx,bx
mov bl,counter_papers
cmp bl,current_hindex
je save_index
dec num_papers
cmp num_papers,0
jne loop_interno
jmp loop_esterno

update:   ;se il valore di h index è minore del primo valore delle citazioni h index è quel valore e riparto
mov current_hindex,al
mov index,al
mov di,2
jmp loop_interno

save_index:
mov bh,current_hindex
mov index, bh
jmp loop_esterno


return:
ret
compute_index_item5 ENDP



findMax PROC
pusha
mov si,0
mov di,0
mov cx, citations[si]
mov num_papers,cl
mov max_citations[di],cx
loopf:
  add si,2
  add di,2
  mov ax,citations[si]
  and al,00111111b
  mov bx,citations[si]
  and bx,0000111111000000b
  shr bx,6
  dec cx
  cmp al,bl
  jae max_al
  jb max_bl
  max_al:
  mov max_citations[di],ax
  cmp cx,0
  jne loopf
  jmp exit_loopf
  max_bl:
  mov max_citations[di],bx
  cmp cx,0
  jne loopf
  exit_loopf:
  popa
  ret
findMax ENDP

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


    print_citations		proc
    					pusha
    					mov di, dx
    					mov dx, word ptr[di] 	;Dx = num of papers
    					shl dx, 1
    					mov si, 2				;counter for citations array
    		loop_p:		cmp si, dx
    					jnbe exit_loopp
    					push dx
    					mov ah,40h
    					mov bx,1
    					mov cx, sizeof string2
    					mov dx, offset string2
    					int 21h				;print string2
    					mov ah,2
    					mov dx, si
    					shr dx, 1
    					add dl, 30h	    	;convert to ascii
    					int 21h				;print number of the current paper
    					mov ah,2
    					mov dl, ':'
    					int 21h
    					mov ah,2
    					mov dl, ' '
    					int 21h

    					push si
    					add si, di
    					mov ax, word ptr[si]
    					pop si
    					mov cl, al
    					and cl, 00111111b		;Cl = Sco
    					shl ax, 2
    					and ah, 00111111b		;Ah = WoS

    					mov dl, ah
    					add dl, 30h	    	;convert to ascii
    					mov ah,2
    					int 21h				;print WoS
    					push cx
    					mov ah,40h
    					mov bx,1
    					mov cx, sizeof string3
    					mov dx, offset string3
    					int 21h				;print string3
    					pop cx

    					mov dl, cl
    					add dl, 30h	    	;convert to ascii
    					mov ah,2
    					int 21h				;print Sco
    					mov ah,40h
    					mov bx,1
    					mov cx, sizeof string4
    					mov dx, offset string4
    					int 21h				;print string4
    					mov ah,2
    					mov dl, 0ah			;print '\n'
    					int 21h

    					pop dx
    					inc si
    					inc si
    					jmp loop_p

    		exit_loopp: mov ah,2
    					mov dl, 0ah			;print '\n'
    					int 21h
    					popa
    					ret
    print_citations		endp

    print_max_citations		proc
    pusha
    mov di, dx
    mov dx, word ptr[di] 	;Dx = num of papers
    shl dx, 1
    mov si, 2				;counter for citations array
loop_p:		cmp si, dx
    jnbe exit_loopp
    push dx
    mov ah,40h
    mov bx,1
    mov cx, sizeof string2
    mov dx, offset string2
    int 21h				;print string2
    mov ah,2
    mov dx, si
    shr dx, 1
    add dl, 30h	    	;convert to ascii
    int 21h				;print number of the current paper
    mov ah,2
    mov dl, ':'
    int 21h
    mov ah,2
    mov dl, ' '
    int 21h

    push si
    add si, di
    mov ax, word ptr[si]
    pop si
    xor ah,ah
    mov ah,al

    mov dl, ah
    add dl, 30h	    	;convert to ascii
    mov ah,2
    int 21h				;print max(wos,sco)



    mov ah,40h
    mov bx,1
    mov cx, sizeof string5
    mov dx, offset string5
    int 21h				;print string4
    mov ah,2
    mov dl, 0ah			;print '\n'
    int 21h

    pop dx
    inc si
    inc si
    jmp loop_p

exit_loopp: mov ah,2
    mov dl, 0ah			;print '\n'
    int 21h
    popa
    ret
    print_max_citations		endp


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
    cmp dx,15
    ja err_int  ;if dx is greater than 15 error arised
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






exit:
call printNL		;this procedure prints a new line
mov ah, 09h		        ;09h is the function of interrupt 21h which prints a string on
mov dx, offset end_program  ;dx is the pointer to the
int 21h                     ;here i'm printing the end_item1 message

.exit

end
